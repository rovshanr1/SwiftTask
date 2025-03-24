import SwiftUI

struct GuestView: View {
    @StateObject private var viewModel = GuestViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showLoginPrompt = false
    @State private var navigateToIntro = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Limited Usage Banner
                    limitedUsageBanner
                        .transition(.scale.combined(with: .opacity))
                    
                    // Task List
                    taskListView
                        .transition(.opacity)
                }
            }
            .overlay(alignment: .bottom) {
                // Floating Action Button
                addTaskButton
                    .padding(.bottom, 20)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Guest Mode")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $viewModel.showingSheet) {
                GuestAddTaskSheet(
                    isPresented: $viewModel.showingSheet,
                    title: $viewModel.newTaskTitle,
                    description: $viewModel.newTaskDescription,
                    onSave: viewModel.addTask
                )
            }
            .alert("Delete Task", isPresented: $viewModel.showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let item = viewModel.itemToDelete {
                        viewModel.deleteTask(item: item)
                    }
                }
            }
            .fullScreenCover(isPresented: $navigateToIntro) {
                IntroView()
            }
        }
    }
    
    // MARK: - View Components
    private var limitedUsageBanner: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.customAccent)
                Text("Limited Usage Mode")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Create an account to unlock all features and sync your tasks across devices")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                navigateToIntro = true
            }) {
                HStack {
                    Text("Create Account")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                .background(Color.customGradient)
                .cornerRadius(15)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.tasks.isEmpty {
                    EmptyGuestTaskView()
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.tasks) { item in
                        GuestTaskRow(item: item,
                                   onDelete: { viewModel.showDeleteAlert(for: item) },
                                   onEdit: viewModel.editTask,
                                   onComplete: viewModel.toggleTaskCompletion)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // FAB için boşluk
        }
    }
    
    private var addTaskButton: some View {
        Button(action: { viewModel.showingSheet = true }) {
            ZStack {
                Circle()
                    .fill(Color.customGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: .customAccent.opacity(0.3), radius: 10)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var backButton: some View {
        Button(action: {
            navigateToIntro = true
        }) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Guest Task Row
struct GuestTaskRow: View {
    let item: TaskItem
    let onDelete: () -> Void
    let onEdit: (TaskItem, String, String) -> Void
    let onComplete: (TaskItem) -> Void
    
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDescription = ""
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion Button
            Button(action: { onComplete(item) }) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.completed ? .customAccent : .white.opacity(0.6))
            }
            
            // Task Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(item.completed ? .gray : .white)
                    .strikethrough(item.completed)
                
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .contextMenu {
            Button(action: {
                editedTitle = item.title
                editedDescription = item.description
                isEditing = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $isEditing) {
            GuestAddTaskSheet(
                isPresented: $isEditing,
                title: $editedTitle,
                description: $editedDescription,
                onSave: {
                    onEdit(item, editedTitle, editedDescription)
                }
            )
        }
    }
}

// MARK: - Empty Task View
struct EmptyGuestTaskView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.customAccent)
            
            Text("No Tasks Yet")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Start by adding your first task")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}
