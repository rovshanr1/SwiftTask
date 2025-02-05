//
//  NetworkService.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 05.02.25.
//

import Foundation
import Network

class NetworkService {
    static let shared = NetworkService()
    private let monitor = NWPathMonitor()
    
    func isConnectedToNetwork() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isConnected = false
        
        monitor.pathUpdateHandler = { path in
            isConnected = (path.status == .satisfied)
            semaphore.signal()
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        semaphore.wait()
        
        return isConnected
    }
}
