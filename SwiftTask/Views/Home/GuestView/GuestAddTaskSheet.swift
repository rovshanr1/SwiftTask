import SwiftUI

struct GuestAddTaskSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Form Fields
                    VStack(spacing: 20) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            TextField("", text: $title)
                                .placeholder(when: title.isEmpty) {
                                    Text("Enter task title")
                                        .foregroundColor(.gray)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(15)
                        }
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            TextField("", text: $description)
                                .placeholder(when: description.isEmpty) {
                                    Text("Add task description (optional)")
                                        .foregroundColor(.gray)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            onSave()
                            isPresented = false
                        }) {
                            Text("Add Task")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .foregroundStyle(.white)
                                .background(Color.customGradient)
                                .cornerRadius(15)
                        }
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Cancel")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.customAccent, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add New Task")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
