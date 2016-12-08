//
//  LocationSearchTable.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 12/8/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
    var matchingItmes:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        let firstSpace = ((selectedItem.subThoroughfare != nil) && (selectedItem.thoroughfare != nil)) ? " " : ""
        let comma = (((selectedItem.subThoroughfare != nil) || (selectedItem.thoroughfare != nil)) && ((selectedItem.subAdministrativeArea != nil) || (selectedItem.administrativeArea != nil))) ? ", " : ""
        let secondSpace = ((selectedItem.subAdministrativeArea != nil) && (selectedItem.administrativeArea != nil)) ? " " : ""
        let addressLine = String(format: "%@%@%@%@%@%@%@", selectedItem.subThoroughfare ?? "", firstSpace, selectedItem.thoroughfare ?? "", comma, selectedItem.locality ?? "", secondSpace, selectedItem.administrativeArea ?? "")
        return addressLine
    }
}

extension LocationSearchTable: UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else {
                return
        }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: {(response, error) in
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                let response = response
                self.matchingItmes = (response?.mapItems)!
                self.tableView.reloadData()
            }
            
        })
        
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        super.tableView(tableView, numberOfRowsInSection: section)
        return matchingItmes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        super.tableView(tableView, cellForRowAt: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItmes[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
       
        
        
        return (cell)
    }
}
