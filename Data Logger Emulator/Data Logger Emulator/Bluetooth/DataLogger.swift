//
//  DataLogger.swift
//  Data Logger Emulator
//
//  Created by Adam Kopec on 29/09/2022.
//

import Combine
import Foundation

class DataLogger: ObservableObject {
    // Device
    /// The current firmware version installed on the device
    @Published var firmwareVersion: String?
    /// The serial number of the device
    @Published var serialNumber: String?
    
    // Battery
    /// Battery level in percentage (0-100)
    @Published var batteryLevel: Int?
    /// Value indicating whether the battery is currently being charged
    @Published var isChargingBattery: Bool?
    
    // Location and Speed
    /// Speed in m/s
    @Published var speed: Int?
    /// Location in degrees
    @Published var location: (latitude: Double, longitude: Double)?
}
