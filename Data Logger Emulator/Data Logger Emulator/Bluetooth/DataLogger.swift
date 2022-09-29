//
//  DataLogger.swift
//  Data Logger Emulator
//
//  Created by Adam Kopec on 29/09/2022.
//

import Foundation

class DataLogger {
    // Device
    /// The current firmware version installed on the device
    var firmwareVersion: String?
    /// The serial number of the device
    var serialNumber: String?
    
    // Battery
    /// Battery level in percentage (0-100)
    var batteryLevel: Int?
    /// Value indicating whether the battery is currently being charged
    var isChargingBattery: Bool?
    
    // Location and Speed
    /// Speed in m/s
    var speed: Int?
    /// Location in degrees
    var location: (latitude: Double, longitude: Double)?
}
