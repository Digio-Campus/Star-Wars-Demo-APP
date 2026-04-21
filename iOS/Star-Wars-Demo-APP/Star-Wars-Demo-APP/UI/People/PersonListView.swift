import SwiftUI

struct PersonListView: View {
    private let repository: PersonRepository
    @StateObject private var viewModel: PersonListViewModel
    private let title = "Star Wars People"

    init(repository: PersonRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: PersonListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .background(StarWarsColors.background)
                .task {
                    await viewModel.loadPeople()
                }
                .navigationDestination(for: Int.self) { personId in
                    PersonDetailView(repository: repository, personId: personId)
                }
        }
    }

    private var content: some View {
        List {
            SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by name")
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            switch viewModel.uiState {
            case .loading:
                LoadingView()
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

            case .empty:
                ContentUnavailableView(
                    "No people",
                    systemImage: "person.2",
                    description: Text("Try a different search.")
                )
                .frame(maxWidth: .infinity, minHeight: 300)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            case .error(let message):
                ErrorView(message: message) {
                    Task { await viewModel.loadPeople() }
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            case .success(let people):
                ForEach(people) { person in
                    NavigationLink(value: person.id) {
                        PersonCardView(person: person)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deletePerson(person)
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                        }
                        .tint(.red)
                    }
                }

                InfiniteScrollFooterView(
                    isLoading: viewModel.isLoadingMore,
                    canLoadMore: viewModel.canLoadMore,
                    onLoadMore: viewModel.loadNextPageIfNeeded
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.loadPeople()
        }
    }

    private func deletePerson(_ person: Person) {
        Task { await viewModel.deleteItem(id: person.id) }
    }
}
