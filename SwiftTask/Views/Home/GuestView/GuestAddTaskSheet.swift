import SwiftUI

struct GuestAddTaskSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    var onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Quick Task")
                .font(.title2)
                .bold()
                .foregroundStyle(.white)
            
            Divider().background(Color.gray)
                .padding(8)
            
            TextField("Task title", text: $title, prompt: Text("Enter task title").foregroundStyle(.gray))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .padding(.horizontal)
            
            TextField("Description (optional)", text: $description, prompt: Text("Add a short description").foregroundStyle(.gray))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                
                Button(action: {
                    onSave()
                    isPresented = false
                }) {
                    Text("Add Task")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 20)
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .presentationDetents([.height(300)])
    }
} 