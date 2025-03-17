//
//  IntroView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 26.01.25.
//

import SwiftUI

struct IntroView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("isOnboardingSheetShowing") var isOnboardingSheetShowing = true
    
    @State private var showHomeScreen = false
    @State private var showRegisterScreen = false
    @State private var showLoginScreen: Bool = false
    @State private var showGuestScreen: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
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
            else if showGuestScreen {
                GuestView()
            }
            else if showRegisterScreen {
                CreateAccountView(loginviewModel: loginViewModel, showRegisterScreen: $showRegisterScreen, showLoginScreen: $showLoginScreen)
            }
           else {
               StartScreenView(showHomeScreen: $showHomeScreen, showRegisterScreen: $showRegisterScreen, showGuestScreen: $showGuestScreen)
            }
        }
        .animation(.easeInOut, value: isOnboardingSheetShowing)
    }
}

struct StartScreenView: View {
    @Binding var showHomeScreen: Bool
    @Binding var showRegisterScreen: Bool
    @Binding var showGuestScreen: Bool
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            VStack() {
                VStack(spacing: 28){
                    Text("Welcome to SwiftTask")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("To access all features, please log in or create an account.")
                        .font(.system(size: 17, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                Spacer()
                VStack(spacing: 28) {
                    
                    Button(action: {
                        showRegisterScreen = true
                    }){
                        Text("Create New Account")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                            .cornerRadius(10)
                    }
                                        
                    Button(action: {
                        showGuestScreen = true
                    }){
                        Text("Continue as Guest")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 1.00, green: 0.44, blue: 0.14), lineWidth: 2)
                            )
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
    }
}

//#Preview {
//    IntroView()
//}
