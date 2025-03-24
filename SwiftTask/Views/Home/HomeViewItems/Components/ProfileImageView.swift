//
//  ProfileImageView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 24.03.25.
//

import SwiftUI

struct ProfileImageView: View {
    let imageData: Data?
    
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 42, height: 42)
                .foregroundColor(.gray)
        }
    }
}

