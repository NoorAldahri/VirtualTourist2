//
//  CustomImageView.swift
//  VirtualTourist
//
//  Created by Noor Aldahri on 07/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit

let imagesCache = NSCache<NSString, AnyObject>()

class CustomImageView: UIImageView {
    
    var imageURL: URL!
    
    func setPhoto(_ newPhoto: Photo) {
        if photo != nil {
            return
        }
        photo = newPhoto
    }
    
    private var photo: Photo! {
        didSet {
            if let image = photo.getImage() {
                hideActivityIndicatorView()
                self.image = image
                return
            }
            
            guard let url = photo.imageURL else {
                return
            }
            
            loadImageUsingCache(with: url)
        }
    }
    
    func loadImageUsingCache(with url: URL) {
        imageURL = url
        image = nil
        showActivityIndicatorView()
        if let cachedImage = imagesCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            hideActivityIndicatorView()
            return
        }
        
        URLSession.shared.dataTask(with: url) { ( data, respons, error ) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let downloadImage = UIImage(data: data!) else { return }
            imagesCache.setObject(downloadImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = downloadImage
                self.photo.set(image: downloadImage)
                try? self.photo.managedObjectContext?.save()
                self.hideActivityIndicatorView()
            }
        }.resume()
    }
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicatorView.color = .black
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()

    func hideActivityIndicatorView() {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    func showActivityIndicatorView() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
    }
}


