//
//  DriverClass.swift
//  Data Logger
//
//  Created by Adam Kopec on 04/10/2022.
//

import Foundation

enum DriverClass {
    // Avg Speed is stored in m/s
    case good(avgSpeed: Double)
    case mediocare(avgSpeed: Double)
    case bad(avgSpeed: Double)
}
