//
//  MapViewController.swift
//  WA
//
//  Created by alekseienko on 26.10.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,CLLocationManagerDelegate,UIGestureRecognizerDelegate {
   
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    // MARK: - PROPERTIES
    let locationManager = CLLocationManager()
    var weatherCoordinate: CLLocationCoordinate2D?
    var isAnimation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handLongTapGesture(gestureRecognizer:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        self.mapView.addGestureRecognizer(longTapGesture)
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    // MARK: - RESET ANIMATION
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        isAnimation = false
    }
    // MARK: - SETUP POINT
    @objc func handLongTapGesture(gestureRecognizer: UILongPressGestureRecognizer ) {
        if mapView.annotations.count <= 2 {
            if gestureRecognizer.state != UIGestureRecognizer.State.ended {
                let touchLocation = gestureRecognizer.location(in: mapView)
                let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
                print("lat:",locationCoordinate.latitude, "lon",locationCoordinate.longitude)
                let pin = MKPointAnnotation()
                pin.coordinate = locationCoordinate
                pin.title = "Weather here"
                mapView.addAnnotation(pin)
                weatherCoordinate = locationCoordinate
            }
            if gestureRecognizer.state != UIGestureRecognizer.State.began {
                return
            }
        }
    }
    // MARK: - GET LOCATION
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: center, span: span)
        if isAnimation {
            mapView.setRegion(region, animated: true)
        }
        mapView.showsUserLocation = true
    }
    // MARK: - PASS DATA
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        if weatherCoordinate != nil {
            vc.weatherCoordinate = weatherCoordinate
        } else {
            vc.weatherCoordinate = locationManager.location?.coordinate
        }
    }
}
