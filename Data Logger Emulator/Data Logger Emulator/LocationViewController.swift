//
//  LocationViewController.swift
//  Data Logger Emulator
//
//  Created by Adam Kopec on 27/09/2022.
//

import Cocoa

class LocationViewController: NSViewController {
    var dataLogger: DataLogger!
    
    @IBOutlet weak var randomSwitch: NSSwitch!
    @IBOutlet weak var speedTextField: NSTextField!
    @IBOutlet weak var latitudeTextField: NSTextField!
    @IBOutlet weak var longitudeTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        // Set the view items based on BluetoothPeripheral configuration
        if let speed =  dataLogger.speed, let location = dataLogger.location {
            randomSwitch.state = .off
            speedTextField.isEnabled = true
            latitudeTextField.isEnabled = true
            longitudeTextField.isEnabled = true
            speedTextField.integerValue = speed / 1000
            latitudeTextField.doubleValue = location.latitude
            longitudeTextField.doubleValue = location.longitude
        } else {
            randomSwitch.state = .on
            speedTextField.isEnabled = false
            latitudeTextField.isEnabled = false
            longitudeTextField.isEnabled = false
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        // Set the preferences for BluetoothPeripheral
        setChanges()
    }
    
    /// The NSSwitch has changed its state
    @IBAction func randomiseChanged(_ sender: NSSwitch) {
        if sender.state == .on {
            speedTextField.isEnabled = false
            latitudeTextField.isEnabled = false
            longitudeTextField.isEnabled = false
        } else {
            speedTextField.isEnabled = true
            latitudeTextField.isEnabled = true
            longitudeTextField.isEnabled = true
        }
    }
    
    /// Push the changes to BluetoothPeripheral object
    func setChanges() {
        if speedTextField.isEnabled {
            // Set Speed in m/s
            dataLogger.speed = speedTextField.integerValue * 1000
            // Set location in degrees
            dataLogger.location = (latitudeTextField.doubleValue, longitudeTextField.doubleValue)
        } else {
            dataLogger.speed = nil
            dataLogger.location = nil
        }
    }
}
