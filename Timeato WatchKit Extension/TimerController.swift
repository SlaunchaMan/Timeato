//
//  TimerController.swift
//  Timeato WatchKit Extension
//
//  Created by Jeff Kelley on 6/9/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import ClockKit
import Foundation
import UserNotifications
import WatchKit
import WatchConnectivity

@objcMembers
class Timer: NSObject {
    let id: UUID
    
    let startDate: Date
    let endDate: Date
    
    init(id: @autoclosure() -> UUID = UUID(), startDate: Date, endDate: Date) {
        self.id = id()
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var percentElapsed: Double {
        let totalDuration = endDate.timeIntervalSince(startDate)
        let elapsedDuration = Date().timeIntervalSince(startDate)
        
        return elapsedDuration / totalDuration
    }
}

class TimerController: NSObject {
    
    static let sharedController = TimerController()
    
    private var timerTimer: Foundation.Timer?
    @objc dynamic var currentTimer: Timer? = nil {
        didSet {
            if let timer = currentTimer {
                timerTimer = Foundation.Timer(
                    fireAt: timer.endDate,
                    interval: 0,
                    target: self,
                    selector: #selector(timerEnded(_:)),
                    userInfo: nil,
                    repeats: false)
                
                RunLoop.current.add(timerTimer!,
                                    forMode: .commonModes)
            }
            
            UserDefaults.standard.set(currentTimer?.id,
                                      forKey: .timerIdentifier)
            
            UserDefaults.standard.set(currentTimer?.endDate,
                                      forKey: .timerEndDate)
        }
    }
    
    private override init() {
        super.init()
        
        let defaults = UserDefaults.standard
        
        if let id = defaults.uuid(forKey: .timerIdentifier),
            let startDate = defaults.date(forKey: .timerStartDate),
            let endDate = defaults.date(forKey: .timerEndDate) {
            currentTimer = Timer(id: id,
                                 startDate: startDate,
                                 endDate: endDate)
        }
    }
    
    fileprivate func sendTimerToPhone(_ timerEndDate: Date) {
        WCSession.default
            .sendMessage(["EndDate": timerEndDate],
                         replyHandler: nil) { (error) in
                            NSLog("Error sending message: %@",
                                  error.localizedDescription)
        }
    }
    
    @available(watchOSApplicationExtension 3.0, *)
    fileprivate func createTimerEndNotification() {
        return UNUserNotificationCenter.current()
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
    
    @available(watchOSApplicationExtension 3.0, *)
    fileprivate func scheduleNotification() {
        guard let timer = currentTimer else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Done"
        content.body = "Your timer has finished."
        content.sound = .default()
        
        let timeInterval = timer.endDate.timeIntervalSinceNow
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: timer.id.uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                NSLog("Error adding notification request: %@",
                      error.localizedDescription)
            }
        }
    }
    
    @available(watchOSApplicationExtension 3.0, *)
    func cancelNotification(for identifier: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier.uuidString])
    }
    
    func startTimer() {
        guard currentTimer == nil else { return }
        
        let timerComponents = TimerSettings.timerComponents
        
        let startDate = Date()
        
        guard let timerEndDate = Calendar.current
            .date(byAdding: timerComponents,
                  to: startDate) else { return }
        
        WKInterfaceDevice.current().play(.start)
        
        currentTimer = Timer(startDate: startDate,
                             endDate: timerEndDate)
        
        sendTimerToPhone(timerEndDate)
        
        if #available(watchOSApplicationExtension 3.0, *) {
            createTimerEndNotification()
        }
        
        let complicationServer = CLKComplicationServer.sharedInstance()
        for complication in complicationServer.activeComplications ?? [] {
            complicationServer.extendTimeline(for: complication)
        }
    }
    
    
    func cancelTimer() {
        guard let timer = currentTimer else { return }
        
        WKInterfaceDevice.current().play(.stop)
        
        currentTimer = nil
        
        if #available(watchOSApplicationExtension 3.0, *) {
            cancelNotification(for: timer.id)
        }
        
        let complicationServer = CLKComplicationServer.sharedInstance()
        for complication in complicationServer.activeComplications ?? [] {
            complicationServer.reloadTimeline(for: complication)
        }
    }
    
    @objc private func timerEnded(_ timer: Foundation.Timer) {
        currentTimer = nil
    }
    
}
