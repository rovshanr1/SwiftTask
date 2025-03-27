import SwiftUI


struct AddTaskSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    @Binding var selectedCategory: TaskCategory?
    @Binding var selectedPriority: TaskPriority?
    @State private var showAllCategories = false
    var onSave: () -> Void
    
    private let mainCategories: [TaskCategory] = [.work, .personal, .home]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Add Task")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, -24)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Input Fields
                    VStack(spacing: 16) {
                        InputField(
                            title: "Task Title",
                            text: $title,
                            placeholder: "Enter task title"
                        )
                        
                        InputField(
                            title: "Description",
                            text: $description,
                            placeholder: "Enter task description"
                        )
                    }
                    
                    // Categories
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Category")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                            Button(action: { showAllCategories.toggle() }) {
                                HStack(spacing: 4) {
                                    Text(showAllCategories ? "Show Less" : "Show More")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                                    Image(systemName: showAllCategories ? "chevron.up" : "chevron.down")
                                        .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                                }
                            }
                        }
                        
                        if !showAllCategories {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(mainCategories, id: \.self) { category in
                                    ModernCategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    if category != .all {
                                        ModernCategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category,
                                            action: { selectedCategory = category }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Priority
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Priority")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                ModernPriorityButton(
                                    priority: priority,
                                    isSelected: selectedPriority == priority,
                                    action: { selectedPriority = priority }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.top, 8)
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: { isPresented = false }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    onSave()
                    isPresented = false
                }) {
                    Text("Create")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.00, green: 0.44, blue: 0.14),
                                    Color(red: 1.00, green: 0.44, blue: 0.14).opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .presentationDetents([.large])
    }
}



