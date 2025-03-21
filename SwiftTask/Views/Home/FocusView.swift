//
//  FocusView.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 31.01.25.
//

import SwiftUI

struct FocusView: View {
    @StateObject private var viewModel = FocusViewModel()
    @State private var selectedTimeFrame = "This Week"
    @State private var navigateToHome = false
    @State private var navigateToProfile = false
    @State private var navigateToFocus = true
    @State private var navigateToCalendar = false
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Focus Mode")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    focusContent()
                        .padding(.bottom, 90)
                }
            }
            
            VStack {
                Spacer()
                TabBarView(
                    navigateToHome: $navigateToHome,
                    navigateToProfile: $navigateToProfile,
                    navigateToCalendar: $navigateToCalendar,
                    navigateToFocus: .constant(true),
                    onAddTask: { /* Focus mode does not support adding tasks */ }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView(context: PersistenceController.shared.viewContext)
                .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(homeViewModel: HomeViewModel(context: PersistenceController.shared.viewContext))
                .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $navigateToCalendar) {
            CalendarView(context: PersistenceController.shared.viewContext)
                .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $viewModel.showingTimerPicker) {
            timerPickerSheet
        }
    }
    
    private var timerPickerSheet: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Select Duration")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                ForEach(viewModel.timerOptions, id: \.minutes) { option in
                    Button(action: {
                        viewModel.setTimer(minutes: option.minutes)
                    }) {
                        Text(option.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(red: 0.21, green: 0.21, blue: 0.21))
                            )
                    }
                }
                
                Button("Cancel") {
                    viewModel.showingTimerPicker = false
                }
                .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                .padding(.top)
            }
            .padding()
            .presentationDetents([.height(400)])
        }
    }
    
    @ViewBuilder
    private func focusContent() -> some View {
        VStack(spacing: 24) {
            // Timer Circle
            ZStack {
                // Arka plan dairesi
                Circle()
                    .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 20)
                    .frame(width: 300, height: 300)
                
                // İlerleme dairesi
                Circle()
                    .trim(from: 0.0, to: viewModel.timeRemaining / viewModel.selectedDuration)
                    .stroke(style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round,
                        lineJoin: .round
                    ))
                    .foregroundColor(Color(red: 1.00, green: 0.44, blue: 0.14))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 300, height: 300)
                    .animation(.linear, value: viewModel.timeRemaining)
                
                Button(action: {
                    if !viewModel.isTimerRunning {
                        viewModel.showingTimerPicker = true
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(viewModel.formatTime(viewModel.timeRemaining))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(viewModel.isTimerRunning ? "Focusing..." : "Tap to set timer")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                .disabled(viewModel.isTimerRunning)
            }
            .padding(.vertical, 30)
            
            // Notification Text
            Text("While your focus mode is on, all of your notifications will be off")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            
            // Focus Button
            Button(action: {
                if viewModel.isTimerRunning {
                    viewModel.stopFocusMode()
                } else {
                    viewModel.startFocusMode()
                }
            }) {
                Text(viewModel.isTimerRunning ? "Stop Focusing" : "Start Focusing")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 1.00, green: 0.44, blue: 0.14))
                    .cornerRadius(4)
                    .padding(.horizontal, 24)
            }
            
            // Overview Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Overview")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Menu {
                        Button("This Week") { selectedTimeFrame = "This Week" }
                        Button("This Month") { selectedTimeFrame = "This Month" }
                        Button("This Year") { selectedTimeFrame = "This Year" }
                    } label: {
                        HStack(spacing: 8) {
                            Text(selectedTimeFrame)
                                .font(.system(size: 14))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                        .cornerRadius(4)
                    }
                }
                .padding(.horizontal, 24)
                
                // Focus History Graph
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<7) { index in
                            let date = Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date()
                            let duration = viewModel.getDurationForDate(date)
                            let maxDuration = viewModel.getMaxDuration()
                            let height = maxDuration > 0 ? CGFloat(duration / maxDuration) * 120 : 0
                            
                            VStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    Text(viewModel.formatDurationHours(duration))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(red: 1.00, green: 0.44, blue: 0.14))
                                        .frame(width: 30, height: max(height, 20))
                                }
                                
                                Text(getDayAbbreviation(for: date))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
    
    private func getDayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
}

#Preview {
    FocusView()
}
