//
//  TimerController.swift
//  Timeato WatchKit Extension
//
//  Created by Jeff Kelley on 6/9/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import Foundation
import UserNotifications
import WatchKit
import WatchConnectivity

@objcMembers
class Timer: NSObject {
    let id: UUID
    let endDate: Date
    
    init(id: @autoclosure() -> UUID = UUID(), endDate: Date) {
        self.id = id()
        self.endDate = endDate
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
            if let oldTimer = oldValue {
                if #available(watchOSApplicationExtension 3.0, *) {
                    cancelNotification(for: oldTimer.id)
                }
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
            let endDate = defaults.date(forKey: .timerEndDate) {
            currentTimer = Timer(id: id, endDate: endDate)
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
        
        guard let timerEndDate = Calendar.current
            .date(byAdding: timerComponents,
                  to: Date()) else { return }
        
        WKInterfaceDevice.current().play(.start)
        
        let timer = Timer(endDate: timerEndDate)
        currentTimer = timer
        
        sendTimerToPhone(timerEndDate)
        
        if #available(watchOSApplicationExtension 3.0, *) {
            createTimerEndNotification()
        }
    }
    
    
    func cancelTimer() {
        guard currentTimer != nil else { return }
        
        WKInterfaceDevice.current().play(.stop)
        
        currentTimer = nil
    }
    
    @objc private func timerEnded(_ timer: Foundation.Timer) {
        currentTimer = nil
    }
    
}
