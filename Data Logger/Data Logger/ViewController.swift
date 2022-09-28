//
//  ViewController.swift
//  Data Logger
//
//  Created by Adam Kopec on 13/09/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            do {
                self.label.text = try await getAppleIDName()
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

