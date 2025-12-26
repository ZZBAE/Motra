//
//  AppleSignInService.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/19/25.
//

import Foundation
import AuthenticationServices

// MARK: - Apple Sign In Result
struct AppleSignInResult {
    let userIdentifier: String
    let email: String?
    let fullName: PersonNameComponents?
    let identityToken: String?
    let authorizationCode: String?
    
    var firstName: String? {
        fullName?.givenName
    }
    
    var lastName: String? {
        fullName?.familyName
    }
    
    var displayName: String? {
        if let firstName = firstName, let lastName = lastName {
            return "\(lastName)\(firstName)" // 한국식 이름 순서
        }
        return firstName ?? lastName
    }
}

// MARK: - Apple Sign In Error
enum AppleSignInError: LocalizedError {
    case invalidCredential
    case tokenEncodingFailed
    case authorizationFailed(Error)
    case cancelled
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "유효하지 않은 인증 정보입니다."
        case .tokenEncodingFailed:
            return "토큰 인코딩에 실패했습니다."
        case .authorizationFailed(let error):
            return "인증 실패: \(error.localizedDescription)"
        case .cancelled:
            return "로그인이 취소되었습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

// MARK: - Apple Sign In Service
final class AppleSignInService: NSObject {
    
    private var continuation: CheckedContinuation<AppleSignInResult, Error>?
    
    /// Apple 로그인 요청
    @MainActor
    func signIn() async throws -> AppleSignInResult {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    /// 기존 로그인 상태 확인
    func checkCredentialState(userIdentifier: String) async -> ASAuthorizationAppleIDProvider.CredentialState {
        await withCheckedContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userIdentifier) { state, _ in
                continuation.resume(returning: state)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInService: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AppleSignInError.invalidCredential)
            continuation = nil
            return
        }
        
        let identityToken: String? = {
            guard let tokenData = credential.identityToken else { return nil }
            return String(data: tokenData, encoding: .utf8)
        }()
        
        let authorizationCode: String? = {
            guard let codeData = credential.authorizationCode else { return nil }
            return String(data: codeData, encoding: .utf8)
        }()
        
        let result = AppleSignInResult(
            userIdentifier: credential.user,
            email: credential.email,
            fullName: credential.fullName,
            identityToken: identityToken,
            authorizationCode: authorizationCode
        )
        
        continuation?.resume(returning: result)
        continuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let signInError: AppleSignInError
        
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                signInError = .cancelled
            case .invalidResponse, .notHandled, .failed:
                signInError = .authorizationFailed(error)
            case .unknown:
                signInError = .unknown
            case .notInteractive:
                signInError = .authorizationFailed(error)
            @unknown default:
                signInError = .unknown
            }
        } else {
            signInError = .authorizationFailed(error)
        }
        
        continuation?.resume(throwing: signInError)
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
