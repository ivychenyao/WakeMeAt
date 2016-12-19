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
    
    var userCurrentLocation: CLLocation? = nil
    var userDestination: CLLocation? = nil
    var counter = 0
    var snoozeAlarmBoolean = false
    
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
        
        UserDefaults.standard.set(false, forKey: "Settings did load")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If user didn't allow Location Services to be enabled, pop-up notification asks user to allow
        if CLLocationManager.authorizationStatus() == .denied {
            let locationServicesDeniedAlarm = UIAlertController(title: "Location services were previously denied", message: "Please enable location services for this app in Settings", preferredStyle: .alert)
            let goToSettings = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            
            let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            locationServicesDeniedAlarm.addAction(goToSettings)
            locationServicesDeniedAlarm.addAction(cancelAlert)
            self.present(locationServicesDeniedAlarm, animated: true, completion: nil)
        }
        
        // Only executes if user never went into Settings - ensures UserDefaults are default values and not all 0
        if UserDefaults.standard.bool(forKey: "Settings did load") == false {
            Settings.sharedInstance.setDefaults()
        }
    }

    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        resultSearchController?.searchBar.text = placemark.name // Changes search bar to display name of placemark
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        userDestination = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        playAlarmBoolean = true
    }
    
    func playAlarm() {
        snoozeAlarmBoolean = false
        if playAlarmBoolean == true {
            settingsViewController.playChosenSound(chosenSound: Sounds.sharedInstance.alarmSound, numLoops: -1) // -1 plays sound in never ending loop
            if Settings.sharedInstance.vibration > 0 {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // used to have AudioServicesPlayAlertSound
            }
            
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
        userDestination = nil
        hereAlert.dismiss(animated: false, completion: nil)
        settingsViewController.stopSound()
        distanceCounterLabel.text = "No destination set"
        resultSearchController?.searchBar.text = ""
        counter = 0
    }
    
    func snoozeOptionClicked(hereAlert: UIAlertController) {
        snoozeAlarmBoolean = true
        counter = 0 // Necessary?
        settingsViewController.stopSound()
        let deadlineTime = DispatchTime.now() + .seconds(60)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.playAlarm()
        })
    }
    
    // Zooms in on current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        userCurrentLocation = location
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
        if userDestination != nil {
            if playAlarmBoolean == true {
                UIApplication.shared.isIdleTimerDisabled = true
                let distanceInMeters = userDestination!.distance(from: userCurrentLocation!)
                
                let distance = distanceInMeters / 1609.344
                let distanceStr = String(format: "%.2f", distance)
                distanceCounterLabel.text = "\(distanceStr) mi away"
                
                if (Double(distance) <= Double(Settings.sharedInstance.radius)) && (snoozeAlarmBoolean == false) {
                    counter += 1
                    
                    if counter == 1 {
                        playAlarm()
                    }
                }
            }
        }
    }
}
