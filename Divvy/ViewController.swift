//
//  ViewController.swift
//  Divvy
//
//  Created by tbredemeier on 5/8/18.
//  Copyright © 2018 tbredemeier. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var myLocation = CLLocation()
    let locationManager = CLLocationManager()
    let query = "https://feeds.divvybikes.com/stations/stations.json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        myLocation = locations.first!
        let center = myLocation.coordinate
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
        if let url = URL(string: self.query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parse(json: json)
                return
            }
        }
        loadError()
    }

    func parse(json: JSON) {
        for result in json["stationBeanList"].arrayValue {
            let stationName = result["stationName"].stringValue
            let latitude = result["latitude"].doubleValue
            let longitude = result["longitude"].doubleValue
            let location = CLLocation(latitude: latitude,
                                      longitude: longitude)
            let distance = location.distance(from: myLocation) / 1609.34
            let availableBikes = result["availableBikes"].intValue
            let annotation = MKPointAnnotation()
            annotation.subtitle = String(format: "%d bikes\n%0.2f miles from here", availableBikes, distance)
            annotation.title = stationName
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
        }
    }

    func loadError() {
        let alert = UIAlertController(title: "Loading Error", message:
            "There was a problem loading the Divvy bike data",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


}

