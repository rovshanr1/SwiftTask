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
    @Published var timeRemaining: TimeInterval = 25 * 60 // Default 25 dakika
    @Published var focusData: [DailyFocus] = []
    @Published var selectedDuration: TimeInterval = 25 * 60 // Seçilen süre
    @Published var showingTimerPicker = false
    
    private var timer: Timer?
    private let calendar = Calendar.current
    private let userDefaults = UserDefaults.standard
    private let focusDataKey = "focusData"
    
    init() {
        loadFocusData()
    }
    
    func startFocusMode() {
        isTimerRunning = true
        timeRemaining = selectedDuration
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
        saveFocusSession()
    }
    
    private func saveFocusSession() {
        let today = Date()
        let focusDuration = selectedDuration - timeRemaining
        
        if focusDuration > 0 {
            if let existingIndex = focusData.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
                focusData[existingIndex].duration += focusDuration
            } else {
                focusData.append(DailyFocus(date: today, duration: focusDuration))
            }
            
            // Son 7 günün verilerini sakla
            focusData = focusData
                .filter { calendar.dateComponents([.day], from: $0.date, to: today).day ?? 0 <= 7 }
                .sorted { $0.date < $1.date }
            
            saveFocusData()
        }
        
        timeRemaining = selectedDuration // Zamanlayıcıyı sıfırla
    }
    
    private func loadFocusData() {
        if let data = userDefaults.data(forKey: focusDataKey),
           let decodedData = try? JSONDecoder().decode([DailyFocus].self, from: data) {
            focusData = decodedData
        }
    }
    
    private func saveFocusData() {
        if let encodedData = try? JSONEncoder().encode(focusData) {
            userDefaults.set(encodedData, forKey: focusDataKey)
        }
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getDurationForDate(_ date: Date) -> TimeInterval {
        return focusData.first { calendar.isDate($0.date, inSameDayAs: date) }?.duration ?? 0
    }
    
    func getMaxDuration() -> TimeInterval {
        return focusData.map { $0.duration }.max() ?? 3600 // En az 1 saat göster
    }
    
    // Zamanlayıcı süre seçenekleri
    let timerOptions: [(minutes: Int, title: String)] = [
        (25, "25 min"),
        (45, "45 min"),
        (60, "1 hour"),
        (90, "1.5 hours"),
        (120, "2 hours")
    ]
    
    func setTimer(minutes: Int) {
        selectedDuration = TimeInterval(minutes * 60)
        timeRemaining = selectedDuration
        showingTimerPicker = false
    }
    
    func formatDurationHours(_ timeInterval: TimeInterval) -> String {
        let hours = timeInterval / 3600
        if hours < 1 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m"
        } else {
            return String(format: "%.1fh", hours)
        }
    }
}
