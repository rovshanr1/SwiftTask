//
//  IntroView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 26.01.25.
//

import SwiftUI

// MARK: - Custom Colors Extension
extension Color {
    static let customBackground = Color(red: 0.07, green: 0.07, blue: 0.07)
    static let customAccent = Color(red: 1.00, green: 0.44, blue: 0.14)
    static let customGradient = LinearGradient(
        gradient: Gradient(colors: [Color.customAccent, Color(red: 0.29, green: 0.29, blue: 0.51)]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - IntroView
/// The main entry point view that handles the app's introduction flow
/// Manages onboarding, authentication, and initial navigation states
struct IntroView: View {
    // MARK: - View Model Properties
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var viewModel = OnboardingViewModel()
    
    // MARK: - App Storage
    @AppStorage("isOnboardingSheetShowing") var isOnboardingSheetShowing = true
    
    // MARK: - View States
    @State private var showContent = false
    @State private var showHomeScreen = false
    @State private var showRegisterScreen = false
    @State private var showLoginScreen: Bool = false
    @State private var showGuestScreen: Bool = false
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.customBackground
                .ignoresSafeArea()
            
            if isOnboardingSheetShowing {
                OnboardingView(viewModel: viewModel) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isOnboardingSheetShowing = false
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityIdentifier("OnboardingView")
            }
            else if showGuestScreen {
                GuestView()
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityIdentifier("GuestView")
            }
            else if showRegisterScreen {
                CreateAccountView(loginviewModel: loginViewModel,
                                showRegisterScreen: $showRegisterScreen,
                                showLoginScreen: $showLoginScreen)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .accessibilityIdentifier("CreateAccountView")
            }
            else {
                StartScreenView(showHomeScreen: $showHomeScreen,
                              showRegisterScreen: $showRegisterScreen,
                              showGuestScreen: $showGuestScreen,
                              showContent: $showContent)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityIdentifier("StartScreenView")
                    .onAppear {
                        // Delay the appearance of content for smooth animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeIn(duration: 0.5)) {
                                showContent = true
                            }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isOnboardingSheetShowing)
    }
}

// MARK: - StartScreenView
/// The initial view shown to users when they first open the app
/// Provides options for account creation and guest access
struct StartScreenView: View {
    // MARK: - Binding Properties
    @Binding var showHomeScreen: Bool
    @Binding var showRegisterScreen: Bool
    @Binding var showGuestScreen: Bool
    @Binding var showContent: Bool
    
    // MARK: - Constants
    private let backgroundColors = Color(red: 0.07, green: 0.07, blue: 0.07)
    private let accentColor = Color(red: 1.00, green: 0.44, blue: 0.14)
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Logo and Welcome Section
                    VStack(spacing: 25) {
                        Image("SwiftTaskLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.7)
                            .shadow(color: .customAccent.opacity(0.3), radius: 10)
                        
                        if showContent {
                            welcomeTextSection
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.top, geometry.size.height * 0.1)
                    
                    Spacer()
                    
                    if showContent {
                        actionButtonsSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - View Components
    
    /// Welcome text section with title and description
    private var welcomeTextSection: some View {
        VStack(spacing: 16) {
            Text("Welcome to SwiftTask")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("Your personal task management solution for enhanced productivity and organization")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    /// Action buttons for account creation and guest access
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                withAnimation(.spring()) {
                    showRegisterScreen = true
                }
            }) {
                HStack {
                    Text("Get Started")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .foregroundStyle(.white)
                .background(Color.customGradient)
                .cornerRadius(15)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    showGuestScreen = true
                }
            }) {
                Text("Continue as Guest")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.customAccent, lineWidth: 2)
                    )
            }
        }
    }
}






