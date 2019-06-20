//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Noor Aldahri on 07/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit

extension UIViewController {

    func alert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
