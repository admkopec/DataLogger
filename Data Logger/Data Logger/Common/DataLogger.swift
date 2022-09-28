//
//  DataLogger.swift
//  Data Logger
//
//  Created by Adam Kopec on 28/09/2022.
//

import Combine
import Foundation

class DataLogger: ObservableObject {
    @Published var firmwareVersion = ""
    @Published var serialNumber = ""
    
    @Published var batteryLevel = 0
    @Published var isCharging = false
    
    @Published var isConnected = false
    
    let car = Car()
}
