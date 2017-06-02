//
//  TimerInterfaceController.swift
//  Timeato WatchKit Extension
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import Foundation
import WatchKit

let defaultTimerLength = 1 // minutes

class TimerInterfaceController: WKInterfaceController {

    // MARK:- UI Elements
    
    @IBOutlet weak var timerPreviewLabel: WKInterfaceLabel?
    @IBOutlet weak var timer: WKInterfaceTimer?
    @IBOutlet weak var startTimerButton: WKInterfaceButton?
    @IBOutlet weak var cancelTimerButton: WKInterfaceButton?
    
    // MARK:- Instance Properties
    
    lazy var timerPreviewFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .positional
        
        return formatter
    }()
    
    var timerComponents: DateComponents {
        return DateComponents(minute: defaultTimerLength, second: 0)
    }
    
    var timerCompletionTimer: Timer?
    
    // MARK:- WKInterfaceControllerMethods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        timerPreviewLabel?
            .setText(timerPreviewFormatter.string(from: timerComponents))
        
    }
    
    // MARK:- Methods
    
    @IBAction func startTimerButtonPressed() {
        startTimer()
    }
    
    func startTimer() {
        guard let timerEndDate = Calendar.autoupdatingCurrent
            .date(byAdding: timerComponents, to: Date()) else { return }
        
        WKInterfaceDevice.current().play(.start)
        
        startTimerButton?.setHidden(true)
        cancelTimerButton?.setHidden(false)
        
        timerPreviewLabel?.setHidden(true)
        timer?.setHidden(false)
        
        timer?.setDate(timerEndDate)
        
        let timeInterval = timerEndDate.timeIntervalSince(Date())
        
        timerCompletionTimer =
            Timer.scheduledTimer(withTimeInterval: timeInterval,
                                 repeats: false) { [weak self] (timer) in
                                    WKInterfaceDevice.current().play(.notification)
                                    
                                    self?.cancelTimer()
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
    
}
