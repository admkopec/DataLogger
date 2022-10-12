//
//  DataLogger.swift
//  Data Logger
//
//  Created by Adam Kopec on 28/09/2022.
//

import Combine
import Foundation

class DataLogger: ObservableObject {
    /// The current firmware version installed on the connected Data Logger
    @Published var firmwareVersion = ""
    /// The serial number of the connected Data Logger instance
    @Published var serialNumber = ""
    
    /// Value bewteen 0 and 100, indicating the current percantage of charge left in the Data Logger battery
    @Published var batteryLevel = 0
    /// Value indicating wherether the Data Logger hardware is currenty recieving charge from the Car
    @Published var isCharging = false
    
    /// Value indicatiing whether we are currently connected to the Data Logger hardware
    @Published var isConnected = false
    
    let car = Car()
}
