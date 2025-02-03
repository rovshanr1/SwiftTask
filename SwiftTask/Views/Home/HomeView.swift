import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showingSheet = false
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: Item?
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    taskListView()
                    Spacer()
                    tabBarView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear { viewModel.fetchItems() }
            .sheet(isPresented: $showingSheet) {
                AddTaskSheet(
                    isPresented: $showingSheet,
                    title: $newTaskTitle,
                    description: $newTaskDescription,
                    onSave: saveTask
                )
            }
            .alert("Are you sure?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete {
                        viewModel.deleteSingleTask(item)
                        itemToDelete = nil
                    }
                }
            } message: {
                Text("This task will be permanently deleted.")
            }
        }
    }
    
    @ViewBuilder
    private func taskListView() -> some View {
        ScrollView {
            if viewModel.items.isEmpty {
                EmptyTaskView()
            } else {
                VStack {
                    ForEach(viewModel.items) { item in
                        TaskRow(item: item, onDelete: { showDeleteAlert(for: item) })
                    }
                }
            }
        }
    }
    
    private func saveTask() {
        if !newTaskTitle.isEmpty {
            viewModel.addTask(title: newTaskTitle, description: newTaskDescription)
            newTaskTitle = ""
            newTaskDescription = ""
        }
    }
    
    private func showDeleteAlert(for item: Item) {
        itemToDelete = item
        showingDeleteAlert = true
    }
    @ViewBuilder
    private func tabBarView() -> some View {
        ZStack {
            HStack {
                HStack(spacing: 50) {
                    Button(action: {}) {
                        Image(systemName: "house")
                            .foregroundStyle(.white)
                        
                    }
                    Button(action: {}) {
                        Image(systemName: "calendar")
                        .foregroundStyle(.white)}
                }
                .padding(.leading, 20)
                Spacer()
                HStack(spacing: 50) {
                    
                    Button(action: {}) {
                        Image(systemName: "clock")
                        .foregroundStyle(.white)}
                    Button(action: {}) {
                        Image(systemName: "person")
                        .foregroundStyle(.white)}
                }
                .padding(.trailing, 20)
            }
            .frame(height: 70)
            .background(Color(red: 0.21, green: 0.21, blue: 0.21).opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 16)
            
            Button(action: { showingSheet = true }) {
                Circle()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.purple)
                    .overlay(Image(systemName: "plus").font(.system(size: 32, weight: .bold)).foregroundColor(.white))
            }
            .offset(y: -30)
        }
    }
}

struct TaskRow: View {
    let item: Item
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title ?? "Unnamed Task")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(item.taskDescription ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .contextMenu { Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") } }
    }
}

struct EmptyTaskView: View {
    var body: some View {
        VStack {
            Image("Checklist-rafiki 1")
                .resizable()
                .scaledToFit()
                .padding()
            VStack(spacing: 10) {
                Text("What do you want to do today?")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white)
                Text("Tap + to add your tasks")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
}

#Preview {
    HomeView(context: PersistenceController.shared.viewContext)
}
