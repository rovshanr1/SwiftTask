//
//  TaskSummaryCard.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 24.03.25.
//

import SwiftUI

struct TaskSummaryCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
        .cornerRadius(12)
    }
}


