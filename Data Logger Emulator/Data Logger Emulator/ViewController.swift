//
//  ViewController.swift
//  BluetoothPeripherial
//
//  Created by Adam Kopec on 05/09/2022.
//

import Cocoa

class ViewController: NSViewController {
    private var bluetoothPeripheral: BluetoothPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is the only window of the app, so we can created the BluetoothPeripheral here
        bluetoothPeripheral = BluetoothPeripheral()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        // Stop advertising once the window closes
        bluetoothPeripheral.stopAdvertising()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }

    /// The user has toggled the advertising option
    @IBAction func startAdvertisingClicked(_ sender: NSButton) {
        if bluetoothPeripheral.isAdvertising {
            bluetoothPeripheral.stopAdvertising()
            sender.title = "Start advertising"
        } else {
            bluetoothPeripheral.startAdvertising()
            sender.title = "Stop advertising"
        }
    }
    
    /// Pass the BluetoothPeripheral object to the presented View Controller
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        (segue.destinationController as? LocationViewController)?.bluetoothPeripheral = bluetoothPeripheral
        (segue.destinationController as? DeviceInfoViewController)?.bluetoothPeripheral = bluetoothPeripheral
    }
}

