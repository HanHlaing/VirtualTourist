//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 26/09/2021.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController,MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Variables/Constants
    
    let regionKey = "key_region"
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setPersistedRegion()
        addGestureRecognizer()
        setUpFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        loadFetchedPins()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: - Actions
    
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            // Create location from pressed region
            let annotation = MKPointAnnotation()
            let touchLocation = sender.location(in: mapView)
            let location = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            annotation.coordinate = location
            
            getLocationNameAndSave(annotation)
        }
    }
    
    //MARK: - Private methods
    
    // Add long press gesture recognizer for the map
    func addGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action:#selector(self.longPressed(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        longPressGesture.delaysTouchesBegan = true
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    // Get location name by using geocoder and save pin
    func getLocationNameAndSave(_ annotation: MKPointAnnotation) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)) { placemarks, error in
            guard let placemark = placemarks?.first else {
                print("Error finding location name")
                return
            }
            annotation.title = placemark.name ?? "no name"
            annotation.subtitle = placemark.locality
            
            self.savePin(annotation)
        }
    }
    
    // Save the Pin in Core Data Stack
    func savePin(_ annotation: MKPointAnnotation) {
        
        let mainContext = self.dataController.viewContext
        let newPin = Pin(context: mainContext)
        mainContext.perform {
            newPin.title = annotation.title
            newPin.subtitle = annotation.subtitle
            newPin.longitude = annotation.coordinate.longitude
            newPin.latitude = annotation.coordinate.latitude
            try? mainContext.save()
        }
    }
    
    // Create a Map region from persistent dictionary
    func setPersistedRegion() {
        
        if let persistedRegion = UserDefaults.standard.dictionary(forKey: regionKey) as? [String: CLLocationDegrees] {
            let center = CLLocationCoordinate2D(latitude: persistedRegion["latitude"]!, longitude: persistedRegion["longitude"]!)
            let span = MKCoordinateSpan(latitudeDelta: persistedRegion["latitudeDelta"]!, longitudeDelta: persistedRegion["longitudeDelta"]!)
            let region = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func loadFetchedPins() {
        if let pins = fetchedResultsController.fetchedObjects {
            self.mapView.addAnnotations(pins)
        }
    }
    
    //MARK: - Delegate methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Save region in a dictionary to keep it persistent
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
        let mapRegion = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: regionKey)
    }
}

