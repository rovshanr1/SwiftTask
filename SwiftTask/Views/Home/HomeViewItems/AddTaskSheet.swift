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
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Task")
                .font(.title2)
                .bold()
                .foregroundStyle(.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    TextField("Task title", text: $title, prompt: Text("Task Title").foregroundStyle(.gray))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    
                    TextField("Description", text: $description, prompt: Text("Description").foregroundStyle(.gray))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    
                    // Categories
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Category")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                            Button(action: { showAllCategories.toggle() }) {
                                HStack(spacing: 4) {
                                    Text(showAllCategories ? "Less" : "More")
                                        .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                                    Image(systemName: showAllCategories ? "chevron.up" : "chevron.down")
                                        .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                                }
                            }
                        }
                        
                        if !showAllCategories {
                            // Ana kategoriler
                            HStack(spacing: 12) {
                                ForEach(mainCategories, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        color: category.color,
                                        icon: category.icon,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                        } else {
                            // Tüm kategoriler
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    if category != .all {
                                        CategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category,
                                            color: category.color,
                                            icon: category.icon,
                                            action: { selectedCategory = category }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Priority
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priority")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                PriorityButton(
                                    priority: priority,
                                    isSelected: selectedPriority == priority,
                                    action: { selectedPriority = priority }
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            
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
                    Text("Create")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .presentationDetents([.large])
    }
}

struct PriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(priority.title)
                .foregroundColor(isSelected ? .white : priority.color)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? priority.color : priority.color.opacity(0.2))
                .cornerRadius(4)
        }
    }
}


