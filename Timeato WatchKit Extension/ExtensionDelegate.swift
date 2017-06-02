//
//  ExtensionDelegate.swift
//  Timeato WatchKit Extension
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import WatchKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func applicationDidFinishLaunching() {
        if #available(watchOSApplicationExtension 3.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }

}

@available(watchOSApplicationExtension 3.0, *)
extension ExtensionDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Present the notification fullscreen
        completionHandler([.alert, .sound])
    }
    
}
