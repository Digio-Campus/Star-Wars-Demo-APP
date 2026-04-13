import SwiftUI

struct MainTabView: View {
    let dependencies: DependencyContainer

    var body: some View {
        TabView {
            FilmListView(repository: dependencies.filmRepository)
                .tabItem {
                    Label("Films", systemImage: "film")
                }

            StarshipListView(repository: dependencies.starshipRepository)
                .tabItem {
                    Label("Starships", systemImage: "airplane")
                }

            PlanetListView(repository: dependencies.planetRepository)
                .tabItem {
                    Label("Planets", systemImage: "globe")
                }

            PersonListView(repository: dependencies.personRepository)
                .tabItem {
                    Label("People", systemImage: "person.2")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(StarWarsColors.primary)
    }
}
