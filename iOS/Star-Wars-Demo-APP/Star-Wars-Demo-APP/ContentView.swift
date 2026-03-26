import SwiftUI
import SwiftData

struct ContentView: View {
    let dependencies: DependencyContainer

    var body: some View {
        AppRouter(dependencies: dependencies)
    }
}

#Preview {
    let schema = Schema([FilmSwiftDataModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let deps = DependencyContainer(modelContainer: container)

    return ContentView(dependencies: deps)
        .modelContainer(container)
}
