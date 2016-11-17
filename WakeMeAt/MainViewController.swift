//
//  MainViewController.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 11/17/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController,MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var myPin:MKPinAnnotationView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        dropPin(latitude: 40.730872, longitude: -74.002066)

    }
    
    
    func dropPin(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "title"
        
        mapView.addAnnotation(pin)
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
