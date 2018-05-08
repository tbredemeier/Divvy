//
//  DetailViewController.swift
//  Divvy
//
//  Created by tbredemeier on 5/8/18.
//  Copyright © 2018 tbredemeier. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var station = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        let stationName = station["stationName"] as? String
        let latitude = station["latitude"] as! Double
        let longitude = station["longitude"] as! Double
        let distance = station["distance"] as! Double
        let availableBikes = station["availableBikes"] as! Int
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.title = stationName
        annotation.subtitle = String(format: "%d bikes\n%0.2f miles from here", availableBikes, distance)
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.mapView.showAnnotations(mapView.annotations, animated: true)
        locationManager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
