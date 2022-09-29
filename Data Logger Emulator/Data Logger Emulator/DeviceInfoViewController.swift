//
//  DeviceInfoViewController.swift
//  Data Logger Emulator
//
//  Created by Adam Kopec on 27/09/2022.
//

import Cocoa
import Combine

class DeviceInfoViewController: NSViewController {
    var dataLogger: DataLogger!
    private var subscriber: AnyCancellable?
    
    @IBOutlet weak var firmwareTextField: NSTextField!
    @IBOutlet weak var serialNumberTextField: NSTextField!
    @IBOutlet weak var batteryLevelLabel: NSTextField!
    @IBOutlet weak var randomSwitch: NSSwitch!
    @IBOutlet weak var batteryLevelTextField: NSTextField!
    @IBOutlet weak var isChargingButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        subscriber = dataLogger.objectWillChange.receive(on: DispatchQueue.main).sink { _ in
            self.updateViewBasedOn(dataLogger: self.dataLogger)
        }
        // Set the view items based on BluetoothPeripheral configuration
        updateViewBasedOn(dataLogger: dataLogger)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        // Unsubscribe
        subscriber?.cancel()
        // Set the preferences for BluetoothPeripheral
        setChanges()
    }
    
    /// The NSSwitch has changed its state
    @IBAction func randomiseChanged(_ sender: NSSwitch) {
        if sender.state == .on {
            // Use random values
            isChargingButton.isEnabled = false
            batteryLevelTextField.isEnabled = false
            batteryLevelLabel.textColor = .placeholderTextColor
        } else {
            // Use user provided values
            isChargingButton.isEnabled = true
            batteryLevelTextField.isEnabled = true
            batteryLevelLabel.textColor = .labelColor
        }
    }
    
    func updateViewBasedOn(dataLogger: DataLogger) {
        if let firmware = dataLogger.firmwareVersion {
            firmwareTextField.stringValue = firmware
        }
        if let serialNumber = dataLogger.serialNumber {
            serialNumberTextField.stringValue = serialNumber
        }
        if let batteryLevel = dataLogger.batteryLevel, let isCharging = dataLogger.isChargingBattery {
            randomSwitch.state = .off
            batteryLevelLabel.textColor = .labelColor
            batteryLevelTextField.isEnabled = true
            isChargingButton.isEnabled = true
            batteryLevelTextField.integerValue = batteryLevel
            isChargingButton.state = isCharging ? .on : .off
        } else {
            randomSwitch.state = .on
            batteryLevelLabel.textColor = .placeholderTextColor
            batteryLevelTextField.isEnabled = false
            isChargingButton.isEnabled = false
        }
    }
    
    /// Push the changes to BluetoothPeripheral object
    func setChanges() {
        if firmwareTextField.stringValue.isEmpty {
            dataLogger.firmwareVersion = nil
        } else {
            dataLogger.firmwareVersion = firmwareTextField.stringValue
        }
        if serialNumberTextField.stringValue.isEmpty {
            dataLogger.serialNumber = nil
        } else {
            dataLogger.serialNumber = serialNumberTextField.stringValue
        }
        
        if batteryLevelTextField.isEnabled {
            dataLogger.batteryLevel = batteryLevelTextField.integerValue
            dataLogger.isChargingBattery = isChargingButton.state == .on
        } else {
            dataLogger.batteryLevel = nil
            dataLogger.isChargingBattery = nil
        }
    }
}
