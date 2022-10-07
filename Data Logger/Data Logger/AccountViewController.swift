//
//  AccountViewController.swift
//  Data Logger
//
//  Created by Adam Kopec on 15/09/2022.
//

import UIKit

class AccountViewController: TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup Driver Classification cell
        if let driverCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DriverTableViewCell {
            driverCell.configure(basedOn: .good(avgSpeed: 80))
        }
        for cell in tableView.visibleCells {
            style(cell: cell)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
