//
//  BluetoothPeripheral.swift
//  BluetoothPeripherial
//
//  Created by Adam Kopec on 26/09/2022.
//

import Combine
import Foundation
import CoreBluetooth
import BluetoothProtocol

//
//  TODO: Improve random LocationAndSpeed and Battery values (Make them more consistent)
//      * Add support for notification functionality of LocationAndSpeed and Battery characteristics
//

class BluetoothPeripheral: NSObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    
    // Data Logger Service
    private var loggerTransferCharacteristic: CBMutableCharacteristic?
    // Device Info Service
    private var protocolVersionCharacteristic: CBMutableCharacteristic?
    private var firmwareVersionCharacteristic: CBMutableCharacteristic?
    private var serialNumberCharacteristic: CBMutableCharacteristic?
    // Battery Service
    private var batteryLevelCharacteristic: CBMutableCharacteristic?
    private var batteryChargingCharacteristic: CBMutableCharacteristic?
    // Location Service
    private var locationAndSpeedCharacteristic: CBMutableCharacteristic?
    
    private var connectedCentral: CBCentral?
    
    private var timers = [CBUUID: AnyCancellable]()
    
    /// A Boolean value that indicates whether the peripheral is advertising data.
    var isAdvertising: Bool {
        return peripheralManager.isAdvertising
    }
    
    // Settings
    let dataLogger = DataLogger()
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }
    /// Start advertising the main (Data Logger) service for discovery
    func startAdvertising() {
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
    }
    /// Stop advertising the services
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
    
    // MARK: - Private funcs
    
    private func setupPeripheral() {
        
        // Build our service.
        
        // Data Logger Service
        
        // Start with the CBMutableCharacteristic.
        let loggerTransferCharacteristic = CBMutableCharacteristic(type: TransferService.loggerCharacteristicUUID, properties: [.notify, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        
        // Create a service from the characteristic.
        let transferService = CBMutableService(type: TransferService.serviceUUID, primary: true)
        
        // Add the characteristic to the service.
        transferService.characteristics = [loggerTransferCharacteristic]
        
        // And add it to the peripheral manager.
        peripheralManager.add(transferService)
        
        // Device Info Service
        
        // Start with the CBMutableCharacteristic.
        let protocolVersionCharacteristic = CBMutableCharacteristic(type: TransferService.protocolVersionCharacteristicUUID, properties: [.read], value: nil, permissions: [.readable])
        let firmwareVersionCharacteristic = CBMutableCharacteristic(type: TransferService.firmwareVersionCharacteristicUUID, properties: [.read], value: nil, permissions: [.readable])
        let serialNumberCharacteristic = CBMutableCharacteristic(type: TransferService.serialNumberCharacteristicUUID, properties: [.read], value: nil, permissions: [.readable])
        
        
        // Create a service from the characteristic.
        let deviceInfoService = CBMutableService(type: TransferService.deviceInfoServiceUUID, primary: true)
        
        // Add the characteristic to the service.
        deviceInfoService.characteristics = [protocolVersionCharacteristic, firmwareVersionCharacteristic, serialNumberCharacteristic]
        // And add it to the peripheral manager.
        peripheralManager.add(deviceInfoService)
        
        // Battery Service
        
        // Start with the CBMutableCharacteristic.
        let batteryLevelCharacteristic = CBMutableCharacteristic(type: TransferService.batteryLevelCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        let batteryChargingCharacteristic = CBMutableCharacteristic(type: TransferService.batteryStatusCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        
        // Create a service from the characteristic.
        let batteryService = CBMutableService(type: TransferService.batteryServiceUUID, primary: true)
        
        // Add the characteristic to the service.
        batteryService.characteristics = [batteryLevelCharacteristic, batteryChargingCharacteristic]
        // And add it to the peripheral manager.
        peripheralManager.add(batteryService)
        
        // Location Service
        
        // Start with the CBMutableCharacteristic.
        let locationAndSpeedCharacteristic = CBMutableCharacteristic(type: TransferService.locationAndSpeedCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        
        // Create a service from the characteristic.
        let locationService = CBMutableService(type: TransferService.locationServiceUUID, primary: true)
        
        // Add the characteristic to the service.
        locationService.characteristics = [locationAndSpeedCharacteristic]
        // And add it to the peripheral manager.
        peripheralManager.add(locationService)
        
        // Save the characteristic for later.
        self.loggerTransferCharacteristic = loggerTransferCharacteristic
        self.protocolVersionCharacteristic = protocolVersionCharacteristic
        self.firmwareVersionCharacteristic = firmwareVersionCharacteristic
        self.serialNumberCharacteristic = serialNumberCharacteristic
        self.batteryLevelCharacteristic = batteryLevelCharacteristic
        self.batteryChargingCharacteristic = batteryChargingCharacteristic
        self.locationAndSpeedCharacteristic = locationAndSpeedCharacteristic
    }
    
    
    // MARK: - CBPeripheralManager
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
            setupPeripheral()
        case .poweredOff:
            print("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            print("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            switch CBManager.authorization {
            case .denied:
                print("You are not authorized to use Bluetooth")
            case .restricted:
                print("Bluetooth is restricted")
            default:
                print("Unexpected authorization")
            }
            return
        case .unknown:
            print("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            print("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            print("A previously unknown peripheral manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    /*
     *  Catch when someone subscribes to our characteristic, then start sending them data
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic")
        
        // Save central
        connectedCentral = central
        let timer: AnyCancellable
        
        switch characteristic.uuid {
        case TransferService.loggerCharacteristicUUID:
            // Start sending some data
            timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect().sink { _ in
                self.sendData()
            }
        case TransferService.locationAndSpeedCharacteristicUUID:
            // Start sending location and speed updates
            timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect().sink { _ in
                self.sendLocationAndSpeed()
            }
        case TransferService.batteryLevelCharacteristicUUID:
            // Start sending battery level updates
            timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect().sink { _ in
                self.sendBatteryLevel()
            }
        case TransferService.batteryStatusCharacteristicUUID:
            // Start sending battery status changes
            timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect().sink { _ in
                self.sendBatteryStatus()
            }
        default:
            print("Central is trying to subscribe to unsupported characteristic")
            return peripheralManager(peripheral, central: central, didUnsubscribeFrom: characteristic)
        }
        timers[characteristic.uuid] = timer
    }
    
    /*
     *  Recognize when the central unsubscribes
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic")
        timers.removeValue(forKey: characteristic.uuid)?.cancel()
        if timers.isEmpty {
            connectedCentral = nil
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            guard request.characteristic.uuid == TransferService.loggerCharacteristicUUID else { continue }
            guard let value = request.value else { continue }
            print("Receieved some value: \(value)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        switch request.characteristic.uuid {
        case TransferService.protocolVersionCharacteristicUUID:
            // Set the response data (Protocol Version)
            request.value = Data("0.1".utf8)
        case TransferService.firmwareVersionCharacteristicUUID:
            // Set the response data (Firmware Version)
            request.value = Data((dataLogger.firmwareVersion ?? "1.0 Mac").utf8)
        case TransferService.serialNumberCharacteristicUUID:
            // Set the response data (Serial Number)
            request.value = Data((dataLogger.serialNumber ?? "00DL1234").utf8)
        case TransferService.batteryLevelCharacteristicUUID:
            // Set the response data (Battery percantage level)
            if let batteryLevel = dataLogger.batteryLevel {
                request.value = Data([UInt8(batteryLevel)])
            } else {
                request.value = Data([UInt8.random(in: 0...100)])
            }
        case TransferService.batteryStatusCharacteristicUUID:
            // Set the response data (Battery discharging status)
            if dataLogger.isChargingBattery == true {
                request.value = Data([1])
            } else if dataLogger.isChargingBattery == false {
                request.value = Data([0])
            } else {
                request.value = Data([UInt8.random(in: 0...1)])
            }
        case TransferService.locationAndSpeedCharacteristicUUID:
            // Set the response data
            if let speed = dataLogger.speed, let location = dataLogger.location {
                request.value = Data([3] +  // Flags (Speed and Location is present)
                                     UInt16(speed*100).littleEndian.bytes + // Speed in 10^-2m/s
                                     UInt32(location.latitude * 10_000_000).littleEndian.bytes + // Latitude in 10^-7deg
                                     UInt32(location.longitude * 10_000_000).littleEndian.bytes) // Longitude in 10^-7deg
            } else {
                // (Random speed between 0m/s and 100m/s || Location of Knowit's Warsaw office)
                request.value = Data([3] +  // Flags (Speed and Location is present)
                                     UInt16.random(in: 0...100_00).littleEndian.bytes + // Speed in 10^-2m/s
                                     UInt32(52_2303300).littleEndian.bytes + // Latitude in 10^-7deg
                                     UInt32(20_9804600).littleEndian.bytes) // Longitude in 10^-7deg
            }
        default:
            // Send the response
            print("Sending a bad response for: \(request.characteristic.uuid)")
            peripheral.respond(to: request, withResult: .attributeNotFound)
            return
        }
        // Send the response
        peripheral.respond(to: request, withResult: .success)
    }
    
    /// Function used for sending data as a result of notify functionality for generic logger characteristic
    private func sendData() {
        guard let transferCharacteristic = loggerTransferCharacteristic else {
            return
        }
        
        guard peripheralManager.updateValue(Data([0, 1, UInt8.random(in: 0...255)]), for: transferCharacteristic, onSubscribedCentrals: nil) else {
            print("Sending failed!")
            return
        }
    }
    
    /// Function used for sending updates of location and speed information when central subscribes for notifications
    private func sendLocationAndSpeed() {
        guard let transferCharacteristic = locationAndSpeedCharacteristic else {
            return
        }
        let data: Data
        switch Int.random(in: 0...2) {
        case 0:
            // Send all information, i.e. Speed and Location
            data = Data([3] + UInt16.random(in: 0...100_00).littleEndian.bytes + UInt32(52_2303300).littleEndian.bytes + UInt32(20_9804600).littleEndian.bytes)
        case 1:
            // Send only the speed information
            data = Data([1] + UInt16.random(in: 0...100_00).littleEndian.bytes)
        case 2:
            // Send only the location information
            data = Data([2] + UInt32(52_2303300).littleEndian.bytes + UInt32(20_9804600).littleEndian.bytes)
        default:
            fatalError()
        }
        guard peripheralManager.updateValue(data, for: transferCharacteristic, onSubscribedCentrals: nil) else {
            print("Sending failed!")
            return
        }
    }
    
    private func sendBatteryLevel() {
        guard let transferCharacteristic = batteryLevelCharacteristic else {
            return
        }
        guard peripheralManager.updateValue(Data([UInt8.random(in: 0...100)]), for: transferCharacteristic, onSubscribedCentrals: nil) else {
            print("Sending failed!")
            return
        }
    }
    
    private func sendBatteryStatus() {
        guard let transferCharacteristic = batteryChargingCharacteristic else {
            return
        }
        let data: Data
        switch Int.random(in: 0...3) {
        case 0:
            data = Data([1])
        default:
            data = Data([0])
        }
        guard peripheralManager.updateValue(data, for: transferCharacteristic, onSubscribedCentrals: nil) else {
            print("Sending failed!")
            return
        }
    }
}
