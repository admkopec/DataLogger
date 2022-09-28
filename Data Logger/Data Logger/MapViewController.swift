//
//  MapViewController.swift
//  Data Logger
//
//  Created by Adam Kopec on 16/09/2022.
//

import UIKit
import MapKit
import Combine

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var speedView: UIVisualEffectView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedUnitLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    private var speedUnit: UnitSpeed = .milesPerHour {
        didSet {
            switch speedUnit {
            case .kilometersPerHour:
                speedUnitLabel.text = "km/h"
            case .milesPerHour:
                speedUnitLabel.text = "mph"
            default:
                break
            }
        }
    }
    
    private var subscribers = [AnyCancellable]()
    private var annotation = CarLocation(coordinate: CLLocationCoordinate2DMake(0, 0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataLogger = (UIApplication.shared.delegate as! AppDelegate).dataLogger
        speedView.layer.masksToBounds = true
        speedView.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
        if dataLogger.isConnected {
            mapView.addAnnotation(annotation)
        }
        // Set proper init labels
        speedLabel.text = "0"
        
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
        
        let car = dataLogger.car
        let value = Measurement(value: car.speed, unit: UnitSpeed.metersPerSecond).converted(to: self.speedUnit)
        self.speedLabel.text = "\(Int(value.value))"
        self.annotation.coordinate = car.location
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // This theoretically can be only called in viewDidLoad, as sidebar/tabbar have separate instances of this view
        if tabBarController == nil {
            blurView.isHidden = true
        } else {
            blurView.isHidden = false
        }
        // Here we should start checking for updates of data logger connection
        let dataLogger = (UIApplication.shared.delegate as! AppDelegate).dataLogger
        dataLogger.$isConnected.receive(on: DispatchQueue.main).sink { isConnected in
            if isConnected {
                // Add the annotation to map view, we'll update the values later
                self.mapView.addAnnotation(self.annotation)
            } else if self.mapView.annotations.isEmpty == false {
                // Remove location and speed information
                self.mapView.removeAnnotation(self.annotation)
                self.speedLabel.text = "0"
            }
        }.store(in: &subscribers)
        // Here we should start checking updates of location and speed
        let car = (UIApplication.shared.delegate as! AppDelegate).dataLogger.car
        car.$speed.receive(on: DispatchQueue.main).sink { speed in
            let value = Measurement(value: speed, unit: UnitSpeed.metersPerSecond).converted(to: self.speedUnit)
            self.speedLabel.text = "\(Int(value.value))"
        }.store(in: &subscribers)
        car.$location.receive(on: DispatchQueue.main).sink { location in
            self.annotation.coordinate = location
        }.store(in: &subscribers)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Here we should cancel subscribers for view updates
        subscribers.forEach({ $0.cancel() })
        subscribers = []
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

class CarLocation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        "Your Car"
    }
    var subtitle: String? {
        "This is the current location of your car"
    }
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
