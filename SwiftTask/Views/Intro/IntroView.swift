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
    @State private var showContent = false
    
    @State private var showHomeScreen = false
    @State private var showRegisterScreen = false
    @State private var showLoginScreen: Bool = false
    @State private var showGuestScreen: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack {
            if isOnboardingSheetShowing {
                OnboardingView(viewModel: viewModel) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isOnboardingSheetShowing = false
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityIdentifier("OnboardingView")
            }
            else if showGuestScreen {
                GuestView()
                    .transition(.opacity)
                    .accessibilityIdentifier("GuestView")
            }
            else if showRegisterScreen {
                CreateAccountView(loginviewModel: loginViewModel, showRegisterScreen: $showRegisterScreen, showLoginScreen: $showLoginScreen)
                    .transition(.opacity)
                    .accessibilityIdentifier("CreateAccountView")
            }
            else {
                StartScreenView(showHomeScreen: $showHomeScreen, 
                              showRegisterScreen: $showRegisterScreen, 
                              showGuestScreen: $showGuestScreen,
                              showContent: $showContent)
                    .transition(.opacity)
                    .accessibilityIdentifier("StartScreenView")
                    .onAppear {
                        // Delay the appearance of content
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeIn(duration: 0.5)) {
                                showContent = true
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isOnboardingSheetShowing)
    }
}

struct StartScreenView: View {
    @Binding var showHomeScreen: Bool
    @Binding var showRegisterScreen: Bool
    @Binding var showGuestScreen: Bool
    @Binding var showContent: Bool
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            
            VStack() {
                VStack(spacing: 20) {
                    Image("SwiftTaskLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .accessibilityIdentifier("SwiftTaskLogo")
                    
                    if showContent {
                        Text("Welcome to SwiftTask")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .accessibilityIdentifier("WelcomeText")
                            .transition(.opacity)
                        
                        Text("To access all features, please log in or create an account.")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .accessibilityIdentifier("DescriptionText")
                            .transition(.opacity)
                    }
                }
                
                Spacer()
                
                if showContent {
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
                        .accessibilityIdentifier("CreateAccountButton")
                        .transition(.opacity)
                        
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
                        .accessibilityIdentifier("GuestButton")
                        .transition(.opacity)
                    }
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
        .accessibilityIdentifier("StartScreenView")
    }
}

#if DEBUG
struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
#endif
