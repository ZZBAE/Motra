//
//  AuthViewModel.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/19/25.
//

import Foundation
import SwiftUI

// MARK: - Auth State
enum AuthState: Equatable {
    case unknown      // 초기 상태, 인증 상태 확인 중
    case signedOut    // 로그아웃 상태
    case signedIn     // 로그인 완료
}

// MARK: - Auth ViewModel
@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var currentUser: User?
    
    // MARK: - Dependencies
    private let authService = LocalAuthService.shared
    
    // MARK: - Initialization
    init() {
        checkAuthState()
    }
    
    // MARK: - Public Methods
    
    /// 앱 시작 시 인증 상태 확인
    func checkAuthState() {
        if let user = authService.getCurrentUser() {
            currentUser = user
            authState = .signedIn
        } else {
            authState = .signedOut
        }
    }
    
    /// 이메일/비밀번호 회원가입
    func signUp(email: String, password: String, nickname: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try authService.signUp(email: email, password: password, nickname: nickname)
            currentUser = user
            authState = .signedIn
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "회원가입 중 오류가 발생했습니다."
        }
        
        isLoading = false
    }
    
    /// 이메일/비밀번호 로그인
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try authService.signIn(email: email, password: password)
            currentUser = user
            authState = .signedIn
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "로그인 중 오류가 발생했습니다."
        }
        
        isLoading = false
    }
    
    /// 로그아웃
    func signOut() {
        authService.signOut()
        currentUser = nil
        authState = .signedOut
    }
    
    /// 회원탈퇴
    func deleteAccount() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try authService.deleteAccount()
            currentUser = nil
            authState = .signedOut
            isLoading = false
            return true
        } catch {
            errorMessage = "회원탈퇴 중 오류가 발생했습니다."
            isLoading = false
            return false
        }
    }
    
    /// 에러 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
}
