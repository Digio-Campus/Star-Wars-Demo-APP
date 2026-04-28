import Foundation

public enum VideoError: Error, Equatable {
    case authMissing
    case quotaExceeded
    case regionBlocked
    case notFound
    case network(String)
    case providerUnsupported
    case parsingError
    case unknown
}
