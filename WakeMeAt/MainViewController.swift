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
import MediaPlayer

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MainViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate, HandleMapSearch {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var distanceCounterLabel: UILabel!
    
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    
    var locationManager: CLLocationManager = CLLocationManager()
    var settingsViewController = SettingsViewController()
    var playAlarmBoolean = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WakeMeAt"
        mapView.showsUserLocation = true
    
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // How accurate
        locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
        
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Destination"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        do {
            Sounds.sharedInstance.alarmSound = try AVAudioPlayer(contentsOf: Sounds.sharedInstance.alarmSoundURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        let myUserDestination = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        
        alarmPending(userDestination: myUserDestination)
        playAlarmBoolean = true
    }
    
    func alarmPending(userDestination: CLLocation) {
//        let userLocation = mapView.userLocation.location // Coordinate of blue circle, user's location
        
        // Calculates how far user current location is from destination
        if playAlarmBoolean == true {
            let userLocation = mapView.userLocation.location // Coordinate of blue circle, user's location
            if userLocation?.coordinate != nil {
                let distanceInMeters = userDestination.distance(from: userLocation!)
        
                let distance = distanceInMeters / 1609.344
                let distanceStr = String(format: "%.2f", distance)
                distanceCounterLabel.text = "\(distanceStr) mi away"
            
                if Double(distance) <= Double(Settings.sharedInstance.radius) {
                    playAlarm()
                }
            }
        }
    }
    
    func playAlarm() {
        if playAlarmBoolean == true {
            settingsViewController.playChosenSound(chosenSound: Sounds.sharedInstance.alarmSound, numLoops: -1) // -1 plays sound in never ending loop
        
            let hereAlert = UIAlertController(title: "YOU HAVE ARRIVED", message: "You are now \(Settings.sharedInstance.radius!) mi away from your destination", preferredStyle:.alert)
            let okOption = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in self.okOptionClicked(hereAlert: hereAlert)})
            hereAlert.addAction(okOption)
            
            let snoozeOption = UIAlertAction(title: "Snooze for 1 minute", style: UIAlertActionStyle.destructive, handler: {(UIAlertAction) in self.snoozeOptionClicked(hereAlert: hereAlert)})
            hereAlert.addAction(snoozeOption)
        
            self.present(hereAlert, animated: true, completion: nil)
        }
    }
    
    func okOptionClicked(hereAlert: UIAlertController) {
        playAlarmBoolean = false
        hereAlert.dismiss(animated: false, completion: nil)
        settingsViewController.stopSound()
        distanceCounterLabel.text = "No destination set"
    }
    
    func snoozeOptionClicked(hereAlert: UIAlertController) {
        settingsViewController.stopSound()
        let deadlineTime = DispatchTime.now() + .seconds(60)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.playAlarm()
        })
    }
    
    // Zooms in on current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! //as! CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
    }
}
