import Foundation

protocol VimeoRepository {
    func searchVimeoVideo(title: String) async throws -> VimeoVideo?
}
