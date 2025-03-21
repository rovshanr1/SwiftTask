//
//  FocusViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 31.01.25.
//

import Foundation
import Combine

class FocusViewModel: ObservableObject {
    @Published var isTimerRunning = false
    @Published var timeRemaining: TimeInterval = 30 * 60 
    @Published var focusData: [DailyFocus] = []
    
    private var timer: Timer?
    private let calendar = Calendar.current
    
    init() {
        generateMockData()
    }
    
    func startFocusMode() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopFocusMode()
            }
        }
    }
    
    func stopFocusMode() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        // Odaklanma süresini kaydet
        saveFocusSession()
    }
    
    private func saveFocusSession() {
        let today = Date()
        if let existingIndex = focusData.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            focusData[existingIndex].duration += (30 * 60) - timeRemaining
        } else {
            focusData.append(DailyFocus(date: today, duration: (30 * 60) - timeRemaining))
        }
        timeRemaining = 30 * 60 // Reset timer
    }
    
    private func generateMockData() {
        let today = Date()
        focusData = [
            DailyFocus(date: calendar.date(byAdding: .day, value: -6, to: today)!, duration: 2.5 * 3600),
            DailyFocus(date: calendar.date(byAdding: .day, value: -5, to: today)!, duration: 3.5 * 3600),
            DailyFocus(date: calendar.date(byAdding: .day, value: -4, to: today)!, duration: 5 * 3600),
            DailyFocus(date: calendar.date(byAdding: .day, value: -3, to: today)!, duration: 3 * 3600),
            DailyFocus(date: calendar.date(byAdding: .day, value: -2, to: today)!, duration: 4 * 3600),
            DailyFocus(date: calendar.date(byAdding: .day, value: -1, to: today)!, duration: 4.5 * 3600),
            DailyFocus(date: today, duration: 2 * 3600)
        ]
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatHours(_ timeInterval: TimeInterval) -> Double {
        return timeInterval / 3600
    }
}
