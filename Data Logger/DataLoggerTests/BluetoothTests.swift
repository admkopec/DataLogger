//
//  BluetoothTests.swift
//  DataLoggerTests
//
//  Created by Adam Kopec on 19/10/2022.
//

import XCTest
import CoreBluetooth
@testable import Data_Logger

final class BluetoothTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        (UIApplication.shared.delegate as! AppDelegate).bluetoothController = BluetoothController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDeviceInfoHandling() {
        let dataLogger = (UIApplication.shared.delegate as! AppDelegate).dataLogger
        let controller: BluetoothController = (UIApplication.shared.delegate as! AppDelegate).bluetoothController

        // Device Info
        let protocolVersion = "1.0"
        let firmwareVersion = "1.0"
        let serialNumber = "XCTest01234"
        controller.handleProtocolVersion(data: Data(protocolVersion.utf8))
        // TODO: Verify this somehow
        controller.handleFirmwareVersion(data: Data(firmwareVersion.utf8))
        XCTAssert(dataLogger.firmwareVersion == firmwareVersion)
        controller.handleSerialNumber(data: Data(serialNumber.utf8))
        XCTAssert(dataLogger.serialNumber == serialNumber)
    }
    
    func testBatteryHandling() {
        let dataLogger = (UIApplication.shared.delegate as! AppDelegate).dataLogger
        let controller: BluetoothController = (UIApplication.shared.delegate as! AppDelegate).bluetoothController

        // Battery
        let batteryLevel = 67 as UInt8
        // Charging status
        controller.handleBatteryChargeStatus(data: Data([0]))
        XCTAssert(dataLogger.isCharging == false)
        controller.handleBatteryChargeStatus(data: Data([1]))
        XCTAssert(dataLogger.isCharging == true)
        // Battery level
        controller.handleBatteryLevel(data: Data([batteryLevel]))
        XCTAssert(dataLogger.batteryLevel == batteryLevel)
    }
    
    func testLocationAndSpeedHandling() {
        let dataLogger = (UIApplication.shared.delegate as! AppDelegate).dataLogger
        let controller: BluetoothController = (UIApplication.shared.delegate as! AppDelegate).bluetoothController

        // Location and Speed
        var location = (latitude: 52.23033, longitude: 20.98046)
        var speed = 600.0
        // Send all information, i.e. Speed and Location
        controller.handleLocationAndSpeed(data: Data([3] + UInt16(speed*100).littleEndian.bytes + UInt32(location.latitude * 10_000_000).littleEndian.bytes + UInt32(location.longitude * 10_000_000).littleEndian.bytes))
        XCTAssert(dataLogger.car.location.longitude == location.longitude && dataLogger.car.location.latitude == location.latitude)
        XCTAssert(dataLogger.car.speed == speed)
        
        speed = 500.0
        // Send only the speed information
        controller.handleLocationAndSpeed(data: Data([1] + UInt16(speed*100).littleEndian.bytes))
        XCTAssert(dataLogger.car.speed == speed)
        
        location = (latitude: 52.23040, longitude: 20.98050)
        // Send only the location information
        controller.handleLocationAndSpeed(data: Data([2] + UInt32(location.latitude * 10_000_000).littleEndian.bytes + UInt32(location.longitude * 10_000_000).littleEndian.bytes))
        XCTAssert(dataLogger.car.location.longitude == location.longitude && dataLogger.car.location.latitude == location.latitude)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
