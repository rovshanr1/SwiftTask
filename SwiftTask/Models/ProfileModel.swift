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
    var taskLeft: Int
    var taskDone: Int
    let email: String
}
