//
//  ViewController.swift
//  MapProject
//
//  Created by v.milchakova on 21.06.2021.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager = CLLocationManager()
    var pickupCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), latitudinalMeters: 10000, longitudinalMeters: 10000)
            let TourEiffel = Place(title: "Tour Eiffel", coordinate: CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945), info: "The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, France. It is named after the engineer Gustave Eiffel, whose company designed and built the tower.")
            let SacréCoeur = Place(title: "SacréCoeur", coordinate: CLLocationCoordinate2D(latitude: 48.8867, longitude: 2.3431), info: "The Basilica of the Sacred Heart of Paris, commonly known as Sacré-Cœur Basilica, is a Roman Catholic church and minor basilica in Paris, France, dedicated to the Sacred Heart of Jesus.")
            let ArcDeTriomphe = Place(title: "Arc De Triomphe", coordinate: CLLocationCoordinate2D(latitude: 48.8738, longitude: 2.2950), info: "Arc De Triomphe is one of the most famous monuments in Paris, France, standing at the western end of the Champs-Élysées at the centre of Place Charles de Gaulle, formerly named Place de l'Étoile")
        
        mapView.setRegion(region, animated: true)
                mapView.addAnnotation(TourEiffel)
                mapView.addAnnotation(SacréCoeur)
                mapView.addAnnotation(ArcDeTriomphe)

    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let sourceAnnotation = MKPointAnnotation()

        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }

        let destinationAnnotation = MKPointAnnotation()

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile

        // Calculate the direction
        let directions = MKDirections(request: directionRequest)

        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }

            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    @objc func pinLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if let pickup = pickupCoordinate, let destination = destinationCoordinate {
            showRouteOnMap(pickupCoordinate: pickup, destinationCoordinate: destination)
        }
        if gestureRecognizer.state == .began {
            
            let startPoint = gestureRecognizer.location(in: self.mapView)
            let touchCoordinate = self.mapView.convert(startPoint, toCoordinateFrom: self.mapView)
            
            if pickupCoordinate == nil {
                pickupCoordinate = CLLocationCoordinate2D(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            } else {
                destinationCoordinate = CLLocationCoordinate2D(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            }

            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Точка"
            annotation.subtitle = "Новая точка на карте"
            
            self.mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    class Place: NSObject, MKAnnotation {
        var title: String?
        var coordinate: CLLocationCoordinate2D
        var info: String
        
        init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
            self.title = title
            self.coordinate = coordinate
            self.info = info
        }
        
    }
}

