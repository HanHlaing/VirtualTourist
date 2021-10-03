//
//  PhotoAlbumViewController+Extension.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 29/09/2021.
//

import Foundation
import CoreData
import UIKit

extension PhotoAlbumViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Check if the download has finished
        if (activityIndicator.isAnimating) && (fetchedResultsController.sections?[section].numberOfObjects != 0) {
            hideActivityIndicator()
            collectionView.reloadData()
        }
        
        // Check if our album is empty
        if (fetchedResultsController.sections?[section].numberOfObjects == 0) {
            labelNoImage.text = "There is no photos yet!"
        } else {
            labelNoImage.text = nil
        }
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let Photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! ImageViewCell
        let mainContext = dataController.viewContext
        // Download an image per cell
        if Photo.image == nil && Photo.imageUrl != nil {
            cell.showActivityIndicator()
            FlickrClient.downloadImage(imgUrl: Photo.imageUrl!) { data, error in
                guard let data = data else {
                    cell.hideActivityIndicator()
                    return
                }
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                    cell.hideActivityIndicator()
                }
                mainContext.perform {
                    Photo.image = data
                    try? mainContext.save()
                }
            }
        }
        
        if Photo.image != nil {
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: Photo.image!)
                cell.hideActivityIndicator()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Delete selected photo from Core Stack
        let photoToErase = fetchedResultsController.object(at: indexPath)
        let mainContext = dataController.viewContext
        mainContext.perform {
            mainContext.delete(photoToErase)
            try? mainContext.save()
        }
    }
    
}


extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        default:
            fatalError("This is not possible")
            break
        }
    }
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pinSelected)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("ERROR: \(error.localizedDescription)")
        }
    }
}

