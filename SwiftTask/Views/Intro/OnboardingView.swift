//
//  OnboardingView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 26.01.25.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onFinish: () -> Void

    @State private var currentPage: Int = 0
    
    var body: some View {
        VStack{
            TabView(selection: $currentPage){
                ForEach(0..<viewModel.isOnboardingItems.count, id: \.self) { index in
                    
                    let item = viewModel.isOnboardingItems[index]
                    VStack(spacing: 20){
                        Image(item.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        Text(item.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text(item.description)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        if index == viewModel.isOnboardingItems.count - 1 {
                            Button("Get Started"){
                                onFinish()
                            }
                            .frame(width: 200, height: 44)
                            .foregroundColor(.white)
                            .background(Color(red: 0.53, green: 0.53, blue: 0.91))
                            .cornerRadius(10)
                            .padding(.top, 20)
                                     }
                    }
                    .tag(index)
                    
                }
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .background(Color(red: 0.07, green: 0.07, blue: 0.07).ignoresSafeArea())
        }
    }
}



