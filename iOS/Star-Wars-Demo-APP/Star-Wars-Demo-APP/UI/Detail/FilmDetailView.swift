import SwiftUI

struct FilmDetailView: View {
    @StateObject private var viewModel: FilmDetailViewModel

    @Environment(\.openURL) private var openURL

    @State private var scrollOffset: CGFloat = 0

    private static let scrollSpaceName = "film-detail-scroll"

    init(repository: FilmRepository, vimeoRepository: VimeoRepository, videoResolver: VideoResolver, filmId: Int) {
        _viewModel = StateObject(wrappedValue: FilmDetailViewModel(filmId: filmId, repository: repository, vimeoRepository: vimeoRepository, videoResolver: videoResolver))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                scrollOffsetSentinel

                switch viewModel.uiState {
                case .loading:
                    LoadingView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)

                case .error(let message):
                    ErrorView(message: message) {
                        viewModel.load()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)

                case .success(let film):
                    VStack(spacing: 0) {
                        VStack(spacing: 16) {
                            headerSection(film)
                            infoSection(film)
                            statsSection(film)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Opening Crawl (background edge-to-edge; content padded)
                        ZStack(alignment: .leading) {
                            StarWarsColors.surface
                                .ignoresSafeArea(.container, edges: [.horizontal])

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Opening Crawl")
                                    .font(.headline)
                                    .foregroundStyle(StarWarsColors.primary)

                                Text(normalizedOpeningCrawl(film.openingCrawl))
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .containerRelativeFrame(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)

                        FullWidthSection {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Video")
                                    .font(.headline)
                                    .foregroundStyle(StarWarsColors.primary)

                                if viewModel.isLoadingVimeoVideo {
                                    LoadingView()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 24)
                                } else {
                                        if let target = viewModel.playbackTarget {
                                        switch target {
                                        case .external(let url):
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Este vídeo no se puede reproducir embebido.")
                                                    .font(.footnote)
                                                    .foregroundStyle(.secondary)

                                                Button("Abrir en YouTube") {
                                                    openURL(url)
                                                }
                                                .buttonStyle(.bordered)
                                                .tint(StarWarsColors.primary)
                                            }

                                        case .vimeo, .direct:
                                            IOSTrailerPlayerView(source: target.toVideoSource())
                                                .frame(height: 210)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                        case .embedded(_, let thumbnailUrl):
                                            let source = target.toVideoSource()
                                            if case .YouTube(let videoId, _) = source {
                                                YouTubeThumbnailPlayerView(videoId: videoId, thumbnailUrl: thumbnailUrl)
                                                    .frame(height: 210)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            } else {
                                                IOSTrailerPlayerView(source: source)
                                                    .frame(height: 210)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                        }
                                    } else {
                                        if let message = viewModel.vimeoErrorMessage {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(message)
                                                    .font(.footnote)
                                                    .foregroundStyle(.secondary)

                                                Button("Retry") {
                                                    Task { await viewModel.loadVimeoVideo() }
                                                }
                                                .buttonStyle(.bordered)
                                                .tint(StarWarsColors.primary)
                                            }
                                        } else {
                                            Text("No video available")
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .containerRelativeFrame(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)

                        Color.clear
                            .frame(height: 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .coordinateSpace(.named(Self.scrollSpaceName))
        .onPreferenceChange(ScrollYPreferenceKey.self) { y in
            // minY is ~0 at rest and becomes negative as the user scrolls down.
            scrollOffset = min(y, 0)
        }
        .background {
            StarWarsColors.background
                .ignoresSafeArea()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                collapsibleNavigationTitle
            }
        }
        .task {
            viewModel.load()
        }
    }

    private var navigationTitle: String {
        if case .success(let film) = viewModel.uiState {
            return film.title
        }
        return "Film Detail"
    }

    private var titleScale: CGFloat {
        let expanded: CGFloat = 1.4
        let collapsed: CGFloat = 0.85
        let collapseDistance: CGFloat = 100

        let progress = min(max((-scrollOffset) / collapseDistance, 0), 1)
        return expanded + (collapsed - expanded) * progress
    }

    private var collapsibleNavigationTitle: some View {
        Text(navigationTitle)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .scaleEffect(titleScale)
            .animation(.easeInOut(duration: 0.22), value: titleScale)
            .accessibilityAddTraits(.isHeader)
    }

    private var scrollOffsetSentinel: some View {
        Color.clear
            .frame(height: 1)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ScrollYPreferenceKey.self,
                            value: proxy.frame(in: .named(Self.scrollSpaceName)).minY
                        )
                }
            }
    }

    private func headerSection(_ film: Film) -> some View {
        card {
            VStack(alignment: .leading, spacing: 6) {
                Text("Episode \(film.episodeId.toRomanNumeral())")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StarWarsColors.primary)

                Text(film.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
            }
        }
    }

    private func infoSection(_ film: Film) -> some View {
        card {
            Text("Info")
                .font(.headline)
                .foregroundStyle(StarWarsColors.primary)

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow { label("Director"); value(film.director) }
                GridRow { label("Producer"); value(film.producer) }
                GridRow { label("Release"); value(film.releaseDate) }
            }
        }
    }

    private func statsSection(_ film: Film) -> some View {
        card {
            Text("Stats")
                .font(.headline)
                .foregroundStyle(StarWarsColors.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                statCard("Characters", film.charactersCount)
                statCard("Planets", film.planetsCount)
                statCard("Starships", film.starshipsCount)
                statCard("Vehicles", film.vehiclesCount)
                statCard("Species", film.speciesCount)
            }
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func value(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statCard(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(StarWarsColors.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(StarWarsColors.background.opacity(0.25), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(StarWarsColors.primary.opacity(0.12))
        }
    }

    private func normalizedOpeningCrawl(_ text: String) -> String {
        text
            .components(separatedBy: .newlines)
            .joined(separator: " ")
    }
}

private struct ScrollYPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
