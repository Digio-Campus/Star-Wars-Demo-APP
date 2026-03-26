import SwiftUI
import SwiftData

@main
struct Star_Wars_Demo_APPApp: App {
    let modelContainer: ModelContainer
    @State private var dependencies: DependencyContainer

    @MainActor
    init() {
        let schema = Schema([FilmSwiftDataModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self.modelContainer = container
            _dependencies = State(initialValue: DependencyContainer(modelContainer: container))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
        }
        .modelContainer(modelContainer)
    }
}
