//
//  SwiftTaskUITests.swift
//  SwiftTaskUITests
//
//  Created by Rovshan Rasulov on 23.03.25.
//

import XCTest

final class SwiftTaskUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Stop immediately when a failure occurs
        continueAfterFailure = false
        
        // Set up UI testing environment
        app.launchArguments = ["UI-Testing"]
        app.launchEnvironment = [
            "UITESTING": "1",
            "animations": "0", // Disable animations during testing
            "DISABLE_ANIMATIONS": "true"
        ]
        
        // Launch the app
        app.launch()
        
        // Ensure the app is running in foreground
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10), "App should be running in foreground")
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Helper Methods
    private func waitForSplashScreenAndAnimation() {
        // Total wait time: animation duration (1.0s) + splash duration (2.5s) + transition (1.0s)
        let totalWaitTime: TimeInterval = 5.0
        sleep(UInt32(totalWaitTime))
    }
    
    private func waitForContentAnimation() {
        // Wait for content delay (0.5s) + animation duration (0.5s)
        let totalWaitTime: TimeInterval = 2.0
        sleep(UInt32(totalWaitTime))
    }
    
    private func skipOnboardingIfPresent() {
        print("\nChecking for onboarding...")
        
        // First check if onboarding is showing
        let onboardingView = app.otherElements["OnboardingView"]
        
        if onboardingView.exists {
            print("Onboarding found, proceeding with flow...")
            // Swipe through onboarding pages
            for i in 0..<3 {
                print("Swiping through page \(i)")
                app.swipeLeft()
                sleep(1)
            }
            
            print("Looking for Get Started button...")
            let getStartedButton = app.buttons["GetStartedButton"]
            if getStartedButton.exists {
                print("Found Get Started button, tapping...")
                getStartedButton.tap()
            } else {
                print("Get Started button not found!")
            }
            
            // Wait for transition animation
            sleep(1)
        } else {
            print("Onboarding not found!")
        }
    }
    
    private func verifyMainScreenElements() {
        print("\nVerifying main screen elements...")
        
        // First verify StartScreenView
        let startScreen = app.otherElements["StartScreenView"]
        XCTAssertTrue(startScreen.waitForExistence(timeout: 5), "StartScreenView should be visible")
        
        // First verify logo which should be immediately visible
        let logo = app.images["SwiftTaskLogo"]
        XCTAssertTrue(logo.waitForExistence(timeout: 5), "Logo should be visible")
        
        // Wait for content animation before checking other elements
        waitForContentAnimation()
        
        // Then verify animated content
        let elementsToVerify: [(element: XCUIElement, description: String)] = [
            (app.staticTexts["WelcomeText"], "Welcome text"),
            (app.staticTexts["DescriptionText"], "Description text"),
            (app.buttons["CreateAccountButton"], "Create account button"),
            (app.buttons["GuestButton"], "Guest button")
        ]
        
        for (element, description) in elementsToVerify {
            XCTAssertTrue(element.waitForExistence(timeout: 5), "\(description) should be visible")
            XCTAssertTrue(element.isHittable, "\(description) should be hittable")
        }
    }

    private func fillCreateAccountForm() {
        let usernameField = app.textFields["Enter your Username"]
        let emailField = app.textFields["Enter your Email"]
        let passwordField = app.secureTextFields["Enter your Password"]
        let confirmPasswordField = app.secureTextFields["Confirm your Password"]
        
        XCTAssertTrue(usernameField.waitForExistence(timeout: 5))
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        XCTAssertTrue(confirmPasswordField.waitForExistence(timeout: 5))
        
        usernameField.tap()
        usernameField.typeText("testuser")
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("Test123!")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("Test123!")
    }
    
    private func fillLoginForm() {
        let emailField = app.textFields["Enter your email"]
        let passwordField = app.secureTextFields["Enter your Password"]
        
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("Test123!")
    }

    // MARK: - Test Cases
    func testInitialLaunch() throws {
        print("\n=== Starting Initial Launch Test ===")
        
        // First verify LaunchView and logo
        sleep(2)
        print("\nLooking for LaunchView...")
        let launchView = app.otherElements["LaunchView"]
        
        // Print all available accessibility identifiers
        print("\nAvailable accessibility identifiers:")
        for element in app.otherElements.allElementsBoundByIndex {
            print("Element: \(element.debugDescription)")
            print("Identifier: \(element.identifier)")
        }
        
        // Try different queries
        let launchViewQuery = app.otherElements.matching(identifier: "LaunchView")
        print("DEBUG: LaunchView query count: \(launchViewQuery.count)")
        
        // Wait longer for LaunchView
        let exists = launchView.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "LaunchView should be visible")
        
        if !exists {
            // Print view hierarchy for debugging
            print("\nView hierarchy:")
            print(app.debugDescription)
            
            // Print all elements for debugging
            print("\nAll elements in hierarchy:")
            app.otherElements.allElementsBoundByIndex.forEach { element in
                print("Type: \(element.elementType)")
                print("Label: \(element.label)")
                print("Identifier: \(element.identifier)")
                print("Frame: \(element.frame)")
                print("---")
            }
        }
        
        print("\nLooking for LaunchView logo...")
        let launchLogo = app.images["SwiftTaskLogo"]
        XCTAssertTrue(launchLogo.waitForExistence(timeout: 10), "Logo should be visible in LaunchView")
        
        // Wait for splash screen and its animations
        waitForSplashScreenAndAnimation()
        
        // Skip onboarding if present
        skipOnboardingIfPresent()
        
        // Verify all main screen elements
        verifyMainScreenElements()
    }

    func testOnboardingFlow() throws {
        print("\n=== Starting Onboarding Flow Test ===")
        
        // Wait for splash screen
        waitForSplashScreenAndAnimation()
        
        // Verify onboarding view
        print("\nLooking for OnboardingView...")
        let onboardingView = app.otherElements["OnboardingView"]
        XCTAssertTrue(onboardingView.waitForExistence(timeout: 10), "Onboarding view should be visible")
        
        // Verify and interact with onboarding pages
        for i in 0..<3 {
            print("\nVerifying page \(i) elements...")
            // Verify page elements
            let image = app.images["OnboardingImage\(i)"]
            let title = app.staticTexts["OnboardingTitle\(i)"]
            let description = app.staticTexts["OnboardingDescription\(i)"]
            
            XCTAssertTrue(image.exists, "Onboarding image \(i) should be visible")
            XCTAssertTrue(title.exists, "Onboarding title \(i) should be visible")
            XCTAssertTrue(description.exists, "Onboarding description \(i) should be visible")
            
            if i < 2 {
                print("Swiping to next page...")
                app.swipeLeft()
                sleep(1)
            }
        }
        
        // Tap Get Started button
        print("\nLooking for Get Started button...")
        let getStartedButton = app.buttons["GetStartedButton"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 5), "Get Started button should be visible")
        getStartedButton.tap()
        
        // Wait for transition and verify main screen
        sleep(1)
        verifyMainScreenElements()
    }
    
    func testCreateAccountNavigation() throws {
        // Wait for initial animations
        waitForSplashScreenAndAnimation()
        skipOnboardingIfPresent()
        waitForContentAnimation()
        
        // Navigate to create account
        let createAccountButton = app.buttons["CreateAccountButton"]
        XCTAssertTrue(createAccountButton.waitForExistence(timeout: 5), "Create account button should be visible")
        createAccountButton.tap()
        
        // Wait for transition and verify
        sleep(1)
        let createAccountView = app.otherElements["CreateAccountView"]
        XCTAssertTrue(createAccountView.waitForExistence(timeout: 5), "Create account view should be visible")
        
        // Fill form
        fillCreateAccountForm()
        
        // Accept terms and conditions
        let termsToggle = app.switches.firstMatch
        let privacyToggle = app.switches.element(boundBy: 1)
        
        termsToggle.tap()
        privacyToggle.tap()
        
        // Tap register button
        let registerButton = app.buttons["Register"]
        XCTAssertTrue(registerButton.waitForExistence(timeout: 5))
        registerButton.tap()
        
        // Wait for registration process
        sleep(2)
    }
    
    func testLoginFlow() throws {
        // Wait for initial animations
        waitForSplashScreenAndAnimation()
        skipOnboardingIfPresent()
        waitForContentAnimation()
        
        // Navigate to create account first
        let createAccountButton = app.buttons["CreateAccountButton"]
        XCTAssertTrue(createAccountButton.waitForExistence(timeout: 5))
        createAccountButton.tap()
        
        // Wait for transition
        sleep(1)
        
        // Navigate to login
        let loginLink = app.buttons["Already have an account? Log in"]
        XCTAssertTrue(loginLink.waitForExistence(timeout: 5))
        loginLink.tap()
        
        // Wait for transition
        sleep(1)
        
        // Fill login form
        fillLoginForm()
        
        // Tap login button
        let loginButton = app.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        // Wait for login process
        sleep(2)
    }
    
    func testForgotPasswordFlow() throws {
        // Navigate to login screen first
        try testLoginFlow()
        
        // Tap forgot password button
        let forgotPasswordButton = app.buttons["Forgot Password?"]
        XCTAssertTrue(forgotPasswordButton.waitForExistence(timeout: 5))
        forgotPasswordButton.tap()
        
        // Wait for sheet to appear
        sleep(1)
        
        // Fill email field
        let emailField = app.textFields["Enter your email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("test@example.com")
        
        // Tap reset button
        let resetButton = app.buttons["Reset Password"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 5))
        resetButton.tap()
        
        // Wait for reset process
        sleep(2)
    }
    
    func testGuestModeNavigation() throws {
        // Wait for initial animations
        waitForSplashScreenAndAnimation()
        skipOnboardingIfPresent()
        waitForContentAnimation()
        
        // Navigate to guest mode
        let guestButton = app.buttons["GuestButton"]
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5), "Guest button should be visible")
        guestButton.tap()
        
        // Wait for transition and verify
        sleep(1)
        let guestView = app.otherElements["GuestView"]
        XCTAssertTrue(guestView.waitForExistence(timeout: 5), "Guest view should be visible")
        
        // Verify guest mode elements
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.exists, "Back button should be visible")
        
        let limitedModeTitle = app.staticTexts["Sınırlı Kullanım Modu"]
        XCTAssertTrue(limitedModeTitle.exists, "Limited mode title should be visible")
        
        let loginButton = app.buttons["Giriş Yap"]
        XCTAssertTrue(loginButton.exists, "Login button should be visible")
        
        // Test adding a task
        let addButton = app.buttons["Add New Task"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // Wait for sheet to appear
        sleep(1)
        
        // Fill task details
        let titleField = app.textFields["Task Title"]
        let descriptionField = app.textFields["Task Description"]
        
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        XCTAssertTrue(descriptionField.waitForExistence(timeout: 5))
        
        titleField.tap()
        titleField.typeText("Test Task")
        
        descriptionField.tap()
        descriptionField.typeText("Test Description")
        
        // Save task
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
        
        // Wait for save process
        sleep(1)
        
        // Verify task was added
        let taskTitle = app.staticTexts["Test Task"]
        XCTAssertTrue(taskTitle.waitForExistence(timeout: 5))
        
        // Test navigation back to intro
        backButton.tap()
        sleep(1)
        
        // Verify we're back at intro view
        let introView = app.otherElements["StartScreenView"]
        XCTAssertTrue(introView.waitForExistence(timeout: 5), "Should return to intro view")
    }
    
    func testAccessibility() throws {
        // Wait for all animations
        waitForSplashScreenAndAnimation()
        skipOnboardingIfPresent()
        waitForContentAnimation()
        
        // Verify logo accessibility
        let logo = app.images["SwiftTaskLogo"]
        XCTAssertTrue(logo.waitForExistence(timeout: 5), "Logo should be visible")
        XCTAssertTrue(logo.isEnabled, "Logo should be accessible")
        
        // Verify buttons accessibility
        let createAccountButton = app.buttons["CreateAccountButton"]
        let guestButton = app.buttons["GuestButton"]
        
        XCTAssertTrue(createAccountButton.waitForExistence(timeout: 5), "Create account button should be visible")
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5), "Guest button should be visible")
        
        XCTAssertTrue(createAccountButton.isEnabled, "Create account button should be accessible")
        XCTAssertTrue(guestButton.isEnabled, "Guest button should be accessible")
        
        // Test VoiceOver labels
        XCTAssertNotNil(logo.value as? String, "Logo should have accessibility label")
        XCTAssertNotNil(createAccountButton.value as? String, "Create account button should have accessibility label")
        XCTAssertNotNil(guestButton.value as? String, "Guest button should have accessibility label")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            let options = XCTMeasureOptions()
            options.iterationCount = 5
            
            measure(
                metrics: [
                    XCTApplicationLaunchMetric(waitUntilResponsive: true),
                    XCTMemoryMetric(),
                    XCTCPUMetric()
                ],
                options: options
            ) {
                let app = XCUIApplication()
                app.launch()
                
                // Wait for all animations to complete
                sleep(7) // Total animation duration
                
                // Verify final state
                let startScreen = app.otherElements["StartScreenView"]
                XCTAssertTrue(startScreen.waitForExistence(timeout: 5))
                
                app.terminate()
            }
        }
    }
}
