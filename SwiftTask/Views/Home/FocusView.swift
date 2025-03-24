//
//  FocusView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 31.01.25.
//

import SwiftUI

struct TimerOption: Identifiable {
    let id = UUID()
    let minutes: Int
    let title: String
    
    init(minutes: Int, title: String) {
        self.minutes = minutes
        self.title = title
    }
}

enum TimeFrame: String, CaseIterable {
    case week = "This Week"
    case month = "This Month"
    case year = "This Year"
}

struct FocusView: View {
    @StateObject private var viewModel = FocusViewModel()
    @State private var selectedTimeFrame = TimeFrame.week
    @State private var navigateToHome = false
    @State private var navigateToProfile = false
    @State private var navigateToFocus = true
    @State private var navigateToCalendar = false
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                FocusHeaderView(title: "Focus Mode")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Timer Circle
                        FocusTimerView(
                            timeRemaining: viewModel.timeRemaining,
                            selectedDuration: viewModel.selectedDuration,
                            isTimerRunning: viewModel.isTimerRunning,
                            formattedTime: viewModel.formatTime(viewModel.timeRemaining),
                            onTap: { 
                                if !viewModel.isTimerRunning {
                                    viewModel.showingTimerPicker = true
                                }
                            }
                        )
                        
                        // Notification Text
                        NotificationInfoView()
                        
                        // Focus Button
                        FocusActionButton(
                            isTimerRunning: viewModel.isTimerRunning,
                            onStart: viewModel.startFocusMode,
                            onStop: viewModel.stopFocusMode
                        )
                        
                        // Overview Section
                        FocusOverviewSection(
                            selectedTimeFrame: $selectedTimeFrame,
                            viewModel: viewModel
                        )
                    }
                    .padding(.bottom, 90)
                }
                .onChange(of: viewModel.isTimerRunning) { oldValue, newValue in
                    // Timer durumu değiştiğinde UI'ı güncelle
                    viewModel.objectWillChange.send()
                }
                
                Spacer()
                
                TabBarView(
                    navigateToHome: $navigateToHome,
                    navigateToProfile: $navigateToProfile,
                    navigateToCalendar: $navigateToCalendar,
                    navigateToFocus: .constant(true),
                    onAddTask: {}
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView(context: PersistenceController.shared.viewContext)
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(homeViewModel: HomeViewModel(context: PersistenceController.shared.viewContext))
        }
        .navigationDestination(isPresented: $navigateToCalendar) {
            CalendarView(context: PersistenceController.shared.viewContext)
        }
        .sheet(isPresented: $viewModel.showingTimerPicker) {
            TimerPickerSheet(
                viewModel: viewModel,
                isPresented: $viewModel.showingTimerPicker
            )
        }
    }
}

// MARK: - Supporting Views

struct FocusHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
}

struct FocusTimerView: View {
    let timeRemaining: TimeInterval
    let selectedDuration: TimeInterval
    let isTimerRunning: Bool
    let formattedTime: String
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 20)
                .frame(width: 300, height: 300)
            
            // Progress Circle
            Circle()
                .trim(from: 0.0, to: timeRemaining / selectedDuration)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.44, blue: 0.14),
                            Color(red: 1.00, green: 0.44, blue: 0.14).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 300, height: 300)
                .animation(.linear(duration: 1), value: timeRemaining)
            
            Button(action: onTap) {
                VStack(spacing: 8) {
                    Text(formattedTime)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(isTimerRunning ? "Focusing..." : "Tap to set timer")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .disabled(isTimerRunning)
        }
        .padding(.vertical, 30)
    }
}

struct NotificationInfoView: View {
    var body: some View {
        Text("While your focus mode is on, all of your notifications will be off")
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(.gray)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
    }
}

struct FocusActionButton: View {
    let isTimerRunning: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        Button(action: {
            print("FocusActionButton tıklandı - Timer durumu: \(isTimerRunning)")
            if isTimerRunning {
                onStop()
            } else {
                onStart()
            }
        }) {
            Text(isTimerRunning ? "Stop Focusing" : "Start Focusing")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
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
                .shadow(color: Color(red: 1.00, green: 0.44, blue: 0.14).opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)
        }
    }
}

struct FocusOverviewSection: View {
    @Binding var selectedTimeFrame: TimeFrame
    let viewModel: FocusViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Overview")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Menu {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Button(timeFrame.rawValue) {
                            withAnimation {
                                selectedTimeFrame = timeFrame
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(selectedTimeFrame.rawValue)
                            .font(.system(size: 14))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            
            // Focus Summary Cards
            HStack(spacing: 16) {
                let totalDuration = viewModel.getTotalDuration(for: selectedTimeFrame)
                let averageDuration = viewModel.getAverageDuration(for: selectedTimeFrame)
                
                FocusSummaryCard(
                    title: "Total Focus Time",
                    value: viewModel.formatDurationHours(totalDuration),
                    icon: "hourglass"
                )
                
                FocusSummaryCard(
                    title: "Average Session",
                    value: viewModel.formatDurationHours(averageDuration),
                    icon: "chart.bar"
                )
            }
            .padding(.horizontal, 24)
            
            // Focus History Graph
            FocusHistoryGraph(viewModel: viewModel, timeFrame: selectedTimeFrame)
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
        .onAppear {
            // Debug için
            print("Overview yüklendi")
            print("Mevcut focusData: \(viewModel.focusData)")
        }
    }
}

struct FocusSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
        .cornerRadius(12)
    }
}

struct FocusHistoryGraph: View {
    let viewModel: FocusViewModel
    let timeFrame: TimeFrame
    
    var dateRange: [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        
        switch timeFrame {
        case .week:
            for day in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                    dates.append(date)
                }
            }
        case .month:
            for day in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                    dates.append(date)
                }
            }
        case .year:
            for month in 0..<12 {
                if let date = calendar.date(byAdding: .month, value: -month, to: today) {
                    dates.append(date)
                }
            }
        }
        
        return dates.reversed()
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(dateRange, id: \.self) { date in
                    let duration = viewModel.getDurationForDate(date)
                    let maxDuration = viewModel.getMaxDuration()
                    let height = maxDuration > 0 ? CGFloat(duration / maxDuration) * 150 : 0
                    
                    FocusHistoryBar(
                        date: date,
                        duration: duration,
                        height: max(height, 20),
                        isToday: Calendar.current.isDateInToday(date),
                        timeFrame: timeFrame
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
}

struct FocusHistoryBar: View {
    let date: Date
    let duration: TimeInterval
    let height: CGFloat
    let isToday: Bool
    let timeFrame: TimeFrame
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Text(formatDuration(duration))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.00, green: 0.44, blue: 0.14),
                                Color(red: 1.00, green: 0.44, blue: 0.14).opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: timeFrame == .year ? 60 : 40, height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            Text(formatDate(date))
                .font(.system(size: 12, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? .white : .gray)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        return "\(hours)h"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        switch timeFrame {
        case .week:
            formatter.dateFormat = "EEE"
        case .month:
            formatter.dateFormat = "d MMM"
        case .year:
            formatter.dateFormat = "MMM"
        }
        
        return formatter.string(from: date).uppercased()
    }
}

struct TimerPickerSheet: View {
    let viewModel: FocusViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Select Duration")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.vertical, 8)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.timerOptions, id: \.minutes) { option in
                        TimerOptionButton(
                            option: option,
                            onSelect: {
                                viewModel.setTimer(minutes: option.minutes)
                                isPresented = false
                            }
                        )
                    }
                }
                
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                .padding(.top)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

struct TimerOptionButton: View {
    let option: TimerOption
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(option.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.21, green: 0.21, blue: 0.21))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

#Preview {
    FocusView()
}
