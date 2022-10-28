//
//  BluetoothController.swift
//  Car Simulator
//
//  Created by Adam Kopec on 07/09/2022.
//

import UIKit
import Combine
import CoreLocation
import CoreBluetooth
import BluetoothProtocol

class BluetoothController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: CoreBluetooth
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    
    private var loggerTransferCharacteristic: CBCharacteristic!
    
    private var dataLogger: DataLogger {
        (UIApplication.shared.delegate as! AppDelegate).dataLogger
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    /*
     *  We will inform centralManager that scanning should stop
     */
    func stopScan() {
        centralManager.stopScan()
    }
    
    /*
     *  We will first check if we are already connected to our counterpart
     *  Otherwise, scan for peripherals - specifically for our service's 128bit CBUUID
     */
    private func retrievePeripheral() {
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [TransferService.serviceUUID]))
        
        print("Found connected Peripherals with transfer service: \(connectedPeripherals)")
        
        if let connectedPeripheral = connectedPeripherals.last {
            print("Connecting to peripheral \(connectedPeripheral)")
            self.discoveredPeripheral = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    /*
     *  Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    private func cleanup() {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = discoveredPeripheral,
              case .connected = discoveredPeripheral.state else { return }
        
        for service in (discoveredPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.loggerCharacteristicUUID && characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    self.discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                    self.loggerTransferCharacteristic = nil
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
            retrievePeripheral()
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
#if DEBUG
            
#endif
            return
        @unknown default:
            print("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    /*
     *  This callback comes whenever a peripheral that is advertising the transfer serviceUUID is discovered.
     *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
     *  we start the connection process
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending on your app’s use case.
        guard RSSI.intValue >= -100
        else {
            print("Discovered perhiperal not in expected range, at \(RSSI.intValue)")
            return
        }
        
        print("Discovered \(String(describing: peripheral.name)) at \(RSSI.intValue)")
        
        // Device is in range - have we already seen it?
        if discoveredPeripheral != peripheral {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it.
            discoveredPeripheral = peripheral
            
            // And finally, connect to the peripheral.
            print("Connecting to perhiperal \(peripheral)")
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    /*
     *  If the connection fails for whatever reason, we need to deal with it.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral). \(String(describing: error))")
        cleanup()
    }
    
    /*
     *  We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        // Stop scanning
        centralManager.stopScan()
        print("Scanning stopped")
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([TransferService.serviceUUID,
                                     TransferService.deviceInfoServiceUUID,
                                     TransferService.batteryServiceUUID,
                                     TransferService.locationServiceUUID])
    }
    
    /*
     *  Once the disconnection happens, we need to clean up our local copy of the peripheral
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Perhiperal Disconnected")
        discoveredPeripheral = nil
        // Set disconnected status
        dataLogger.isConnected = false
        // We're disconnected, so start scanning again
        retrievePeripheral()
    }
    
    // MARK: - CBPeripheralDelegate
    
    /*
     *  The peripheral letting us know when services have been invalidated.
     */
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == TransferService.serviceUUID {
            print("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([TransferService.serviceUUID,
                                         TransferService.deviceInfoServiceUUID,
                                         TransferService.batteryServiceUUID,
                                         TransferService.locationServiceUUID])
            dataLogger.isConnected = false
        }
    }
    
    /*
     *  The Transfer Service was discovered
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            print("Discovered service with: \(service.uuid)")
            switch service.uuid {
            case TransferService.serviceUUID:
                peripheral.discoverCharacteristics([TransferService.loggerCharacteristicUUID],
                                                   for: service)
            case TransferService.deviceInfoServiceUUID:
                peripheral.discoverCharacteristics([TransferService.protocolVersionCharacteristicUUID,
                                                    TransferService.firmwareVersionCharacteristicUUID,
                                                    TransferService.serialNumberCharacteristicUUID],
                                                   for: service)
            case TransferService.batteryServiceUUID:
                peripheral.discoverCharacteristics([TransferService.batteryLevelCharacteristicUUID,
                                                    TransferService.batteryStatusCharacteristicUUID],
                                                   for: service)
            case TransferService.locationServiceUUID:
                peripheral.discoverCharacteristics([TransferService.locationAndSpeedCharacteristicUUID],
                                                   for: service)
            default:
                continue
            }
        }
    }
    
    /*
     *  The Transfer characteristic was discovered.
     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Deal with errors (if any).
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics {
            switch characteristic.uuid {
//            case TransferService.loggerCharacteristicUUID:
//                print("Attaching to logger notifier")
//                // If it is, subscribe to it
//                peripheral.setNotifyValue(true, for: characteristic)
//                loggerTransferCharacteristic = characteristic
            case TransferService.protocolVersionCharacteristicUUID,
                TransferService.firmwareVersionCharacteristicUUID,
                TransferService.serialNumberCharacteristicUUID:
                print("Attempting to read value")
                // Read the value
                peripheral.readValue(for: characteristic)
            case TransferService.batteryLevelCharacteristicUUID,
                TransferService.batteryStatusCharacteristicUUID,
                TransferService.locationAndSpeedCharacteristicUUID:
                print("Attempting to read value and subscribe for updates")
                // Read the value
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                continue
            }
        }
        
        // Once this is complete, we just need to wait for the data to come in.
    }
    
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else {
            // Deal with errors (if any)
            if let error = error {
                print("Error discovering characteristics: \(error.localizedDescription)")
            }
            cleanup()
            return
        }
        
        switch characteristic.uuid {
        case TransferService.protocolVersionCharacteristicUUID:
            handleProtocolVersion(data: value)
        case TransferService.firmwareVersionCharacteristicUUID:
            handleFirmwareVersion(data: value)
        case TransferService.serialNumberCharacteristicUUID:
            handleSerialNumber(data: value)
        case TransferService.batteryLevelCharacteristicUUID:
            handleBatteryLevel(data: value)
        case TransferService.batteryStatusCharacteristicUUID:
            handleBatteryChargeStatus(data: value)
        case TransferService.locationAndSpeedCharacteristicUUID:
            handleLocationAndSpeed(data: value)
        default:
            print("Unsupported characteristic returned value: \(value)")
        }
    }
    
    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.loggerCharacteristicUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            print("Notification began on \(characteristic)")
        } else {
            // Notification has stopped, so disconnect from the peripheral
            print("Notification stopped on \(characteristic). Disconnecting")
            cleanup()
        }
    }
    
    /*
     *  This is called when peripheral is ready to accept more data when using write without response
     */
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("Peripheral is ready, send data")
//        writeData()
    }
    
    func writeEmulated(data: Data) {
        // TODO: Wait for peripheral
        discoveredPeripheral?.writeValue(data, for: loggerTransferCharacteristic, type: .withoutResponse)
    }
    
    // MARK: - Handlers
    
    // MARK: Device Service
    
    func handleProtocolVersion(data: Data) -> Void {
        let protocolVersion = String(data: data, encoding: .utf8) ?? "Null"
        print("Discovered prototcol version: \(protocolVersion)")
        // Disconnect if the protocol isn't supported by the application
        guard ["0.1", "1.0"].contains(protocolVersion) else { return cleanup() }
        // Set connected status once we know that the protocol is supported
        dataLogger.isConnected = true
    }
    
    func handleFirmwareVersion(data: Data) -> Void {
        let firmwareVersion = String(data: data, encoding: .utf8) ?? "Null"
        print("Discovered Data Logger's firmware version: \(firmwareVersion)")
        dataLogger.firmwareVersion = firmwareVersion
    }
    
    func handleSerialNumber(data: Data) -> Void {
        let serialNumber = String(data: data, encoding: .utf8) ?? "Null"
        print("Discovered Data Logger's serial number: \(serialNumber)")
        dataLogger.serialNumber = serialNumber
    }
    
    // MARK: Battery Service
    
    func handleBatteryLevel(data: Data) -> Void {
        print("Discovered Data Logger's battery level: \(data.first ?? 0)")
        dataLogger.batteryLevel = Int(data.first ?? 0)
    }
    
    func handleBatteryChargeStatus(data: Data) -> Void {
        if data.first == 0 {
            print("Discovered that Data Logger's battery is discharging")
            dataLogger.isCharging = false
        } else {
            print("Discovered that Data Logger's battery is charging")
            dataLogger.isCharging = true
        }
    }
    
    // MARK: Location Service
    
    func handleLocationAndSpeed(data: Data) -> Void {
        let flags = data[0]
        print("Discovered Car's location and speed: Flags: \(flags)")
        if (flags & 1) == 1 {
            let littleEndian = [data[1], data[2]].withUnsafeBytes {
                $0.load(as: UInt16.self)
            }
            let speed = Double(UInt16(littleEndian: littleEndian))/100
            print("Speed: \(speed) m/s")
            dataLogger.car.speed = speed
        }
        let littleEndianLat: UInt32
        let littleEndianLon: UInt32
        if (flags & 3) == 3 {
            littleEndianLat = [data[3], data[4], data[5], data[6]].withUnsafeBytes {
                $0.load(as: UInt32.self)
            }
            littleEndianLon = [data[7], data[8], data[9], data[10]].withUnsafeBytes {
                $0.load(as: UInt32.self)
            }
        } else if (flags & 2) == 2 {
            littleEndianLat = [data[1], data[2], data[3], data[4]].withUnsafeBytes {
                $0.load(as: UInt32.self)
            }
            littleEndianLon = [data[5], data[6], data[7], data[8]].withUnsafeBytes {
                $0.load(as: UInt32.self)
            }
        } else {
            return
        }
        let location = CLLocationCoordinate2D(latitude: Double(UInt32(littleEndian: littleEndianLat))/10_000_000, longitude: Double(UInt32(littleEndian: littleEndianLon))/10_000_000)
        print("Latitude: \(location.latitude) deg")
        print("Longitude: \(location.longitude) deg")
        dataLogger.car.location = location
    }
}
