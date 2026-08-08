//
//  TokenStore.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import Foundation
import Security

protocol TokenStore: Sendable {
    func save(
        accessToken: String,
        refreshToken: String
    ) throws

    func load() throws -> StoredTokens?

    func clear() throws
}

struct StoredTokens: Sendable, Equatable, Codable {
    let accessToken: String
    let refreshToken: String
}

struct KeychainTokenStore: TokenStore {

    private let service: String
    private let account: String

    init(
        service: String = "com.rakesh.closetai",
        account: String = "authentication"
    ) {
        self.service = service
        self.account = account
    }

    func save(
        accessToken: String,
        refreshToken: String
    ) throws {
        let tokens = StoredTokens(
            accessToken: accessToken,
            refreshToken: refreshToken
        )

        let data = try JSONEncoder().encode(tokens)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        if updateStatus == errSecItemNotFound {
            var item = query
            attributes.forEach { key, value in
                item[key] = value
            }

            let addStatus = SecItemAdd(
                item as CFDictionary,
                nil
            )

            guard addStatus == errSecSuccess else {
                throw TokenStoreError.keychainError(
                    status: addStatus
                )
            }

            return
        }

        guard updateStatus == errSecSuccess else {
            throw TokenStoreError.keychainError(
                status: updateStatus
            )
        }
    }

    func load() throws -> StoredTokens? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw TokenStoreError.keychainError(
                status: status
            )
        }

        guard let data = result as? Data else {
            throw TokenStoreError.invalidStoredData
        }

        do {
            return try JSONDecoder().decode(
                StoredTokens.self,
                from: data
            )
        } catch {
            throw TokenStoreError.invalidStoredData
        }
    }

    func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(
            query as CFDictionary
        )

        guard status == errSecSuccess ||
              status == errSecItemNotFound else {
            throw TokenStoreError.keychainError(
                status: status
            )
        }
    }
}

enum TokenStoreError: Error, Sendable, Equatable {
    case keychainError(status: OSStatus)
    case invalidStoredData
}
