//
//  KeychainService.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/19/25.
//

import Foundation
import Security

/// Keychain을 사용한 안전한 데이터 저장 서비스
final class KeychainService {
    
    static let shared = KeychainService()
    
    private let service = "com.motra.auth"
    
    private init() {}
    
    // MARK: - Keys
    enum Key: String {
        case userIdentifier = "apple_user_identifier"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
    
    // MARK: - Save
    func save(_ value: String, for key: Key) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // 기존 항목 삭제
        delete(key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Load
    func load(_ key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    // MARK: - Delete
    @discardableResult
    func delete(_ key: Key) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Clear All
    func clearAll() {
        Key.allCases.forEach { delete($0) }
    }
}

// MARK: - Key CaseIterable
extension KeychainService.Key: CaseIterable {}
