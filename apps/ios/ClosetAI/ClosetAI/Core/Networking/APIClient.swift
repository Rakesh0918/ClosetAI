//
//  APIClient.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation

protocol APIClient: Sendable {
    func send<Response>(
        _ request: APIRequest<Response>
    ) async throws -> Response
}

struct URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let sessionRefresher: (any SessionRefreshing)?

    init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        sessionRefresher: (any SessionRefreshing)? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.sessionRefresher = sessionRefresher
    }

    func send<Response>(
        _ request: APIRequest<Response>
    ) async throws -> Response {
        let urlRequest = try makeURLRequest(from: request)

        do {
            let (data, response) = try await session.data(
                for: urlRequest
            )

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(
                    statusCode: httpResponse.statusCode
                )
            }

            // HTTP 204 / empty successful response.
            if data.isEmpty {
                guard let emptyResponse = NoContentResponse() as? Response else {
                    throw NetworkError.decodingFailed(
                        underlying: "Expected response body but received empty data."
                    )
                }

                return emptyResponse
            }

            do {
                return try decoder.decode(
                    Response.self,
                    from: data
                )
            } catch {
                throw NetworkError.decodingFailed(
                    underlying: error.localizedDescription
                )
            }
        } catch is CancellationError {
            throw NetworkError.requestCancelled
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            throw NetworkError.requestFailed(
                underlying: error.localizedDescription
            )
        }
    }
}

// MARK: - Request Construction

private extension URLSessionAPIClient {

    func makeURLRequest<Response>(
        from request: APIRequest<Response>
    ) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(
                path: request.path
            ),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(
            url: url
        )

        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        for (field, value) in request.headers {
            urlRequest.setValue(
                value,
                forHTTPHeaderField: field
            )
        }

        return urlRequest
    }

    func mapURLError(
        _ error: URLError
    ) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet,
             .networkConnectionLost:
            return .noInternetConnection

        case .cancelled:
            return .requestCancelled

        default:
            return .requestFailed(
                underlying: error.localizedDescription
            )
        }
    }
}
