//
//  LoginView.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/19/25.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showSignUp: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 60)
                        
                        // 로고 섹션
                        logoSection
                            .padding(.bottom, 50)
                        
                        // 로그인 폼
                        loginForm
                            .padding(.horizontal, 24)
                        
                        Spacer()
                            .frame(height: 30)
                        
                        // 회원가입 링크
                        signUpLink
                            .padding(.bottom, 50)
                    }
                }
                
                // 로딩 오버레이
                if authViewModel.isLoading {
                    loadingOverlay
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(authViewModel: authViewModel)
            }
            .alert("로그인 오류", isPresented: .constant(authViewModel.errorMessage != nil)) {
                Button("확인") {
                    authViewModel.clearError()
                }
            } message: {
                Text(authViewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundStyle(.blue.gradient)
            
            Text("Motra")
                .font(.system(size: 42, weight: .bold, design: .rounded))
            
            Text("나만의 운동 기록을 시작하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 16) {
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
            
            // 로그인 버튼
            Button {
                Task {
                    await authViewModel.signIn(email: email, password: password)
                }
            } label: {
                Text("로그인")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Sign Up Link
    private var signUpLink: some View {
        HStack(spacing: 4) {
            Text("아직 계정이 없으신가요?")
                .foregroundStyle(.secondary)
            
            Button("회원가입") {
                showSignUp = true
            }
            .fontWeight(.semibold)
        }
        .font(.subheadline)
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
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel())
}
