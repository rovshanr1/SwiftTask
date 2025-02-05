//
//  ProfileModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 04.02.25.
//

import Foundation

struct ProfileModel: Identifiable {
    let id = UUID()
    let userName: String
    let taskLeft: Int
    let taskDone: Int
    let email: String
}
