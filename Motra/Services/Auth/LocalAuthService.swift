//
//  LocalAuthService.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/19/25.
//

import Foundation
import CryptoKit

// MARK: - Auth Error
enum AuthError: LocalizedError {
    case emailAlreadyExists
    case invalidCredentials
    case userNotFound
    case invalidEmail
    case weakPassword
    case emptyFields
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyExists:
            return "이미 가입된 이메일입니다."
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case .userNotFound:
            return "등록되지 않은 사용자입니다."
        case .invalidEmail:
            return "올바른 이메일 형식이 아닙니다."
        case .weakPassword:
            return "비밀번호는 6자 이상이어야 합니다."
        case .emptyFields:
            return "모든 필드를 입력해주세요."
        }
    }
}

// MARK: - Local Auth Service
/// 로컬 인증 서비스 (서버 연동 전 임시 사용)
/// TODO: 서버 구현 후 APIAuthService로 교체
final class LocalAuthService {
    
    static let shared = LocalAuthService()
    
    private let usersKey = "registered_users"
    private let currentUserKey = "current_user_id"
    
    private init() {}
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, nickname: String) throws -> User {
        // 유효성 검사
        guard !email.isEmpty, !password.isEmpty, !nickname.isEmpty else {
            throw AuthError.emptyFields
        }
        
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        // 중복 이메일 확인
        var users = loadUsers()
        if users.contains(where: { $0.value.user.email == email }) {
            throw AuthError.emailAlreadyExists
        }
        
        // 새 사용자 생성
        let user = User(email: email, nickname: nickname)
        let hashedPassword = hashPassword(password)
        
        // 저장
        users[user.id] = StoredUser(user: user, passwordHash: hashedPassword)
        saveUsers(users)
        
        // 현재 사용자로 설정
        setCurrentUser(user)
        
        print("✅ 회원가입 성공: \(user.email)")
        return user
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) throws -> User {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.emptyFields
        }
        
        let users = loadUsers()
        
        guard let storedUser = users.values.first(where: { $0.user.email == email }) else {
            throw AuthError.userNotFound
        }
        
        let hashedPassword = hashPassword(password)
        guard storedUser.passwordHash == hashedPassword else {
            throw AuthError.invalidCredentials
        }
        
        // 현재 사용자로 설정
        setCurrentUser(storedUser.user)
        
        print("✅ 로그인 성공: \(storedUser.user.email)")
        return storedUser.user
    }
    
    // MARK: - Sign Out
    func signOut() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        KeychainService.shared.clearAll()
        print("ℹ️ 로그아웃 완료")
    }
    
    // MARK: - Delete Account
    func deleteAccount() throws {
        guard let userId = UserDefaults.standard.string(forKey: currentUserKey) else {
            throw AuthError.userNotFound
        }
        
        // 사용자 목록에서 제거
        var users = loadUsers()
        users.removeValue(forKey: userId)
        saveUsers(users)
        
        // 로그아웃 처리
        signOut()
        
        print("✅ 회원탈퇴 완료")
    }
    
    // MARK: - Get Current User
    func getCurrentUser() -> User? {
        guard let userId = UserDefaults.standard.string(forKey: currentUserKey) else {
            return nil
        }
        
        let users = loadUsers()
        return users[userId]?.user
    }
    
    // MARK: - Private Helpers
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func setCurrentUser(_ user: User) {
        UserDefaults.standard.set(user.id, forKey: currentUserKey)
        _ = KeychainService.shared.save(user.id, for: .userIdentifier)
    }
    
    // MARK: - Storage
    
    private struct StoredUser: Codable {
        let user: User
        let passwordHash: String
    }
    
    private func loadUsers() -> [String: StoredUser] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([String: StoredUser].self, from: data) else {
            return [:]
        }
        return users
    }
    
    private func saveUsers(_ users: [String: StoredUser]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
}
