import Foundation

protocol VideoResolver {
    func resolve(title: String) async throws -> PlaybackTarget?
}
