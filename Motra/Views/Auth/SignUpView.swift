//
//  SignUpView.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/19/25.
//

import SwiftUI

struct SignUpView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var nickname: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // 헤더
                    headerSection
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    
                    // 회원가입 폼
                    signUpForm
                        .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
            
            // 로딩 오버레이
            if authViewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("회원가입 오류", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("확인") {
                authViewModel.clearError()
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundStyle(.blue.gradient)
            
            Text("회원가입")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Motra와 함께 운동을 기록하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Sign Up Form
    private var signUpForm: some View {
        VStack(spacing: 16) {
            // 닉네임 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("닉네임")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TextField("사용할 닉네임", text: $nickname)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .autocorrectionDisabled()
            }
            
            // 이메일 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("이메일")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TextField("example@email.com", text: $email)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }
            
            // 비밀번호 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("비밀번호")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    if showPassword {
                        TextField("6자 이상", text: $password)
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("6자 이상", text: $password)
                            .textFieldStyle(.plain)
                    }
                    
                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // 비밀번호 확인
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("비밀번호 확인")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if !confirmPassword.isEmpty {
                        if passwordsMatch {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                HStack {
                    if showConfirmPassword {
                        TextField("비밀번호 재입력", text: $confirmPassword)
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("비밀번호 재입력", text: $confirmPassword)
                            .textFieldStyle(.plain)
                    }
                    
                    Button {
                        showConfirmPassword.toggle()
                    } label: {
                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // 회원가입 버튼
            Button {
                Task {
                    await authViewModel.signUp(email: email, password: password, nickname: nickname)
                }
            } label: {
                Text("회원가입")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .padding(.top, 8)
            
            // 약관 안내
            Text("회원가입 시 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
        }
    }
    
    // MARK: - Computed Properties
    private var passwordsMatch: Bool {
        password == confirmPassword && !password.isEmpty
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !nickname.isEmpty && 
        passwordsMatch &&
        password.count >= 6
    }
}

#Preview {
    NavigationStack {
        SignUpView(authViewModel: AuthViewModel())
    }
}
