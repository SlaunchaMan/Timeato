//
//  AppDelegate.swift
//  Timeato
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var useOldNotifications: Bool {
        if #available(iOS 10.0, *) {
            return false
        }
        
        return true
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        if #available(iOS 9.0, *) {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        if useOldNotifications {
            let settings = UIUserNotificationSettings(types: [.alert, .sound],
                                                      categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
}

@available(iOS 9.0, *)
extension AppDelegate: WCSessionDelegate {
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            NSLog("Error activating WCSession: %@",
                  error.localizedDescription)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any]) {
        if useOldNotifications, let timerEndDate = message["EndDate"] as? Date {
            let notification = UILocalNotification()
            notification.alertTitle = "Timer Finished"
            notification.alertBody = "Your timer has finished."
            notification.fireDate = timerEndDate
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
}
