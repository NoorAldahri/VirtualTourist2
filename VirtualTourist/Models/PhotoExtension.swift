//
//  PhotoExtension.swift
//  VirtualTourist
//
//  Created by Noor Aldahri on 07/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit


extension Photo {
    
    func set(image: UIImage) {
        self.imageData = image.pngData()
    }

    func getImage() -> UIImage? {
        return (imageData == nil) ? nil : UIImage (data: imageData!)
    }
    
    public override func awakeFromInsert() {
        super .awakeFromInsert()
        creationDate = Date()
    }
}
