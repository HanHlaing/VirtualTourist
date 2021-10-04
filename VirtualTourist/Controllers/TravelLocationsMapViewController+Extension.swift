//
//  TravelLocationsMapViewController+Extension.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 27/09/2021.
//

import Foundation
import CoreData

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let point = anObject as? Pin else {
            fatalError("Only check Pin instances")
        }
        
        switch type {
        case .insert:
            mapView.addAnnotation(point)
            
        case .delete:
            mapView.removeAnnotation(point)
            
        case .update:
            mapView.removeAnnotation(point)
            mapView.addAnnotation(point)
            
        case .move:
            fatalError("This is not possible")
        @unknown default:
            fatalError("Unknown error in this version")
        }
    }
    
    func setUpFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error fetching Pin results")
        }
    }
}
