//
//  LocationViewController.swift
//  Data Logger Emulator
//
//  Created by Adam Kopec on 27/09/2022.
//

import Cocoa
import Combine

class LocationViewController: NSViewController {
    var dataLogger: DataLogger!
    private var subscriber: AnyCancellable?
    
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
            speedTextField.isEnabled = false
            latitudeTextField.isEnabled = false
            longitudeTextField.isEnabled = false
        } else {
            speedTextField.isEnabled = true
            latitudeTextField.isEnabled = true
            longitudeTextField.isEnabled = true
        }
    }
    
    func updateViewBasedOn(dataLogger: DataLogger) {
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
