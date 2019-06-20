//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Noor Aldahri on 07/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collecitonView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    var menuShowing = false
    
    var fetchedResultContoller: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var pageNumber = 1
    var isDeletingEverything = false
    
    var context: NSManagedObjectContext {
        return DataContoller.shared.viewContext
    }
    
    var isPhotosEmpty: Bool {
        return (fetchedResultContoller.fetchedObjects?.count ?? 0) != 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 4
        setupFetchedResultController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultContoller = nil
    }
    
    func setupFetchedResultController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        fetchedResultContoller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultContoller.delegate = self
        
        do {
            try fetchedResultContoller.performFetch()
            if isPhotosEmpty {
                return
            }
            else {
                newCollectionTapped(self)
            }
        }
            catch {
                fatalError("The fetch could not be performd: \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        if isPhotosEmpty {
            isDeletingEverything = true
            for photo in fetchedResultContoller.fetchedObjects! {
                context.delete(photo)
            }
            try? context.save()
            isDeletingEverything = false
        }
        
        FlickrAPI.getPhotoUrls(with: pin.coordinate, pageNumber: pageNumber) { (urls, error, errorMessage) in
            DispatchQueue.main.sync {
            
                guard (error == nil) && (errorMessage == nil) else {
                    self.alert(title: "ERROR", message: error?.localizedDescription ?? errorMessage)
                    return
                }
                
                guard let urls = urls, !urls.isEmpty else {
                    self.label.isHidden = false
                    return
                }
                
                for url in urls {
                    let photo = Photo(context: self.context)
                    photo.imageURL = url
                    photo.pin = self.pin
                }
                
                try? self.context.save()
            }
        }
        pageNumber += 1
        leadingConstraint.constant = -215
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collecitonView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultContoller.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collecitonView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
        let photo = fetchedResultContoller.object(at: indexPath)
        cell.imageView.setPhoto(photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultContoller.object(at: indexPath)
        context.delete(photo)
        try? context.save()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, type == .delete && !isDeletingEverything {
            collecitonView.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = indexPath, type == .insert {
            collecitonView.insertItems(at: [indexPath])
            return
        }
        
        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move {
            collecitonView.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }
        
        if type != .update {
            collecitonView.reloadData()
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        
        if (menuShowing) {
            leadingConstraint.constant = -215
        } else {
            leadingConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {
               self.view.layoutIfNeeded()

            })
        }
         menuShowing = !menuShowing

    }
    @IBAction func homeBtn(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)

    }
}
