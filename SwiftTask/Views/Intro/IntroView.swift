//
//  IntroView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 26.01.25.
//

import SwiftUI

struct IntroView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("isOnboardingSheetShowing") var isOnboardingSheetShowing = true
    
    @State private var showLoginScreen = false
    @State private var showRegisterScreen = false
    var body: some View {
        ZStack {
            if isOnboardingSheetShowing {
                OnboardingView(viewModel: viewModel) {
                    withAnimation {
                        isOnboardingSheetShowing = false
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            else if showLoginScreen {
                LoginView(showLoginScreen: $showLoginScreen)
            }
            else if showRegisterScreen {
                CreateAccountView(showRegisterScreen: $showRegisterScreen)
            }
           else {
               StartScreenView(showLoginScreen: $showLoginScreen, showRegisterScreen: $showRegisterScreen)
            }
        }
        .animation(.easeInOut, value: isOnboardingSheetShowing)
    }
}

struct StartScreenView: View {
    @Binding var showLoginScreen: Bool
    @Binding var showRegisterScreen: Bool
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Welcome to SwiftTask")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Please login to your account or create a new account to continue.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                VStack(spacing: 30) {
                    Button(action: {
                        print("Login pressed")
                        showLoginScreen = true
                    }){
                        Text("Create Account")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                    .cornerRadius(10)
                    
                    Button(action: {
                        print("Create account pressed")
                        showRegisterScreen = true
                    }){
                        Text("Create Account")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 1.00, green: 0.44, blue: 0.14), lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    IntroView()
}
