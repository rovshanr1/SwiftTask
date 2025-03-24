//
//  EmptySearchView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 24.03.25.
//

import SwiftUI


struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No matching tasks found")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}
