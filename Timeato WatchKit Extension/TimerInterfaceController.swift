//
//  TimerInterfaceController.swift
//  Timeato WatchKit Extension
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import Foundation
import WatchKit
import UserNotifications
import WatchConnectivity

class TimerInterfaceController: WKInterfaceController {
    
    // MARK:- UI Elements
    
    @IBOutlet weak var timer: WKInterfaceTimer?
    @IBOutlet weak var startTimerButton: WKInterfaceButton?
    @IBOutlet weak var cancelTimerButton: WKInterfaceButton?
    
    // MARK:- Properties
    
    var timerObservation: NSKeyValueObservation?
    
    // MARK:- WKInterfaceControllerMethods
    
    override func awake(withContext context: Any?) {
        timerObservation = TimerController.sharedController
            .observe(\.currentTimer) { [weak self] (_, _) in
                self?.configureUI()
        }
    }
    
    override func willActivate() {
        configureUI()
    }
    
    // MARK:- Methods
    
    func configureUI() {
        clearAllMenuItems()
        
        if let currentTimer = TimerController.sharedController.currentTimer {
            startTimerButton?.setHidden(true)
            cancelTimerButton?.setHidden(false)
            
            timer?.setDate(currentTimer.endDate)
            timer?.start()
        }
        else {
            startTimerButton?.setHidden(false)
            cancelTimerButton?.setHidden(true)
            
            timer?.stop()
            
            if let date = Calendar.current.date(
                byAdding: TimerSettings.timerComponents,
                to: Date()) {
                timer?.setDate(date + 1)
            }
            
            addMenuItem(with: .more,
                        title: "Timer Settings",
                        action: #selector(timerSettingsMenuItemSelected))
        }
    }
    
    @IBAction func startTimerButtonPressed() {
        TimerController.sharedController.startTimer()
    }
    
    @IBAction func cancelTimerButtonPressed() {
        TimerController.sharedController.cancelTimer()
    }
    
    @objc func timerSettingsMenuItemSelected() {
        presentController(
            withName: TimerSettingsInterfaceController.storyboardIdentifier,
            context: nil)
    }
    
}
