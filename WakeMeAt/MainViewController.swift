//
//  MainViewController.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 11/17/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var myPin: MKPinAnnotationView!
    var settingsViewController = SettingsViewController()
    var radius: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WakeMeAt"
        mapView.showsUserLocation = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // How accurate
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
        
        radius = settingsViewController.radiusValue
    }
    
    
    func dropPin(location: CLLocation) {
        let coord: CLLocationCoordinate2D = location.coordinate
        let pin = MKPointAnnotation()
        pin.coordinate = coord
        pin.title = "Destination" // Add address of inputted destination
        
        mapView.addAnnotation(pin)
        
        alarmPending(userDestination: location)
    }
    
    // TODO: Add a button (or pop up) to start alarm and tracking of distance between current location and destiantion
    func alarmPending(userDestination: CLLocation) {
        let userLocation = mapView.userLocation.location // Coordinate of blue circle, user's location
        
        // Calculates how far user current location is from destination
        if userLocation?.coordinate != nil {
            let distanceInMeters = userDestination.distance(from: userLocation!)
        
            let distance = distanceInMeters / 1609.344
            print(distance)
            
            if Double(distance) <= Double(radius) {
                print("Alarm goes off")
            }
        }
    }
    
    // Have to override
    func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // Zooms in on current location
        let location = locations.last as! CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
        // TODO: Drop red pin on user's pick of destination. Right now drops on user's current location
        dropPin(location: location)
        
        //self.mapView.showsUserLocation = true
    
    }
}
