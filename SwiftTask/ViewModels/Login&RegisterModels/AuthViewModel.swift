//
//  AuthViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 31.01.25.
//

import SwiftUI


class AutAuthViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    func login() {
        isLoggedIn = true
    }
    func logout() {
        isLoggedIn = false
    }
}
