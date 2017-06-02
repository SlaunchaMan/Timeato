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

class TimerInterfaceController: WKInterfaceController {

    // MARK:- UI Elements
    
    @IBOutlet weak var timerPreviewLabel: WKInterfaceLabel?
    @IBOutlet weak var timer: WKInterfaceTimer?
    @IBOutlet weak var startTimerButton: WKInterfaceButton?
    @IBOutlet weak var cancelTimerButton: WKInterfaceButton?
    
    // MARK:- Instance Properties
    
    var timerCompletionTimer: Timer?
    var timerEndDate: Date?
    
    // MARK:- WKInterfaceControllerMethods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        configurePreviewLabel()
    }
    
    override func willActivate() {
        super.willActivate()
        
        configurePreviewLabel()
    }
    
    // MARK:- Methods
    
    func configurePreviewLabel() {
        let timerComponents = TimerSettings.timerComponents
        let timerPreviewFormatter = TimerSettings.timerPreviewFormatter
        
        timerPreviewLabel?
            .setText(timerPreviewFormatter.string(from: timerComponents))
    }
    
    @IBAction func startTimerButtonPressed() {
        startTimer()
    }
    
    func startTimer() {
        let timerComponents = TimerSettings.timerComponents
        
        guard let timerEndDate = Calendar.autoupdatingCurrent
            .date(byAdding: timerComponents, to: Date()) else { return }
        
        WKInterfaceDevice.current().play(.start)
        
        startTimerButton?.setHidden(true)
        cancelTimerButton?.setHidden(false)
        
        timerPreviewLabel?.setHidden(true)
        timer?.setHidden(false)
        
        timer?.setDate(timerEndDate)
        self.timerEndDate = timerEndDate
        
        let timeInterval = timerEndDate.timeIntervalSinceNow
        
        timerCompletionTimer =
            Timer.scheduledTimer(timeInterval: timeInterval,
                                 target: self,
                                 selector: #selector(timerCompletionTimerFired(_:)),
                                 userInfo: nil,
                                 repeats: false)
        
        if #available(watchOSApplicationExtension 3.0, *) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound]) { (allow, error) in
                    if allow {
                        self.scheduleNotification()
                    }
                    else if let error = error {
                        NSLog("Error authorizing notifications: %@",
                              error.localizedDescription)
                    }
            }
        }
    }
    
    @objc func timerCompletionTimerFired(_ timer: Timer) {
        cancelTimer()
    }
    
    @available(watchOSApplicationExtension 3.0, *)
    func scheduleNotification() {
        guard let timerEndDate = timerEndDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Done"
        content.body = "Your timer has finished."
        content.sound = .default()
        
        let timeInterval = timerEndDate.timeIntervalSinceNow
        
        let trigger =
            UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                              repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                NSLog("Error adding notification request: %@",
                      error.localizedDescription)
            }
        }
    }
    
    @IBAction func cancelTimerButtonPressed() {
        WKInterfaceDevice.current().play(.stop)
        
        cancelTimer()
    }
    
    func cancelTimer() {
        timer?.setHidden(true)
        timerPreviewLabel?.setHidden(false)
        
        cancelTimerButton?.setHidden(true)
        startTimerButton?.setHidden(false)
        
        timerCompletionTimer?.invalidate()
        timerCompletionTimer = nil
    }
    
    @IBAction func timerSettingsMenuItemSelected() {
        presentController(
            withName: TimerSettingsInterfaceController.storyboardIdentifier,
            context: nil)
    }
    
}
