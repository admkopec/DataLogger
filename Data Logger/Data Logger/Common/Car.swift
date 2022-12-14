//
//  Car.swift
//  Data Logger
//
//  Created by Adam Kopec on 28/09/2022.
//

import Combine
import Foundation
import CoreLocation

class Car: ObservableObject {
    /// The current speed of the car in m/s
    @Published var speed: CLLocationSpeed = 0
    /// The current location of the car
    @Published var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    static func convert(speed: CLLocationSpeed, from unit: UnitSpeed = .metersPerSecond, to newUnit: UnitSpeed) -> Int {
        let value = Measurement(value: speed, unit: unit).converted(to: newUnit)
        return Int(value.value)
    }
}
