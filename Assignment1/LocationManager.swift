//
//  LocationManager.swift
//  Assignment1
//
//  Created by Jovanka Milosevic on 2022-11-02.
//  Email: milosevj@sheridancollege.ca
//
//  Description: The class that is used to get users current location and track changes in their location.
//

import Foundation
import CoreLocation

//ViewModel to hold the user location data
class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject
{
        @Published var location = CLLocation()
        @Published var userTracking = true
        let locationManager = CLLocationManager()
    
    override init()
    {
            super.init()

            // get the current user location
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation() //if user allowed it, start updating location
            userTracking = true
        }
    }
    
    func startTracking()
    {
        locationManager.startUpdatingLocation()
        userTracking = true
    }

    func stopTracking()
    {
            locationManager.stopUpdatingLocation()
            userTracking = false
    }
    
    // delegates for LocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // get the current location
        if let location = locations.last
        {
            self.location = location
        }
    }
}

