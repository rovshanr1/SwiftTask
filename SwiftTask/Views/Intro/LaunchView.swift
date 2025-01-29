//
//  LaunchView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 25.01.25.
//

import SwiftUI

struct LaunchView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var isMainScreenActive: Bool = false
    
    var body: some View {
        if isMainScreenActive {
            IntroView()
        } else {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                VStack {
                    Image("appIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0)) {
                                logoScale = 1.0
                                logoOpacity = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isMainScreenActive = true
                                }
                            }
                        }
                }
            }
        }
    }
}


#Preview {
    LaunchView()
}
