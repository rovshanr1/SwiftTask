import SwiftUI

struct AddTaskSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    var onSave: () -> Void
    
    var body: some View {
        ZStack{
            Color(red: 0.21, green: 0.21, blue: 0.21)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Add Task")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                TextField("Task title", text: $title)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.gray), lineWidth: 2)
                    )
                
                TextField("Description", text: $description)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.gray), lineWidth: 2)
                    )
                
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        onSave()
                        isPresented = false
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(red: 0.21, green: 0.21, blue: 0.21))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .presentationDetents([.medium, .large])
        }
    }
}
 

