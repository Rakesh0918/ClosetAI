//
//  APIClientTests.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import XCTest

@testable import ClosetAI

final class APIClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()

        MockURLProtocol.reset()
    }

    // MARK: - Successful Response

    func testSuccessfulResponseIsDecoded() async throws {
        MockURLProtocol.configure(
            statusCode: 200,
            responseBody: #"{"name":"Rakesh"}"#
        )

        let client = makeClient()

        let request = await APIRequest<UserResponse>(
            path: "/v1/user"
        )

        let response = try await client.send(request)

        XCTAssertEqual(response.name, "Rakesh")
    }

    // MARK: - HTTP Error

    func testNonSuccessfulStatusCodeThrowsHTTPError() async {
        MockURLProtocol.configure(
            statusCode: 404,
            responseBody: #"{"error":"not_found"}"#
        )

        let client = makeClient()

        let request = await APIRequest<UserResponse>(
            path: "/v1/user"
        )

        do {
            _ = try await client.send(request)

            XCTFail("Expected NetworkError.httpError")
        } catch let error as NetworkError {
            XCTAssertEqual(
                error,
                .httpError(statusCode: 404)
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Decoding Error

    func testInvalidJSONThrowsDecodingError() async {
        MockURLProtocol.configure(
            statusCode: 200,
            responseBody: #"{"invalid":true}"#
        )

        let client = makeClient()

        let request = await APIRequest<UserResponse>(
            path: "/v1/user"
        )

        do {
            _ = try await client.send(request)

            XCTFail("Expected NetworkError.decodingFailed")
        } catch let error as NetworkError {
            switch error {
            case .decodingFailed:
                XCTAssertTrue(true)

            default:
                XCTFail(
                    "Expected decodingFailed, got \(error)"
                )
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - HTTP Method

    func testRequestUsesConfiguredHTTPMethod() async throws {
        MockURLProtocol.configure(
            statusCode: 200,
            responseBody: #"{"name":"Rakesh"}"#
        )

        let client = makeClient()

        let request = await APIRequest<UserResponse>(
            path: "/v1/user",
            method: .post
        )

        let response = try await client.send(request)

        XCTAssertEqual(response.name, "Rakesh")
        XCTAssertEqual(
            MockURLProtocol.lastRequest?.httpMethod,
            "POST"
        )
    }

    // MARK: - Helpers

    private func makeClient() -> URLSessionAPIClient {
        let configuration = URLSessionConfiguration.ephemeral

        configuration.protocolClasses = [
            MockURLProtocol.self
        ]

        let session = URLSession(
            configuration: configuration
        )

        return URLSessionAPIClient(
            baseURL: URL(
                string: "https://example.com"
            )!,
            session: session
        )
    }
    
    func testNoContentResponseSucceedsFor204() async throws {
        MockURLProtocol.configure(
            statusCode: 204,
            responseBody: ""
        )

        let client = makeClient()

        let request = APIRequest<NoContentResponse>(
            path: "/v1/test",
            method: .post
        )

        let response = try await client.send(request)

        XCTAssertNotNil(response)
    }
}

// MARK: - Test Response Model

private struct UserResponse: Decodable, Sendable {
    let name: String
}

// MARK: - Mock URL Protocol

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {

    private static let lock = NSLock()

    private nonisolated(unsafe) static var responseStatusCode = 200
    private nonisolated(unsafe) static var responseBody = Data()
    private nonisolated(unsafe) static var request: URLRequest?

    static var lastRequest: URLRequest? {
        lock.lock()
        defer { lock.unlock() }

        return request
    }

    static func configure(
        statusCode: Int,
        responseBody: String
    ) {
        lock.lock()
        defer { lock.unlock() }

        self.responseStatusCode = statusCode
        self.responseBody = Data(responseBody.utf8)
        self.request = nil
    }

    static func reset() {
        lock.lock()
        defer { lock.unlock() }

        responseStatusCode = 200
        responseBody = Data()
        request = nil
    }

    override class func canInit(
        with request: URLRequest
    ) -> Bool {
        true
    }

    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lock.lock()

        Self.request = request

        let statusCode = Self.responseStatusCode
        let responseBody = Self.responseBody

        Self.lock.unlock()

        guard let url = request.url else {
            client?.urlProtocol(
                self,
                didFailWithError: URLError(.badURL)
            )

            return
        }

        guard let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: [
                "Content-Type": "application/json"
            ]
        ) else {
            client?.urlProtocol(
                self,
                didFailWithError: URLError(
                    .badServerResponse
                )
            )

            return
        }

        client?.urlProtocol(
            self,
            didReceive: response,
            cacheStoragePolicy: .notAllowed
        )

        client?.urlProtocol(
            self,
            didLoad: responseBody
        )

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
