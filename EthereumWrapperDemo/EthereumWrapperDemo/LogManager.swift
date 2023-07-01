//
//  LogManager.swift
//  EthereumWrapperDemo
//
//  Created by Harrison Friia on 6/30/23.
//

import BleTransport
import BleWrapper
import EthWrapper
import SwiftUI

class LogManager: ObservableObject {
    @Published var logs: [String] = []
    
    private let dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SS"
    }

    func addToLog(_ message: String) {
        DispatchQueue.main.async {
            let date = Date()
            let timestamp = self.dateFormatter.string(from: date)
            self.logs.append("[\(timestamp)] \(message)")
        }
    }
}
