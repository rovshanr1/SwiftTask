//
//  EmptyTaskView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 24.03.25.
//

import SwiftUI

struct EmptyTaskView: View {
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text("What do you want to do today?")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white)
                Text("Tap + to add your tasks")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
}

