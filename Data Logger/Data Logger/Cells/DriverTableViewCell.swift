//
//  DriverTableViewCell.swift
//  Data Logger
//
//  Created by Adam Kopec on 04/10/2022.
//

import UIKit

class DriverTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(basedOn driverClass: DriverClass) -> Void {
        // TODO: Configure the cell based on provided driver class
    }
}
