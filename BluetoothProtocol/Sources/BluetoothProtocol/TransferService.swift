//
//  TransferService.swift
//  BluetoothProtocol
//
//  Created by Adam Kopec on 26/09/2022.
//

import Foundation
import CoreBluetooth

public enum TransferService {
    public static let serviceUUID = CBUUID(string: "73F743B6-556E-47C2-99C0-FD638B20B2D2")
    public static let loggerCharacteristicUUID = CBUUID(string: "1F12D956-B545-448C-8E2D-80F471D59C39")
    
#if DEBUG
    // Due to the CoreBluetooth limitations, we have to use a different value
    public static let batteryServiceUUID = CBUUID(string: "016FC6F8-38F2-4C70-9E92-E9F338425516")
#else
    public static let batteryServiceUUID = CBUUID(string: "0x180F")
#endif
    public static let batteryLevelCharacteristicUUID = CBUUID(string: "0x2A19")
    public static let batteryStatusCharacteristicUUID = CBUUID(string: "0x2A1A")
    
#if DEBUG
    // Due to the CoreBluetooth limitations, we have to use a different value
    public static let deviceInfoServiceUUID = CBUUID(string: "5286D90F-445F-4494-BF4E-C3A282DC271C")
#else
    public static let deviceInfoServiceUUID = CBUUID(string: "0x180A")
#endif
    public static let serialNumberCharacteristicUUID = CBUUID(string: "0x2A25")
    public static let firmwareVersionCharacteristicUUID = CBUUID(string: "0x2A26") // Firmware Revision String
    public static let protocolVersionCharacteristicUUID = CBUUID(string: "0x2A28") // Software Revision String
    
    public static let locationServiceUUID = CBUUID(string: "0x1819")
    public static let locationAndSpeedCharacteristicUUID = CBUUID(string: "0x2A67")
}
