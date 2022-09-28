//
//  TableViewController.swift
//  Data Logger
//
//  Created by Adam Kopec on 13/09/2022.
//

import UIKit

class TableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .systemBackground
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }
    
    func style(cell: UITableViewCell) {
        if traitCollection.userInterfaceStyle != .dark {
            cell.backgroundColor = .systemGroupedBackground
        } else {
            cell.backgroundColor = .secondarySystemGroupedBackground
        }
    }
}
