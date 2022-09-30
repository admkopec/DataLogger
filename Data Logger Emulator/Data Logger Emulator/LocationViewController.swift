//
//  LocationViewController.swift
//  Data Logger Emulator
//
//  Created by Adam Kopec on 27/09/2022.
//

import Cocoa
import Combine

class LocationViewController: NSViewController, NSTextFieldDelegate {
    var dataLogger: DataLogger!
    private var subscriber: AnyCancellable?
    private var pauseUpdates = false
    
    @IBOutlet weak var randomSwitch: NSSwitch!
    @IBOutlet weak var speedTextField: NSTextField!
    @IBOutlet weak var latitudeTextField: NSTextField!
    @IBOutlet weak var longitudeTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        speedTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        subscriber = dataLogger.objectWillChange.receive(on: DispatchQueue.main).sink { _ in
            guard !self.pauseUpdates else { return }
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
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        pauseUpdates = true
        return true
    }
    
    @IBAction func valueSubmitted(_ sender: Any) {
        setChanges()
        pauseUpdates = false
    }
    
    /// The NSSwitch has changed its state
    @IBAction func randomiseChanged(_ sender: NSSwitch) {
        if sender.state == .on {
            dataLogger.randomLocation = true
            speedTextField.isEnabled = false
            latitudeTextField.isEnabled = false
            longitudeTextField.isEnabled = false
            // Set some random speed between 0 and 180 km/h
            speedTextField.integerValue = Int.random(in: 0...180)
            // Set the location of Knowit's Warsaw office
            latitudeTextField.doubleValue = 52.23033
            longitudeTextField.doubleValue = 20.98046
        } else {
            dataLogger.randomLocation = false
            speedTextField.isEnabled = true
            latitudeTextField.isEnabled = true
            longitudeTextField.isEnabled = true
        }
    }
    
    func updateViewBasedOn(dataLogger: DataLogger) {
        speedTextField.integerValue = Int((Double(dataLogger.speed) * 3.6).rounded())
        latitudeTextField.doubleValue = dataLogger.location.latitude
        longitudeTextField.doubleValue = dataLogger.location.longitude
        if dataLogger.randomLocation == false {
            randomSwitch.state = .off
            speedTextField.isEnabled = true
            latitudeTextField.isEnabled = true
            longitudeTextField.isEnabled = true
        } else {
            randomSwitch.state = .on
            speedTextField.isEnabled = false
            latitudeTextField.isEnabled = false
            longitudeTextField.isEnabled = false
        }
    }
    
    /// Push the changes to BluetoothPeripheral object
    func setChanges() {
        // Set Speed in m/s
        dataLogger.speed = Int((speedTextField.doubleValue / 3.6).rounded())
        // Set location in degrees
        dataLogger.location = (latitudeTextField.doubleValue, longitudeTextField.doubleValue)
    }
}
