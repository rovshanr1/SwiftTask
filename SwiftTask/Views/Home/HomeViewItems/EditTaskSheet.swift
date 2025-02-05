//
//  EditTask.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 03.02.25.
//

import SwiftUI

struct EditTaskSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    var onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(red: 0.21, green: 0.21, blue: 0.21)
                    .ignoresSafeArea()
                VStack{
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Edit Task")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.white)
                        TextField("Task title", text: $title, prompt: Text("TextTitle").foregroundStyle(.gray))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.gray), lineWidth: 2)
                            )
                        
                        TextField("Description", text: $description, prompt: Text("Description").foregroundStyle(.gray))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.gray), lineWidth: 2)
                            )
                        Spacer()
                    }
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .presentationDetents([.medium, .large])
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") { onSave() }
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}
