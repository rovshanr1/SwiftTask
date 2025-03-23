import XCTest
@testable import SwiftTask
import CoreData

final class CalendarViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: CalendarViewModel!
    var context: NSManagedObjectContext!
    var container: NSPersistentContainer!
    var notificationCenter: NotificationCenter!
    var notificationObservers: [NSObjectProtocol] = []
    
    // MARK: - Test Lifecycle
    override func setUpWithError() throws {
        super.setUp()
        try setupTestEnvironment()
    }
    
    override func tearDownWithError() throws {
        try cleanupTestEnvironment()
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    private func setupTestEnvironment() throws {
        notificationCenter = .default
        
        container = NSPersistentContainer(name: "SwiftTask")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        if let error = loadError {
            throw error
        }
        
        context = container.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        viewModel = CalendarViewModel(context: context, isTestEnvironment: true)
    }
    
    private func cleanupTestEnvironment() throws {
        notificationObservers.forEach { notificationCenter.removeObserver($0) }
        notificationObservers.removeAll()
        
        try clearAllData()
        
        viewModel = nil
        context = nil
        container = nil
        notificationCenter = nil
    }
    
    private func clearAllData() throws {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let items = try context.fetch(fetchRequest)
        for item in items {
            context.delete(item)
        }
        try context.save()
    }
    
    private func createTestTask(
        title: String,
        description: String = "",
        completed: Bool = false,
        category: TaskCategory = .all,
        priority: TaskPriority = .low,
        date: Date = Date()
    ) throws -> Item {
        let task = Item(context: context)
        task.id = UUID()
        task.title = title
        task.taskDescription = description
        task.completed = completed
        task.category = category.rawValue
        task.priority = Int16(priority.rawValue)
        task.date = Calendar.current.startOfDay(for: date)
        try context.save()
        return task
    }
    
    private func expectNotification(
        name: Notification.Name,
        object: Any? = nil
    ) -> XCTestExpectation {
        let expectation = expectation(description: "Notification: \(name.rawValue)")
        let observer = notificationCenter.addObserver(
            forName: name,
            object: object,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }
        notificationObservers.append(observer)
        return expectation
    }
    
    // MARK: - Tests
    func testInitialState() throws {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.selectedCategory, .all)
        XCTAssertTrue(viewModel.tasks.isEmpty)
        XCTAssertNotNil(viewModel.selectedDate)
    }
    
    func testTaskCreationAndFetching() throws {
        let today = Calendar.current.startOfDay(for: Date())
        _ = try createTestTask(
            title: "Test Task",
            category: .work,
            date: today
        )
        
        viewModel.fetchTasks()
        
        let tasksForToday = viewModel.tasksForDate(today)
        XCTAssertEqual(tasksForToday.count, 1)
        XCTAssertEqual(tasksForToday.first?.title, "Test Task")
        XCTAssertEqual(tasksForToday.first?.category, TaskCategory.work.rawValue)
    }
    
    func testToggleTaskCompletion() throws {
        let today = Calendar.current.startOfDay(for: Date())
        let task = try createTestTask(
            title: "Toggle Test",
            completed: false,
            date: today
        )
        
        viewModel.fetchTasks()
        
        // İlk toggle işlemi için beklenti
        let firstToggleExpectation = expectation(description: "First toggle notification")
        let observer1 = notificationCenter.addObserver(
            forName: .tasksUpdated,
            object: nil,
            queue: .main
        ) { _ in
            firstToggleExpectation.fulfill()
        }
        notificationObservers.append(observer1)
        
        viewModel.toggleTaskCompletion(task)
        XCTAssertTrue(task.completed, "Görev tamamlanmış olmalı")
        wait(for: [firstToggleExpectation], timeout: 2.0)
        
        // İkinci toggle işlemi için beklenti
        let secondToggleExpectation = expectation(description: "Second toggle notification")
        let observer2 = notificationCenter.addObserver(
            forName: .tasksUpdated,
            object: nil,
            queue: .main
        ) { _ in
            secondToggleExpectation.fulfill()
        }
        notificationObservers.append(observer2)
        
        viewModel.toggleTaskCompletion(task)
        XCTAssertFalse(task.completed, "Görev tamamlanmamış olmalı")
        wait(for: [secondToggleExpectation], timeout: 2.0)
    }
    
    func testTaskCountsUpdate() throws {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Önce mevcut verileri temizle
        try clearAllData()
        
        // Test görevi oluştur
        let task = try createTestTask(
            title: "Test Task",
            description: "Test Description",
            completed: false,
            category: .work,
            priority: .medium,
            date: today
        )
        
        // İlk durumu kontrol et
        viewModel.fetchTasks()
        XCTAssertEqual(viewModel.totalTasks(for: today), 1, "Başlangıçta 1 görev olmalı")
        XCTAssertFalse(viewModel.hasCompletedTasks(for: today), "Başlangıçta tamamlanmış görev olmamalı")
        XCTAssertEqual(task.category, TaskCategory.work.rawValue, "Görev kategorisi Work olmalı")
        
        // Notification beklentisi oluştur
        let toggleExpectation = expectation(description: "Task toggle notification")
        let observer = notificationCenter.addObserver(
            forName: .tasksUpdated,
            object: nil,
            queue: .main
        ) { _ in
            toggleExpectation.fulfill()
        }
        notificationObservers.append(observer)
        
        // Görevi tamamla
        viewModel.toggleTaskCompletion(task)
        
        // Notification'ı bekle
        wait(for: [toggleExpectation], timeout: 2.0)
        
        // Değişiklikleri kontrol et
        XCTAssertTrue(task.completed, "Görev tamamlanmış olmalı")
        XCTAssertTrue(viewModel.hasCompletedTasks(for: today), "Tamamlanmış görev olmalı")
        XCTAssertEqual(viewModel.totalTasks(for: today), 1, "Toplam görev sayısı değişmemeli")
    }
    
    func testCategoryFiltering() throws {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Önce mevcut verileri temizle
        try clearAllData()
        
        // Test görevlerini oluştur
        _ = try createTestTask(
            title: "Work Task",
            description: "Work Description",
            category: .work,
            priority: .high,
            date: today
        )
        
        _ = try createTestTask(
            title: "Home Task",
            description: "Home Description",
            category: .home,
            priority: .medium,
            date: today
        )
        
        // ViewModel'i yenile ve ilk durumu kontrol et
        viewModel.fetchTasks()
        XCTAssertEqual(viewModel.totalTasks(for: today), 2, "Toplam 2 görev olmalı")
        
        // Work kategorisi testi
        viewModel.selectedCategory = .work
        var filteredTasks = viewModel.tasksForDate(today)
        XCTAssertEqual(filteredTasks.count, 1, "Work kategorisinde 1 görev olmalı")
        XCTAssertEqual(filteredTasks.first?.title, "Work Task", "Work görev başlığı eşleşmeli")
        XCTAssertEqual(filteredTasks.first?.category, TaskCategory.work.rawValue, "Kategori Work olmalı")
        
        // Home kategorisi testi
        viewModel.selectedCategory = .home
        filteredTasks = viewModel.tasksForDate(today)
        XCTAssertEqual(filteredTasks.count, 1, "Home kategorisinde 1 görev olmalı")
        XCTAssertEqual(filteredTasks.first?.title, "Home Task", "Home görev başlığı eşleşmeli")
        XCTAssertEqual(filteredTasks.first?.category, TaskCategory.home.rawValue, "Kategori Home olmalı")
        
        // Tüm kategoriler testi
        viewModel.selectedCategory = .all
        filteredTasks = viewModel.tasksForDate(today)
        XCTAssertEqual(filteredTasks.count, 2, "Tüm kategorilerde 2 görev olmalı")
    }
    
    func testWeekDaysGeneration() throws {
        let days = viewModel.getDaysInWeek()
        XCTAssertEqual(days.count, 7, "Hafta 7 gün olmalı")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // İlk gün kontrolü (bugünden 3 gün önce)
        let firstDay = days.first!
        let daysBetweenFirstAndToday = calendar.dateComponents([.day], from: firstDay, to: today).day!
        XCTAssertEqual(daysBetweenFirstAndToday, 3, "İlk gün bugünden 3 gün önce olmalı")
        
        // Son gün kontrolü (bugünden 3 gün sonra)
        let lastDay = days.last!
        let daysBetweenTodayAndLast = calendar.dateComponents([.day], from: today, to: lastDay).day!
        XCTAssertEqual(daysBetweenTodayAndLast, 3, "Son gün bugünden 3 gün sonra olmalı")
        
        // Günlerin ardışık olduğunu kontrol et
        for i in 0..<(days.count - 1) {
            let difference = calendar.dateComponents([.day], from: days[i], to: days[i + 1]).day!
            XCTAssertEqual(difference, 1, "Günler ardışık olmalı")
        }
    }
    
    func testDateFormatting() throws {
        let date = Date()
        
        // Formatlı tarih kontrolü
        let formattedDate = viewModel.formattedDate(date)
        XCTAssertFalse(formattedDate.isEmpty, "Formatlı tarih boş olmamalı")
        
        // Haftanın günü kontrolü
        let weekDay = viewModel.weekDay(date)
        XCTAssertFalse(weekDay.isEmpty, "Haftanın günü boş olmamalı")
        
        // Gün numarası kontrolü
        let dayNumber = viewModel.dayNumber(date)
        XCTAssertFalse(dayNumber.isEmpty, "Gün numarası boş olmamalı")
        
        // Gün numarası doğruluğu kontrolü
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        if let dayComponent = components.day,
           let dayNumberInt = Int(dayNumber) {
            XCTAssertEqual(dayNumberInt, dayComponent, "Gün numarası doğru olmalı")
        }
    }
    
    func testTaskCompletionStatus() throws {
        let today = Calendar.current.startOfDay(for: Date())
        let task = try createTestTask(
            title: "Completion Test",
            completed: true,
            date: today
        )
        
        viewModel.fetchTasks()
        
        XCTAssertTrue(viewModel.hasCompletedTasks(for: today), "Tamamlanmış görev olmalı")
        XCTAssertEqual(viewModel.totalTasks(for: today), 1, "Toplam görev sayısı 1 olmalı")
        
        viewModel.toggleTaskCompletion(task)
        
        XCTAssertFalse(viewModel.hasCompletedTasks(for: today), "Tamamlanmış görev olmamalı")
        XCTAssertEqual(viewModel.totalTasks(for: today), 1, "Toplam görev sayısı değişmemeli")
    }
} 
