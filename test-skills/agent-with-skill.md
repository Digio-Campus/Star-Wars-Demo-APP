● List directory .
  └ 10 files found

● Read SKILL.md
  │ .agents/skills/swiftui-expert-skill/SKILL.md
  └ 281 lines read

Perfecto. He leído el archivo **SKILL.md** de SwiftUI Expert y aplicaré sus recomendaciones. Ahora te presento una respuesta técnica y detallada sobre el ciclo de vida en SwiftUI y gestión de memoria.

---

## 📖 Confirmación de lectura de la Skill

**Sí, he leído y consultado el archivo `/home/valero/Star-Wars-Demo-APP/.agents/skills/swiftui-expert-skill/SKILL.md`.** 

Aplicaré específicamente las recomendaciones sobre:
- **Gestión de estado**: `@State` (privado), `@Binding`, `@StateObject` vs `@ObservedObject`, `@Bindable` (iOS 17+)
- **View composition**: views simples y puras sin side effects en `body`
- **Performance**: evitar dependencias innecesarias, cuidar los closures (capturar valores)
- **Patrones de seguridad**: gating de APIs con `#available`, closures `Sendable` capturando valores en lugar de acceder a estado `@MainActor`

---

## 🔄 Ciclo de Vida de una Vista en SwiftUI

### 1. **Creación e Identidad de la Vista**

Cuando SwiftUI crea una vista, primero establece su **identidad estructural**. Cada vez que el `body` se evalúa, SwiftUI compara la estructura anterior con la nueva usando:

```swift
// Identidad EXPLÍCITA (recomendado)
List {
    ForEach(characters, id: \.id) { char in  // ✅ Identidad estable
        CharacterRow(character: char)
    }
}

// ❌ EVITAR: Identidad implícita por índice (rompe animaciones)
ForEach(characters.indices, id: \.self) { index in
    CharacterRow(character: characters[index])
}
```

**Impacto en ARC**: Cada identidad diferente crea una **nueva instancia de vista** en SwiftUI. Si la identidad cambia sin razón, se libera la anterior (potencial memory leak si has referencias retenidas) y se crea una nueva.

---

### 2. **Fase de Inicialización: `init()` y `onAppear`**

```swift
struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterViewModel  // ✅ Se retiene durante toda la vida de la vista
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                Text(viewModel.character.name)
            }
        }
        .onAppear {
            isLoading = true
            Task {
                await viewModel.fetchDetails()
                isLoading = false
            }
        }
    }
}
```

**Ciclo de ARC aquí**:
- `@StateObject` se crea **una sola vez** y se retiene mientras la vista viva. ARC cuenta = 1
- Cuando `onAppear` ejecuta, se captura `self` implícitamente en el closure de `Task`
- **Riesgo**: Si usas `self.viewModel` directamente en el closure sin captura explícita y luego la vista desaparece, puede haber ciclo de referencia

---

### 3. **Actualización del `body` (Invalidación)**

Cada vez que se invalida una vista (cambio de `@State`, `@Binding`, `@ObservedObject`), SwiftUI:

1. **Re-evalúa** el `body` completamente
2. **Compara** la nueva jerarquía con la anterior
3. **Actualiza** solo lo que cambió

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1  // ✅ Triggers body re-evaluation
            }
        }
    }
}
```

**Impacto en memoria**:
- Cada re-evaluación es una **copia temporal** de la jerarquía de vistas
- SwiftUI descarta la copia anterior (ARC cuenta disminuye)
- Si haces trabajo **pesado en `body` directamente**, multiplicas ese trabajo por cada invalidación

---

### 4. **Ciclos de vida de `onAppear` y `onDisappear`**

```swift
struct DataFetchView: View {
    @StateObject private var viewModel = DataViewModel()
    
    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
        }
        .onAppear {
            // ✅ Se ejecuta DESPUÉS de que la vista se dibuja
            viewModel.startPolling()
        }
        .onDisappear {
            // ✅ Se ejecuta ANTES de que la vista desaparezca
            viewModel.stopPolling()  // CRÍTICO: detener observables
        }
    }
}
```

**ARC y ciclo de vida**:
- `onAppear` se ejecuta después del primer `body` (la vista ya tiene referencias visuales)
- `onDisappear` se ejecuta **antes de la liberación** (es tu último chance de cleanup)
- **Sin `onDisappear` adecuado**: Tasks activos, timers, Combine subscriptions **quedan en memoria**

---

## 🔄 Gestión de Memoria: Property Wrappers y ARC

### `@State`: Propietario Local

```swift
struct FormView: View {
    @State private var email = ""      // ✅ SwiftUI es propietario, ARC cuenta = 1
    @State private var password = ""   // Cada @State es independiente
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)  // $email es Binding
            TextField("Password", text: $password)
        }
    }
}
```

**Ciclo ARC**:
- SwiftUI retiene `email` y `password` en su propio almacén (`@State`)
- No necesitas retener referencias; desaparecen con la vista
- ✅ **Seguro**: No hay ciclos de referencia posibles con `@State`

---

### `@Binding`: Propietario Externo

```swift
struct ParentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChildView(selection: $selectedTab)  // Binding al padre
        }
    }
}

struct ChildView: View {
    @Binding var selection: Int  // No es propietario, solo observa
    
    var body: some View {
        Button("Change") {
            selection = 1  // Modifica el padre
        }
    }
}
```

**ARC**:
- `@Binding` solo **referencia** el `@State` del padre
- ARC cuenta del padre: +1 (el hijo tiene una referencia temporal)
- Cuando el hijo desaparece, la referencia se libera

---

### `@StateObject` vs `@ObservedObject`

```swift
// ✅ CORRECTO: La vista es PROPIETARIA
struct CharacterDetailView: View {
    @StateObject private var viewModel = CharacterViewModel()  // Creado aquí
    
    var body: some View {
        Text(viewModel.character.name)
    }
}

// ✅ CORRECTO: La vista RECIBE el objeto
struct CharacterCardView: View {
    @ObservedObject var viewModel: CharacterViewModel  // Inyectado, no propietario
    
    var body: some View {
        Text(viewModel.character.name)
    }
}

// ❌ INCORRECTO: @StateObject con valor inicial
struct BuggyView: View {
    @StateObject private var viewModel = CharacterViewModel()  // ✅ OK
    // @StateObject private var child: ChildViewModel  // ❌ Si lo pasas al init, ignora cambios
}
```

**ARC**:
- `@StateObject`: SwiftUI **posee** el objeto (ARC count = 1 durante la vida de la vista)
- `@ObservedObject`: Alguien más lo posee; la vista solo observa (ARC count = N, donde N = propietarios)
- **Riesgo en `@ObservedObject`**: Si el propietario desaparece, el objeto se libera y la vista crashea

---

### `@Observable` + `@Bindable` (iOS 17+)

```swift
import Observation

@Observable
final class CharacterViewModel {
    var character: Character?
    var isLoading = false
    
    func fetchCharacter() { }
}

struct DetailView: View {
    @State private var viewModel = CharacterViewModel()  // ✅ Directo con @State
    
    var body: some View {
        ChildView(viewModel: viewModel)  // Solo let, no necesita @Binding
    }
}

struct ChildView: View {
    var viewModel: CharacterViewModel  // read-only
    
    var body: some View {
        TextField("Name", text: $viewModel.character?.name ?? "")  // ✅ $ funciona con @Observable
    }
}
```

**ARC**: 
- `@Observable` clases **no** necesitan `@StateObject`; son más eficientes
- SwiftUI captura cambios a nivel de **propiedad** (no de objeto completo)
- Menos re-renders innecesarios = menos presión en memoria

---

### `@EnvironmentObject`: Propagación Global

```swift
@Observable
final class AppState {
    var authToken: String?
    var currentUser: User?
}

@main
struct StarWarsApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)  // ✅ Disponible en toda la jerarquía
        }
    }
}

struct DetailView: View {
    @Environment(AppState.self) var appState  // iOS 17+
    // O @EnvironmentObject var appState: AppState  // iOS 16 y anterior
    
    var body: some View {
        Text(appState.currentUser?.name ?? "Unknown")
    }
}
```

**ARC**:
- El environment retiene referencias a `appState`
- Cada vista que accede a él incrementa el ARC count temporalmente
- ✅ **Seguro**: El ambiente se asegura de que el objeto viva mientras se necesite

---

## 🚨 Ciclos de Referencia: Closures y Combine

### Problema: Retención Fuerte en Closures

```swift
class CharacterViewModel: ObservableObject {
    @Published var character: Character?
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    
    func loadCharacter(id: Int) {
        // ❌ PROBLEMA: El closure captura 'self' fuertemente
        apiService.fetch(id: id)
            .sink { [weak self] completion in  // ✅ SOLUCIÓN: [weak self]
                switch completion {
                case .failure(let error):
                    self?.character = nil  // self puede ser nil
                case .finished:
                    break
                }
            } receiveValue: { [weak self] character in
                self?.character = character
            }
            .store(in: &cancellables)
    }
}
```

**ARC sin `[weak self]`**:

ViewModel retiene cancellables -> cancellables retiene Publisher -> Publisher retiene closure -> closure captura self fuertemente -> CICLO: ViewModel -> cancellables -> closure -> ViewModel

**Solución**: Usar `[weak self]` o `[unowned self]`

```swift
.sink { [weak self] completion in  // ✅ Referencia débil
    guard let self else { return }
    // ...
}
```

---

### Problema: Closures en `onReceive`

```swift
struct CharacterView: View {
    @StateObject private var viewModel = CharacterViewModel()
    @State private var data: [Character] = []
    
    var body: some View {
        List(data) { character in
            Text(character.name)
        }
        .onReceive(viewModel.$characters) { newCharacters in
            // ⚠️ El closure captura implícitamente 'self'
            data = newCharacters
        }
    }
}
```

**Problema**: Si `viewModel` retiene referencias a vistas (poco común, pero posible), hay un ciclo.

**Solución**:

```swift
.onReceive(viewModel.$characters) { [weak viewModel] newCharacters in
    guard viewModel != nil else { return }
    data = newCharacters
}
```

---

### Problema: Closures en Layout (iOS 18+)

```swift
struct HeavyView: View {
    @State private var viewModel = ExpensiveViewModel()
    
    var body: some View {
        VStack {
            Text("Data")
        }
        .onGeometryChange(of: \.frame) { _, newFrame in
            // ⚠️ Este closure puede ejecutarse fuera del main thread
            // No accedas a @MainActor state aquí
            let value = viewModel.computeValue()  // ❌ Puede crashear
        }
    }
}

// ✅ CORRECTO: Capturar valores antes
.onGeometryChange(of: \.frame) { _, newFrame in
    let cachedValue = viewModel.computeValue()  // Captura el valor
    // Usa cachedValue sin acceder a viewModel
}
```

---

## 📋 Recomendaciones Prácticas para Evitar Memory Leaks

### 1. **Siempre usar `[weak self]` en Publishers**

```swift
class ViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    func observe<T>(_ publisher: AnyPublisher<T, Error>) where T: Any {
        publisher
            .sink(
                receiveCompletion: { [weak self] completion in  // ✅
                    // ...
                },
                receiveValue: { [weak self] value in  // ✅
                    // ...
                }
            )
            .store(in: &cancellables)
    }
}
```

### 2. **Detener Observables en `onDisappear`**

```swift
struct ObservingView: View {
    @State private var cancellable: AnyCancellable?
    @State private var value = ""
    
    var body: some View {
        Text(value)
            .onAppear {
                cancellable = Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in value = "\(Date())" }
            }
            .onDisappear {
                cancellable?.cancel()  // ✅ CRÍTICO
            }
    }
}
```

### 3. **Evitar `AnyView` en Listas**

```swift
// ❌ AnyView causa memory issues en listas
List(items) { item in
    AnyView(
        VStack {
            Text(item.name)
        }
    )
}

// ✅ Extraer a subvista
List(items) { item in
    ItemRow(item: item)
}

struct ItemRow: View {
    let item: Item
    var body: some View {
        VStack {
            Text(item.name)
        }
    }
}
```

### 4. **Body Puro: Sin Side Effects**

```swift
// ❌ INCORRECTO: Side effects en body
struct BadView: View {
    @State private var data: [Character] = []
    
    var body: some View {
        VStack {
            ForEach(data, id: \.id) { char in
                Text(char.name)
            }
        }
        .onAppear {
            fetchData()  // ✅ Aquí sí (onAppear es el lugar)
        }
    }
    
    private func fetchData() {
        // ...
    }
}

// ❌ INCORRECTO: Operaciones en body
struct AnotherBadView: View {
    @State private var items: [Item] = []
    
    var body: some View {
        List(items.filter { $0.isActive }) {  // ❌ Se ejecuta CADA re-render
            Text($0.name)
        }
    }
}

// ✅ CORRECTO: Computación antes del body
var filteredItems: [Item] {
    items.filter { $0.isActive }
}

var body: some View {
    List(filteredItems) {
        Text($0.name)
    }
}
```

### 5. **Usar `let` para Valores Inmutables, `var` + `.onChange()` para Observados**

```swift
struct ChildView: View {
    let character: Character  // ✅ Valor, no binding
    var character: Character  // ✅ Observado (con .onChange)
    
    @Binding var selectedId: Int  // ✅ Solo si el hijo MODIFICA
    
    var body: some View {
        Text(character.name)
            .onChange(of: character) { oldValue, newValue in
                // React a cambios
            }
    }
}
```

### 6. **`@Environment` sobre `@EnvironmentObject` (iOS 17+)**

```swift
// iOS 17+: Más eficiente y type-safe
@Observable final class AppState { }

struct DetailView: View {
    @Environment(AppState.self) var appState  // ✅ Type-safe
}

// iOS 16: Alternativa
@EnvironmentObject var appState: AppState
```

### 7. **Validar Cambios antes de Asignar Estado**

```swift
// ❌ Causa actualizaciones innecesarias
.onChange(of: value) { newValue in
    state = newValue  // Se ejecuta incluso si no cambió realmente
}

// ✅ Validar primero
.onChange(of: value) { newValue in
    if state != newValue {
        state = newValue
    }
}
```

---

## 🎬 Diagrama de Ciclo de Vida Completo

```
┌──────────────────────────────────────────────────┐
│ 1. INIT: Crear @State, @StateObject             │
│    ARC count = 1 (SwiftUI es propietario)       │
└──────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────┐
│ 2. BODY EVALUATION: Jerarquía de vistas         │
│    (Posibles re-evaluaciones si @State cambia)  │
└──────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────┐
│ 3. APPEAR: onAppear ejecuta                     │
│    (Iniciar Tasks, subscriptions, etc.)         │
│    CRÍTICO: Capturar [weak self] si es needed  │
└──────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────┐
│ 4. LIVE: Vista visible, reacciona a cambios     │
│    State changes → re-evaluar body              │
└──────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────┐
│ 5. DISAPPEAR: onDisappear ejecuta               │
│    CRÍTICO: Cancelar subscriptions, timers      │
│    Liberar referencias débiles                   │
└──────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────┐
│ 6. DEINIT: SwiftUI libera @State, @StateObject  │
│    ARC count = 0 → Memoria reclamada             │
└──────────────────────────────────────────────────┘
```

---

## Conclusión

La gestión de memoria en SwiftUI es **automática y segura** si sigues estos principios:

1. ✅ Usa `@StateObject` cuando **creas** observables; `@ObservedObject` cuando los **recibes**
2. ✅ Siempre `[weak self]` en closures de Publishers
3. ✅ Cancela subscriptions en `onDisappear`
4. ✅ Mantén `body` **puro**: sin side effects, sin computación pesada
5. ✅ Prefiere `@Observable` + `@State` (iOS 17+) sobre `ObservableObject`
6. ✅ Pasa solo valores necesarios a subvistas (evita config objects grandes)

**El ciclo de vida de SwiftUI y ARC trabajan juntos automáticamente cuando respetas estas convenciones.**


Total usage est:        0.33 Premium requests
API time spent:         45s
Total session time:     51s
Total code changes:     +0 -0
Breakdown by AI model:
 claude-haiku-4.5        48.1k in, 6.0k out, 34.3k cached (Est. 0.33 Premium requests)
