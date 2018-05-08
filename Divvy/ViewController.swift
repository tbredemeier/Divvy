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

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    var stations = [[String: Any]]()
    var myLocation = CLLocation()
    let locationManager = CLLocationManager()
    let query = "https://feeds.divvybikes.com/stations/stations.json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
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
            let station = ["stationName": stationName, "availableBikes":
                availableBikes, "latitude": latitude, "longitude": longitude,
                                "distance": distance] as [String: Any]
            stations.append(station)
        }
        stations.sort { ($0["distance"]! as! Double) < ($1["distance"]! as! Double) }
    }

    func loadError() {
        let alert = UIAlertController(title: "Loading Error", message:
            "There was a problem loading the Divvy bike data",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        let station = stations[indexPath.row]
        cell.textLabel?.text = station["stationName"] as? String
        let distance = station["distance"] as! Double
        let availableBikes = station["availableBikes"] as! Int
        cell.detailTextLabel?.text = String(format: "%d bikes %0.2f miles from here", availableBikes, distance)
            return cell
    }

    @IBAction func onChangedSelector(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tableView.isHidden = true
        }
        else {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! DetailViewController
        let index = tableView.indexPathForSelectedRow?.row
        dvc.station = stations[index!]
    }

}

