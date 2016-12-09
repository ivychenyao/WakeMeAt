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
import GooglePlaces
import GooglePlacePicker

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MainViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate, HandleMapSearch {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchLocationButton: UIButton!
    
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    
    var locationManager: CLLocationManager = CLLocationManager()
    var myPin: MKPinAnnotationView!
    var settingsViewController = SettingsViewController()
    var radius: Double!
    var alarm = AVAudioPlayer()
    var volume: Float!
    var vibration: Float!
    var snooze: Double!
    var makeAlarmPend = false
    var placesClient: GMSPlacesClient!
    var playAlarmBoolean = true
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WakeMeAt"
        //placesClient = GMSPlacesClient.shared()
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
            settingsViewController.alarmBuzzerPlayer = try AVAudioPlayer(contentsOf: settingsViewController.alarmBuzzerURL as URL)
            settingsViewController.policeSirenPlayer = try AVAudioPlayer(contentsOf: settingsViewController.policeSirenURL as URL)
            settingsViewController.doorbellPlayer = try AVAudioPlayer(contentsOf: settingsViewController.doorbellURL as URL)
            settingsViewController.ambulancePlayer = try AVAudioPlayer(contentsOf: settingsViewController.ambulanceURL as URL)
            settingsViewController.hornHonkPlayer = try AVAudioPlayer(contentsOf: settingsViewController.hornHonkURL as URL)
            settingsViewController.fireAlarmPlayer = try AVAudioPlayer(contentsOf: settingsViewController.fireAlarmURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        radius = settingsViewController.radiusValue
        
        if let tryAlarm = settingsViewController.alarmSound {
            alarm = tryAlarm
        } else {
            alarm = settingsViewController.alarmBuzzerPlayer
        }
        
        if let tryVolume = settingsViewController.alarmSound?.volume {
            volume = tryVolume
        } else {
            volume = 0.5
        }
        
        // TODO: Could just call setVibration() in SettingsView instead to make phone vibrate when arrived?
        if let tryVibration = settingsViewController.vibrationSlider?.value {
            vibration = tryVibration
        } else {
            vibration = 0.5
        }
        
        if let trySnooze = settingsViewController.stepper?.value {
            // snooze = trySnooze
            snooze = 1.0
        } else {
            snooze = 5.0
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
        let city = placemark.locality
        let state = placemark.administrativeArea
        annotation.subtitle = "\(city!) \(state!)"
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        let myUserDestination = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        
        alarmPending(userDestination: myUserDestination)
    }
    
   /* func dropPin(location: CLLocation) {
        // makeAlarmPend = false
        self.mapView.removeAnnotations(self.mapView.annotations) // Deletes any previously dropped pins -- ANNOTATION DELETED BUT alarmPending() still runs on. Tried to add boolean makeAlarmPend but that didn't work well
        let coord: CLLocationCoordinate2D = location.coordinate
        let pin = MKPointAnnotation()
        pin.coordinate = coord
        pin.title = "Destination" // Add address of inputted destination
        
        mapView.addAnnotation(pin)
        
        
        
        
        
        // makeAlarmPend = true
        alarmPending(userDestination: location)
    }*/
    
    // TODO: Add a button (or pop up) to start alarm and tracking of distance between current location and destination
    func alarmPending(userDestination: CLLocation) {
        let userLocation = mapView.userLocation.location // Coordinate of blue circle, user's location
        
        // Calculates how far user current location is from destination
        if playAlarmBoolean == true {
            if userLocation?.coordinate != nil {
                let distanceInMeters = userDestination.distance(from: userLocation!)
        
                let distance = distanceInMeters / 1609.344
                print(distance)
            
                if Double(distance) <= Double(radius) {
                    print("Alarm goes off")
                    playAlarm()
                }
            }
        }
    }
    
    func playAlarm() {
        if playAlarmBoolean == true {
            settingsViewController.playChosenSound(chosenSound: alarm, numLoops: -1) // -1 plays sound in never ending loop
        
            let hereAlert = UIAlertController(title: "YOU HAVE ARRIVED", message: "You are now \(radius!) mi away from your destination", preferredStyle:.alert)
            let okOption = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in self.okOptionClicked(hereAlert: hereAlert)})
            hereAlert.addAction(okOption)
            
            let snoozeOption = UIAlertAction(title: "Snooze for \(snooze!) min", style: UIAlertActionStyle.destructive, handler: {(UIAlertAction) in self.snoozeOptionClicked(hereAlert: hereAlert)})
            hereAlert.addAction(snoozeOption)
        
            self.present(hereAlert, animated: true, completion: nil)
        }
    }
    
    func okOptionClicked(hereAlert: UIAlertController) {
        print("Done")
        playAlarmBoolean = false
        hereAlert.dismiss(animated: false, completion: nil)
        settingsViewController.stopSound()
    }
    
    func aye() {
        print("halp lol f uckk")
    }
    
    func snoozeOptionClicked(hereAlert: UIAlertController) {
       // sleep(4058490328409238490)
        //Thread.sleep(forTimeInterval: 60)
        
        //Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(aye), userInfo: nil, repeats: false)
        
        //Timer.
        
        // this delays function being called, not has function play for tha tlong
        //DispatchQueue.main.asyncAfter(deadline: .now() + 4.3) {
       //     self.playAlarm()
       // }
    }
    

    func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // Zooms in on current location
        let location = locations.last as! CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
        // TODO: Drop red pin on user's pick of destination. Right now drops on user's current location
        //dropPin(location: location)
        
        let NYLocation = CLLocation(latitude: 40.7128, longitude: 74.0059)
        //dropPin(location: NYLocation)
        
        //self.mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    
}

