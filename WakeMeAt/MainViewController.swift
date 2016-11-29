//
//  MainViewController.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 11/17/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var myPin:MKPinAnnotationView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WakeMeAt"
        mapView.showsUserLocation = true
        
        // How accurate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
    }
    
    
    func dropPin(location: CLLocation) {
        let pin = MKPointAnnotation()
        let coord: CLLocationCoordinate2D = location.coordinate
        pin.coordinate = coord
        pin.title = "Destination" // Add address of inputted destination
        
        mapView.addAnnotation(pin)
    }

    // Have to override
    func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // Zooms in on current location
        let location = locations.last as! CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        dropPin(location: location) // Drop red pin on current location (CHANGE TO DESTINATION)
        
        //self.mapView.showsUserLocation = true
    
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
