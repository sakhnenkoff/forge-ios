import Foundation

public protocol NetworkingServiceProtocol: Sendable {
    func send<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T
    func send(_ request: URLRequest) async throws
}

// SAFETY: Stored state is immutable; decoding uses a new JSONDecoder per call.
// TODO(CONC-002): Remove @unchecked Sendable after Foundation sendability reaches full coverage.
@available(iOS 15.0, macOS 12.0, *)
public final class NetworkingService: NetworkingServiceProtocol, @unchecked Sendable {
    private let urlSession: URLSession
    private let decodeStrategy: DecodeStrategy

    public init(
        urlSession: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.urlSession = urlSession
        self.decodeStrategy = DecodeStrategy(
            dateDecodingStrategy: decoder.dateDecodingStrategy,
            dataDecodingStrategy: decoder.dataDecodingStrategy,
            nonConformingFloatDecodingStrategy: decoder.nonConformingFloatDecodingStrategy,
            keyDecodingStrategy: decoder.keyDecodingStrategy
        )
    }

    public func send<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await performRequest(request)
        try validateResponse(response)
        return try decode(data)
    }

    public func send(_ request: URLRequest) async throws {
        let (_, response) = try await performRequest(request)
        try validateResponse(response)
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await urlSession.data(for: request)
        } catch {
            throw APIError.network(error: error)
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 400...499:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw APIError.unknown
        }
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = decodeStrategy.dateDecodingStrategy
            decoder.dataDecodingStrategy = decodeStrategy.dataDecodingStrategy
            decoder.nonConformingFloatDecodingStrategy = decodeStrategy.nonConformingFloatDecodingStrategy
            decoder.keyDecodingStrategy = decodeStrategy.keyDecodingStrategy
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error: error)
        }
    }
}

private struct DecodeStrategy {
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    let dataDecodingStrategy: JSONDecoder.DataDecodingStrategy
    let nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy
    let keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
}
