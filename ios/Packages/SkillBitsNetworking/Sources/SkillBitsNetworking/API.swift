import Foundation
import SkillBitsCore

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}

public protocol APIRequest: Sendable {
    associatedtype Response: Decodable
    var method: HTTPMethod { get }
    var path: String { get }
    var body: Data? { get }
}

public struct APIEndpoint<Response: Decodable>: APIRequest {
    public let method: HTTPMethod
    public let path: String
    public let body: Data?

    public init(method: HTTPMethod, path: String, body: Data? = nil) {
        self.method = method
        self.path = path
        self.body = body
    }
}

public enum NetworkError: Error {
    case notFound
    case decodingFailed
}

public protocol APIClient: Sendable {
    func send<T: APIRequest>(_ request: T) async throws -> T.Response
}
