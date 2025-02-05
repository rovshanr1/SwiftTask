//
//  OnboardingViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 26.01.25.
//

import Foundation


class OnboardingViewModel: ObservableObject {
    @Published var isOnboardingItems: [OnboardingModel] = [
        OnboardingModel(imageName: "Frame 160", title: "Manage your tasks", description: "You can easily manage all of your daily tasks in DoMe for free", isLast: false),
        OnboardingModel(imageName: "Frame 161", title: "Create daily routine", description: "In SwiftTask you can create your personalized routine to stay productive", isLast: false),
        OnboardingModel(imageName: "Frame 162", title: "Organize your tasks", description: "You can organize your daily tasks by adding your tasks into separate categories", isLast: true)
    ]
    
}
