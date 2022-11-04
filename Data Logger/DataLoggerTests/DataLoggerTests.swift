//
//  DataLoggerTests.swift
//  DataLoggerTests
//
//  Created by Adam Kopec on 19/10/2022.
//

import XCTest
import MapKit
@testable import Data_Logger

final class DataLoggerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMapView() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let speedLabel = UILabel()
        let speedUnitLabel = UILabel()
        let speedView = UIVisualEffectView()
        let blurView = UIVisualEffectView()
        let mapView = MKMapView(frame: .zero)
        
        let mapVC = MapViewController()
        mapVC.speedLabel = speedLabel
        mapVC.speedUnitLabel = speedUnitLabel
        mapVC.speedView = speedView
        mapVC.blurView = blurView
        mapVC.mapView = mapView
        
        let dataLogger = (UIApplication.shared.delegate as! AppDelegate).dataLogger
        dataLogger.isConnected = false
        dataLogger.car.speed = 30
        
        mapVC.viewDidLoad()
        XCTAssert(mapVC.mapView.annotations.isEmpty)
        if mapVC.speedUnitLabel.text == "mph" {
            XCTAssert(mapVC.speedLabel.text == "67")
        } else {
            XCTAssert(mapVC.speedLabel.text == "108")
        }
        
        mapVC.viewWillAppear(true)
        
        dataLogger.car.speed = 70
        
        wait(for: 0.5)
        
        if mapVC.speedUnitLabel.text == "mph" {
            XCTAssert(mapVC.speedLabel.text == "156")
        } else {
            XCTAssert(mapVC.speedLabel.text == "251")
        }
        
        dataLogger.car.location = CLLocationCoordinate2D(latitude: 28.5, longitude: 5.07)
        dataLogger.isConnected = true
        wait(for: 0.5)
        
        XCTAssert(mapVC.mapView.annotations.contains(where: { $0.coordinate.latitude == dataLogger.car.location.latitude && $0.coordinate.longitude == dataLogger.car.location.longitude }))
        XCTAssert(mapVC.mapView.annotations.count == 1)
        
        mapVC.viewWillDisappear(true)
    }
    
    func testConversions() {
        let speed = 70.0
        XCTAssert(Car.convert(speed: speed, to: .kilometersPerHour) == 251)
        XCTAssert(Car.convert(speed: speed, to: .milesPerHour) == 156)
    }
    
    func testDriverCell() {
        let label1 = UILabel()
        let label2 = UILabel()
        let imageView = UIImageView()
        let driverCell = DriverTableViewCell()
        driverCell.iconView = imageView
        driverCell.titleLabel = label1
        driverCell.detailLabel = label2
        driverCell.awakeFromNib()
        driverCell.configure(basedOn: .good(avgSpeed: 70))
        XCTAssert(driverCell.iconView.image == UIImage(systemName: "checkmark.circle.fill"))
        XCTAssert(driverCell.titleLabel.text?.localizedCaseInsensitiveContains("good") == true)
        if Locale.current.measurementSystem == .metric {
            XCTAssert(driverCell.detailLabel.text?.localizedCaseInsensitiveContains("251 km/h") == true)
        } else {
            XCTAssert(driverCell.detailLabel.text?.localizedCaseInsensitiveContains("156 mph") == true)
        }
    }
    
    @discardableResult
    func wait(for seconds: TimeInterval) -> XCTWaiter.Result {
        let exp = expectation(description: "Resume testing after \(seconds) seconds")
        return XCTWaiter.wait(for: [exp], timeout: 2.0)
    }
}
