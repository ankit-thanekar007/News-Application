//
//  LocationManager.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 08/02/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import CoreLocation
import UIKit

protocol LocationDelegate {
    func locationUpdatedTo(loc : CLLocation)
    func deniedLocation()
    func restrictedLocation()
}


class LocationManager: NSObject {
    
    private let manager = CLLocationManager.init()
    var currentLocation : CLLocation? {
        didSet {
            if let loc = currentLocation{
                delegate?.locationUpdatedTo(loc: loc)
            }
        }
    }
    var delegate : LocationDelegate?
    
    override init() {
        super.init()
        initializeLocationManager()
    }
    
    func initializeLocationManager() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }
    
    func processAuth(_ status : CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                manager.startUpdatingLocation()
            }
        case .restricted:
            delegate?.restrictedLocation()
        case .denied:
            delegate?.deniedLocation()
        @unknown default:
            delegate?.deniedLocation()
        }
    }
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        processAuth(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
}
