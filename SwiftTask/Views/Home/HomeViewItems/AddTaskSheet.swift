import SwiftUI

struct AddTaskSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    var onSave: () -> Void
    
    var body: some View {
            
            VStack(spacing: 20) {
                Text("Add Task")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                
                Divider().background(Color.gray)
                    .padding(8)
                
                TextField("Task title", text: $title, prompt: Text("TextTitle").foregroundStyle(.gray))
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 352, height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                        )
                
                TextField("Description", text: $description, prompt: Text("Description").foregroundStyle(.gray))
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 352, height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                        )
                
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                            .frame(width: 153, height: 48)
                    }
                    
                    Button(action: {
                        onSave()
                        isPresented = false
                    }) {
                        Text("Save")
                            .foregroundStyle(.white)
                            .frame(width: 153, height: 48)
                            .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                            .cornerRadius(5)
                    }
                    .padding(.horizontal)
                }
                
            }
            .cornerRadius(15)
            .padding()
            .presentationDetents([.medium, .large])
        }
    }


