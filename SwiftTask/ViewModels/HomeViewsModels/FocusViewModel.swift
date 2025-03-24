//
//  FocusViewModel.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 31.01.25.
//

import Foundation
import Combine
import FirebaseAuth

class FocusViewModel: ObservableObject {
    @Published var isTimerRunning = false
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var focusData: [DailyFocus] = []
    @Published var selectedDuration: TimeInterval = 25 * 60
    @Published var showingTimerPicker = false
    
    private var timer: Timer?
    private let calendar = Calendar.current
    private let focusService = FocusService.shared
    
    init() {
        loadFocusData()
    }
    
    func startFocusMode() {
        print("startFocusMode çağrıldı")
        isTimerRunning = true
        timeRemaining = selectedDuration
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                print("Kalan süre: \(self.timeRemaining) saniye")
            } else {
                print("Timer tamamlandı")
                self.stopFocusMode()
            }
        }
    }
    
    func stopFocusMode() {
        print("stopFocusMode çağrıldı")
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        saveFocusSession()
    }
    
    private func saveFocusSession() {
        print("saveFocusSession çağrıldı")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı ID bulunamadı")
            return
        }
        
        let today = Date()
        let focusDuration = selectedDuration - timeRemaining
        
        if focusDuration > 0 {
            if let existingIndex = focusData.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
                var updatedFocus = focusData[existingIndex]
                updatedFocus.duration += focusDuration
                focusData[existingIndex] = updatedFocus
                print("Güncellenen süre: \(updatedFocus.duration) saniye")
                focusService.saveFocusSession(updatedFocus)
            } else {
                let newFocus = DailyFocus(date: today, duration: focusDuration, userId: userId)
                focusData.append(newFocus)
                print("Yeni süre: \(focusDuration) saniye")
                focusService.saveFocusSession(newFocus)
            }
            
            // Son 7 günün verilerini sakla ve sırala
            focusData = focusData
                .filter { calendar.dateComponents([.day], from: $0.date, to: today).day ?? 0 <= 7 }
                .sorted { $0.date < $1.date }
                
            // UI'ı güncelle
            objectWillChange.send()
            print("focusData güncellendi ve UI yenilendi")
        } else {
            print("focusDuration 0 veya negatif: \(focusDuration)")
        }
        
        timeRemaining = selectedDuration // Zamanlayıcıyı sıfırla
    }
    
    private func loadFocusData() {
        focusData = focusService.loadFocusSessions()
        
        // Firebase'den verileri yükle ve senkronize et
        focusService.loadFocusFromFirebase { [weak self] remoteSessions in
            guard let self = self else { return }
            
            let today = Date()
            self.focusData = remoteSessions
                .filter { self.calendar.dateComponents([.day], from: $0.date, to: today).day ?? 0 <= 7 }
                .sorted { $0.date < $1.date }
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
    
    // TimeFrame filtreleme metodları
    func getFilteredFocusData(for timeFrame: TimeFrame) -> [DailyFocus] {
        let today = Date()
        
        switch timeFrame {
        case .week:
            return focusData.filter {
                guard let days = calendar.dateComponents([.day], from: $0.date, to: today).day else { return false }
                return days <= 7
            }
        case .month:
            return focusData.filter {
                guard let month = calendar.dateComponents([.month], from: $0.date, to: today).month else { return false }
                return month <= 1
            }
        case .year:
            return focusData.filter {
                guard let year = calendar.dateComponents([.year], from: $0.date, to: today).year else { return false }
                return year <= 1
            }
        }
    }
    
    func getTotalDuration(for timeFrame: TimeFrame) -> TimeInterval {
        return getFilteredFocusData(for: timeFrame).reduce(0) { $0 + $1.duration }
    }
    
    func getAverageDuration(for timeFrame: TimeFrame) -> TimeInterval {
        let filteredData = getFilteredFocusData(for: timeFrame)
        guard !filteredData.isEmpty else { return 0 }
        return filteredData.reduce(0) { $0 + $1.duration } / Double(filteredData.count)
    }
    
    // Zamanlayıcı süre seçenekleri
    let timerOptions: [TimerOption] = [
        TimerOption(minutes: 25, title: "25 min"),
        TimerOption(minutes: 45, title: "45 min"),
        TimerOption(minutes: 60, title: "1 hour"),
        TimerOption(minutes: 90, title: "1.5 hours"),
        TimerOption(minutes: 120, title: "2 hours")
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
            if minutes == 0 {
                let seconds = Int(timeInterval)
                return "\(seconds)s"
            }
            return "\(minutes)m"
        } else {
            return String(format: "%.1fh", hours)
        }
    }
}
