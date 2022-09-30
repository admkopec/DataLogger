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
    var randomBattery = true
    /// Battery level in percentage (0-100)
    @Published var batteryLevel = 100
    /// Value indicating whether the battery is currently being charged
    @Published var isChargingBattery = false
    
    // Location and Speed
    var randomLocation = true
    /// Speed in m/s
    @Published var speed = Int.random(in: 0...50)
    /// Location in degrees
    @Published var location = (latitude: 52.23033, longitude: 20.98046)
    
    private var batteryTimer: AnyCancellable!
    private var locationTimer: AnyCancellable!
    
    init() {
        batteryTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            if self?.isChargingBattery == true {
                self?.batteryLevel += 1
                if self?.batteryLevel ?? 0 > 95, Bool.random() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) {
                        self?.isChargingBattery = false
                    }
                }
            } else {
                self?.batteryLevel -= 1
                if self?.batteryLevel ?? 100 < 20, Bool.random() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) {
                        self?.isChargingBattery = true
                    }
                }
            }
        }
        locationTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            let speed = self?.speed ?? 0 + Int.random(in: -1...1)
            self?.speed = speed < 0 ? 0 : speed
            // TODO: Make the changes in direction a bit better
            switch Int.random(in: 0...3) {
            case 0:
                // Move left
                self?.location.latitude += Double(self?.speed ?? 0) / 10 * 0.0001
            case 1:
                // Move right
                self?.location.latitude -= Double(self?.speed ?? 0) / 10 * 0.0001
            case 2:
                // Move up
                self?.location.longitude += Double(self?.speed ?? 0) / 10 * 0.0001
            case 3:
                // Move down
                self?.location.longitude -= Double(self?.speed ?? 0) / 10 * 0.0001
            default:
                break
            }
        }
    }
    
    deinit {
        batteryTimer.cancel()
        locationTimer.cancel()
    }
}
