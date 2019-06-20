//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Noor Aldahri on 05/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DataContoller.shared.load()
        
        return true
    }

    func saveContext () {
        try? DataContoller.shared.viewContext.save()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
      saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

}

