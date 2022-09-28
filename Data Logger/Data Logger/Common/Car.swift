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
    @Published var speed: CLLocationSpeed = 0
    @Published var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
}
