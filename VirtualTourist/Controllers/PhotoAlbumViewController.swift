//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 29/09/2021.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelNoImage: UILabel!
    @IBOutlet weak var barButtonNewCollection: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //MARK: - Variables/Constants
    
    var pinSelected: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    let reuseId = "ImageViewCell"
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(activityIndicator)
        view.addSubview(labelNoImage)
        computeFlowLayout()
        setUpFetchedResultsController()
        setUpMapUI()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        computeFlowLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        mapView.removeAnnotation(pinSelected)
        fetchedResultsController = nil
    }
    
    //MARK: - Actions
    
    @IBAction func newCollection(_ sender: Any) {
        reloadPhotos()
    }
    
    //MARK: - Private methods
    
    func computeFlowLayout() {
        
        let space: CGFloat = 2.0
        
        let isPortrait = UIDevice.current.orientation.isValidInterfaceOrientation
        ? UIDevice.current.orientation.isPortrait
        : (view.frame.size.width < view.frame.size.height)
        
        let numOfCols: CGFloat = isPortrait ? 3.0 : 5.0
        let spacesBetweenCols = numOfCols - 1
        
        let portraitViewWidth = min(view.frame.size.width, view.frame.size.height)
        let landscapeViewWidth = max(view.frame.size.width, view.frame.size.height)
        let horizontalViewDimension = isPortrait ? portraitViewWidth : landscapeViewWidth
        
        let dimension = (horizontalViewDimension - (spacesBetweenCols * space)) / numOfCols
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // First delete album & disable newCollection button until download has finished
    func reloadPhotos() {
        
        deletePhotos()
        setButtonsUI(enable: false)
        FlickrClient.getPhotosByLocation(lat: pinSelected.latitude, lon: pinSelected.longitude) { response, error in
            guard let response = response else {
                self.setButtonsUI(enable: true)
                showError(message: Errors.flickrServer.localizedDescription, actualVC: self)
                return
            }
            
            for photoStruct in response.photos.photo {
                let mainContext = self.dataController.viewContext
                let imgPath = FlickrClient.getImgPath(photoStruct: photoStruct)
                mainContext.perform {
                    let photoInstance = FlickrClient.savePhotoURL(imgPath: imgPath, context: self.dataController.viewContext)
                    self.pinSelected.addToPhotos(photoInstance)
                    try? mainContext.save()
                }
            }
            self.setButtonsUI(enable: true)
        }
    }
    
    // Delete all the album if exists & save context
    func deletePhotos() {
        if pinSelected.photos?.count != 0 {
            let mainContext = dataController.viewContext
            if let photos = fetchedResultsController.fetchedObjects {
                for photo in photos {
                    mainContext.perform {
                        mainContext.delete(photo)
                        try? mainContext.save()
                    }
                }
            }
        }
    }
    
    func setButtonsUI(enable: Bool) {
        if enable {
            hideActivityIndicator()
            barButtonNewCollection.isEnabled = true
            view.isUserInteractionEnabled = true
        } else {
            barButtonNewCollection.isEnabled = false
            showActivityIndicator()
            view.isUserInteractionEnabled = false
        }
    }
    
    func setUpMapUI() {
        mapView.isUserInteractionEnabled = false
        mapView.addAnnotation(pinSelected)
        mapView.showAnnotations([pinSelected], animated: true)
        mapView.camera.centerCoordinate = pinSelected.coordinate
    }
    
    public func showActivityIndicator() {
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.labelNoImage.text = "Downloading..."
        }
    }
    
    public func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    //MARK: - Delegate methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
