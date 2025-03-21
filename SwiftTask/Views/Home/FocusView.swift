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
            
            VStack(spacing: 20) {
                focusContent()
                
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
    }
    
    @ViewBuilder
    private func focusContent() -> some View {
        VStack(spacing: 20) {
            Text("Focus Mode")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Timer Circle
            ZStack {
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Circle()
                    .trim(from: 0.0, to: viewModel.timeRemaining / (30 * 60))
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.purple)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: viewModel.timeRemaining)
                
                Text(viewModel.formatTime(viewModel.timeRemaining))
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 250, height: 250)
            
            // Notification Text
            Text("While your focus mode is on, all of your\nnotifications will be off")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            // Focus Button
            Button(action: {
                if viewModel.isTimerRunning {
                    viewModel.stopFocusMode()
                } else {
                    viewModel.startFocusMode()
                }
            }) {
                Text(viewModel.isTimerRunning ? "Stop Focusing" : "Start Focusing")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            // Overview Section
            VStack(alignment: .leading) {
                HStack {
                    Text("Overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Menu {
                        Button("This Week") { selectedTimeFrame = "This Week" }
                        Button("This Month") { selectedTimeFrame = "This Month" }
                        Button("This Year") { selectedTimeFrame = "This Year" }
                    } label: {
                        HStack {
                            Text(selectedTimeFrame)
                            Image(systemName: "chevron.down")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
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
