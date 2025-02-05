//
//  TabBarView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 04.02.25.
//
import SwiftUI

struct TabBarView: View {
    @Binding var navigateToHome: Bool
    @Binding var navigateToProfile: Bool
    var onAddTask: () -> Void

    var body: some View {
        ZStack {
            HStack {
                HStack(spacing: 50) {
                    Button(action: {
                        navigateToHome = true
                    }) {
                        Image(systemName: "house")
                            .foregroundStyle(.white)
                    }
                    Button(action: {}) {
                        Image(systemName: "calendar")
                            .foregroundStyle(.white)
                    }
                }
                .padding(.leading, 20)
                Spacer()
                HStack(spacing: 50) {
                    Button(action: {}) {
                        Image(systemName: "clock")
                            .foregroundStyle(.white)
                    }
                    Button(action: {
                        navigateToProfile = true
                    }) {
                        Image(systemName: "person")
                            .foregroundStyle(.white)
                    }
                }
                .padding(.trailing, 20)
            }
            .frame(height: 70)
            .background(Color(red: 0.21, green: 0.21, blue: 0.21).opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 16)

            Button(action: onAddTask) {
                Circle()
                    .frame(width: 64, height: 64)
                    .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                    .overlay(Image(systemName: "plus").font(.system(size: 32, weight: .bold)).foregroundColor(.white))
            }
            .offset(y: -30)
        }
    }
}

