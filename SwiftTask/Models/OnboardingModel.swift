//
//  OnboardingModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 26.01.25.
//

import Foundation

struct OnboardingModel: Identifiable{
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let isLast: Bool
}
