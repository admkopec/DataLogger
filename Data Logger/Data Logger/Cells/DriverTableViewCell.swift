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
    
    private var speedUnit: UnitSpeed!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set proper units of measurement
        if #available(iOS 16, *) {
            if Locale.current.measurementSystem == .metric {
                speedUnit = .kilometersPerHour
            } else if [.uk, .us].contains(Locale.current.measurementSystem) {
                speedUnit = .milesPerHour
            }
        } else {
            // Fallback on earlier versions
            if Locale.current.usesMetricSystem {
                speedUnit = .kilometersPerHour
            } else {
                speedUnit = .milesPerHour
            }
        }
    }
    
    func configure(basedOn driverClass: DriverClass) -> Void {
        // Configure the cell based on provided driver class
        let unitString: String
        if speedUnit == .kilometersPerHour {
            unitString = "km/h"
        } else {
            unitString = "mph"
        }
        
        let speed: Double
        switch driverClass {
        case .good(let avgSpeed):
            iconView.image = UIImage(systemName: "checkmark.circle.fill")
            iconView.tintColor = .systemGreen
            titleLabel.text = "You are a good driver"
            speed = avgSpeed
        case .mediocare(let avgSpeed):
            iconView.image = UIImage(systemName: "exclamationmark.circle.fill")
            iconView.tintColor = .systemOrange
            titleLabel.text = "You are a mediocare driver"
            speed = avgSpeed
        case .bad(let avgSpeed):
            iconView.image = UIImage(systemName: "exclamationmark.circle.fill")
            iconView.tintColor = .systemRed
            titleLabel.text = "You are a bad driver"
            speed = avgSpeed
        }
        
        let value = Measurement(value: speed, unit: UnitSpeed.metersPerSecond).converted(to: self.speedUnit)
        detailLabel.text = "Your avg speed is \(Car.convert(speed: speed, to: speedUnit)) \(unitString)"
    }
}
