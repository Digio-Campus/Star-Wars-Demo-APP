# Ciclo de Vida de SwiftUI y Gestión de Memoria con ARC

Te presento un análisis técnico detallado sobre el ciclo de vida de vistas en SwiftUI y su interacción con ARC:

## 1. Ciclo de Vida de una Vista SwiftUI

### Fases Principales

```swift
struct ContentView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
                .onAppear {
                    // 1. INITIALIZATION: La vista se crea, @State se inicializa
                    print("Appear - Vista lista para interacción")
                }
                .onDisappear {
                    // 6. CLEANUP: La vista se destruye, libera recursos
                    print("Disappear - Limpieza de recursos")
                }
            
            Button("Incrementar") {
                // 3. INVALIDATION: state cambia → body se recalcula
                count += 1
            }
        }
        // 2. BODY EVALUATION: Se ejecuta para generar la vista
        // 4. RENDER: UIKit renderiza los cambios
        // 5. DIFF: SwiftUI compara con la anterior vista
    }
}
```

### Fases Detalladas

| Fase | Descripción | ARC Impact |
|------|-------------|-----------|
| **Creación** | Se asigna memoria para la instancia de la vista | `retain count++` |
| **Body Evaluation** | SwiftUI invoca `var body` y analiza su contenido | Temporal, garbage collected rápidamente |
| **Invalidation** | Un estado cambia, disparando recalculación | Body se re-evalúa |
| **Rendering** | UIKit renderiza la jerarquía en pantalla | Las vistas previas se liberan |
| **onAppear** | Se ejecuta después del primer render | Ideal para setup |
| **onDisappear** | Se ejecuta antes de destruir la vista | Deben cancelarse subscripciones |

---

## 2. Diferencias Críticas de Wrappers de Propiedades

### @State vs @Binding

```swift
// @State: Propietario del estado (source of truth)
struct ParentView: View {
    @State private var name = "Juan"
    
    var body: some View {
        VStack {
            ChildView(name: $name)  // Pasa reference
        }
        // ARC: El estado vive mientras ParentView exista
    }
}

// @Binding: Referencia al estado del padre (no propietario)
struct ChildView: View {
    @Binding var name: String
    
    var body: some View {
        TextField("Nombre", text: $name)
        // ARC: No retiene ownership, solo referencia
    }
}
```

**ARC Implication**: `@Binding` usa `Ref<T>` internamente, no incrementa `retain count` del valor.

---

### @ObservedObject vs @StateObject

```swift
class ViewModel: ObservableObject {
    @Published var data = ""
    deinit { print("ViewModel deallocado") }
}

// ❌ PROBLEMATICO: @ObservedObject recrea el objeto en cada body evaluation
struct BadView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        Text(viewModel.data)
        // Si BadView se recrea, ViewModel se libera y recrea
        // Puede causar memory leaks o loss de estado
    }
}

// ✅ CORRECTO: @StateObject retiene el objeto durante toda la vida de la vista
struct GoodView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        Text(viewModel.data)
        // ViewModel persiste mientras GoodView exista
        // deinit se ejecuta cuando GoodView se destruye
    }
}
```

**ARC**: `@StateObject` incrementa `retain count` del ViewModel. Cuando la vista se destruye, el `retain count` disminuye y el objeto es deallocado (si no hay otras referencias).

---

### @EnvironmentObject

```swift
class AppState: ObservableObject {
    @Published var user: User?
}

@main
struct App: SwiftUI.App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                // Inyecta AppState en toda la jerarquía
        }
    }
}

struct DeepNestedView: View {
    @EnvironmentObject var appState: AppState
    // Accede sin pasar explícitamente
    
    var body: some View {
        Text("User: \(appState.user?.name ?? "N/A")")
    }
}
```

**ARC**: El propietario es quien lo crea con `@StateObject`. Las vistas que lo consumen con `@EnvironmentObject` solo mantienen referencias débiles implícitas.

---

## 3. Identidad de la Vista (View Identity)

SwiftUI usa **Structural Identity** o **Explicit Identity** para diferenciar vistas:

```swift
struct CounterList: View {
    @State private var items = [1, 2, 3]
    
    var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                // ❌ Problema: Cuando items cambia, todas las vistas se recrean
                CounterItem(initialValue: item)
            }
            
            Button("Agregar") {
                items.append(items.max()! + 1)
                // Todas las CounterItems pierden @State
            }
        }
    }
}

struct CounterItem: View {
    @State private var count = 0
    let initialValue: Int
    
    var body: some View {
        HStack {
            Text("Item: \(initialValue), Count: \(count)")
            Button("+") { count += 1 }
        }
    }
}
```

**Solución**: Usar un modelo con `id` único:

```swift
struct Item: Identifiable {
    let id = UUID()
    var value: Int
}

struct CounterList: View {
    @State private var items = [Item(value: 1), Item(value: 2)]
    
    var body: some View {
        VStack {
            ForEach(items) { item in
                // ✅ Cada item mantiene su identidad, su @State persiste
                CounterItem(item: item)
            }
        }
    }
}
```

---

## 4. Ciclos de Referencia con Closures

### Problema Común

```swift
class NetworkManager: ObservableObject {
    @Published var data = ""
    
    func fetchData() {
        let url = URL(string: "https://api.example.com/data")!
        
        URLSession.shared.dataTask(with: url) { [self] data, _, _ in
            // ❌ MEMORY LEAK: [self] crea un ciclo de referencia
            // dataTask retiene self
            // self retiene dataTask (implícitamente via closure capture)
            // Cuando dataTask termina, self no se libera porque dataTask retiene self
            
            if let data = data {
                self.data = String(data: data, encoding: .utf8) ?? ""
            }
        }.resume()
    }
}
```

### Solución: Weak Self

```swift
class NetworkManager: ObservableObject {
    @Published var data = ""
    
    func fetchData() {
        let url = URL(string: "https://api.example.com/data")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            // ✅ CORRECTO: [weak self] previene el ciclo de referencia
            // self es una referencia débil, no incrementa retain count
            guard let self = self else { return }  // Verifica si aún existe
            
            if let data = data {
                self.data = String(data: data, encoding: .utf8) ?? ""
            }
        }.resume()
    }
}
```

---

## 5. Combine y Memory Management

### Subscripciones que Generan Leaks

```swift
class DataViewModel: ObservableObject {
    @Published var items = [String]()
    private var cancellables = Set<AnyCancellable>()
    
    // ❌ LEAK: Sin almacenar AnyCancellable
    func startBadListening() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                print("Tick") // Esta subscripción NUNCA se cancela
                // Timer sigue ejecutándose aunque la vista se destruya
            }
            // No guardamos el AnyCancellable, por lo que se libera inmediatamente
            // Pero Timer.publish sigue activo
    }
    
    // ✅ CORRECTO: Guardar AnyCancellable
    func startGoodListening() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                print("Tick")
            }
            .store(in: &cancellables)  // Almacena la subscripción
        
        // Cuando DataViewModel se destruye, cancellables se libera
        // y todas las subscripciones se cancelan automáticamente
    }
    
    deinit {
        // Las subscripciones se cancelan aquí
        cancellables.removeAll()
    }
}
```

### Combine + Closures

```swift
class ChatViewModel: ObservableObject {
    @Published var messages = [String]()
    private var cancellables = Set<AnyCancellable>()
    
    func setupMessageListener() {
        let publisher = URLSession.shared.dataTaskPublisher(for: URL(string: "...")!)
        
        publisher
            .sink(receiveCompletion: { [weak self] completion in
                // ✅ [weak self] aquí también es crítico
                switch completion {
                case .failure(let error):
                    print("Error: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] data in
                guard let self = self else { return }
                self.messages.append(String(data: data.data, encoding: .utf8) ?? "")
            })
            .store(in: &cancellables)
    }
}
```

---

## 6. Patrones de Memory Leak en SwiftUI

### Leak 1: Timer No Cancelado

```swift
struct TimerView: View {
    @State private var timer: Timer?
    
    var body: some View {
        Text("Timer Running")
            .onAppear {
                // ❌ LEAK: Timer sigue corriendo aunque la vista desaparezca
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    print("Tick")
                }
            }
            .onDisappear {
                // ✅ CORRECTO: Cancelar en onDisappear
                timer?.invalidate()
                timer = nil
            }
    }
}
```

### Leak 2: Binding a Closure con Captura Fuerte

```swift
struct BadBindingView: View {
    @State private var text = ""
    var callback: (String) -> Void
    
    var body: some View {
        // ❌ LEAK: Si callback captura self fuertemente
        TextField("Escribir", text: Binding(
            get: { text },
            set: { newValue in
                text = newValue
                callback(text)  // Puede causar ciclo si callback retiene self
            }
        ))
    }
}
```

### Leak 3: URLSession sin Cancelación

```swift
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellables = Set<AnyCancellable>()
    private var dataTask: URLSessionDataTask?
    
    func loadImage(from url: URL) {
        // ❌ LEAK: Si la vista se destruye antes de que termine, 
        // el dataTask sigue reteniendo self
        dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            if let data = data {
                self.image = UIImage(data: data)
            }
        }
        dataTask?.resume()
    }
    
    deinit {
        // ✅ CORRECTO: Cancelar la tarea al destruirse
        dataTask?.cancel()
    }
}
```

---

## 7. Recomendaciones Prácticas

| Recomendación | Razón | Ejemplo |
|---|---|---|
| **Usa @StateObject para ViewModel** | Persiste el objeto durante toda la vida de la vista | `@StateObject var vm = ViewModel()` |
| **[weak self] en closures** | Previene ciclos de referencia | `URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in` |
| **.store(in: &cancellables)** | Cancela subscripciones automáticamente | `publisher.sink {...}.store(in: &cancellables)` |
| **Cancela timers en onDisappear** | Evita que continúen ejecutándose | `timer?.invalidate()` |
| **Usa Identifiable en ForEach** | Mantiene identidad y @State en items | `ForEach(items) { item in` |
| **guard let self = self** | Verifica que el objeto aún exista | `guard let self = self else { return }` |
| **Limpia en deinit** | Libera recursos antes de destruirse | `cancellables.removeAll()` |

---

## 8. Ejemplo Completo: ViewModel Seguro

```swift
class SecureViewModel: ObservableObject {
    @Published var data = ""
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private var dataTask: URLSessionDataTask?
    private var timer: Timer?
    
    // ✅ Carga de datos segura
    func fetchData() {
        isLoading = true
        let url = URL(string: "https://api.example.com/data")!
        
        dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    self.data = String(data: data, encoding: .utf8) ?? ""
                }
            }
        }
        dataTask?.resume()
    }
    
    // ✅ Subscripción segura a Combine
    func startPolling() {
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchData()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        dataTask?.cancel()
        timer?.invalidate()
        cancellables.removeAll()
        print("SecureViewModel deallocado correctamente")
    }
}

struct SecureView: View {
    @StateObject private var viewModel = SecureViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.data)
            }
            
            Button("Cargar") {
                viewModel.fetchData()
            }
        }
        .onAppear {
            viewModel.startPolling()
        }
    }
}
```

---

## Resumen: Ciclo de Vida y ARC

1. **Creación**: Vista se asigna en memoria, `retain count++`
2. **onAppear**: Se ejecuta, configura recursos
3. **Body Updates**: Se evalúa cuando el estado cambia
4. **onDisappear**: Se ejecuta, cancela operaciones
5. **Destruction**: Vista se libera, `retain count--`, deinit ejecuta limpieza

**Clave**: Siempre limpia en `onDisappear` o `deinit` lo que inicies en `onAppear`.


Total usage est:        0.33 Premium requests
API time spent:         32s
Total session time:     37s
Total code changes:     +0 -0
Breakdown by AI model:
 claude-haiku-4.5        21.0k in, 4.7k out, 14.0k cached (Est. 0.33 Premium requests)
