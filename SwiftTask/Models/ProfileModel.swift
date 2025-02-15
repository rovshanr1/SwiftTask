//
//  ProfileModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 04.02.25.
//

import Foundation

struct ProfileModel: Identifiable {
    var id = UUID()
    var userName: String
    var taskLeft: Int
    var taskDone: Int
    var email: String
    var timestamp: Date
}
