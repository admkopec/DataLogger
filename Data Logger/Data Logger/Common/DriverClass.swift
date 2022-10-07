//
//  DriverClass.swift
//  Data Logger
//
//  Created by Adam Kopec on 04/10/2022.
//

import Foundation

enum DriverClass {
    case good(avgSpeed: Int)
    case mediocare(avgSpeed: Int)
    case bad(avgSpeed: Int)
}
