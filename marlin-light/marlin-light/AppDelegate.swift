//
//  AppDelegate.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/22/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupWindowAndRootViewController()
        disableIdleTimer()
        return true
    }
    
    func setupWindowAndRootViewController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = MainViewController()
        self.window!.makeKeyAndVisible()
    }

    func disableIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
}

