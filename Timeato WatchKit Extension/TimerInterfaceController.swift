//
//  TimerInterfaceController.swift
//  Timeato WatchKit Extension
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import Foundation
import WatchKit

class TimerInterfaceController: WKInterfaceController {

    // MARK:- UI Elements
    
    @IBOutlet weak var timerPreviewLabel: WKInterfaceLabel?
    @IBOutlet weak var timer: WKInterfaceTimer?
    @IBOutlet weak var startTimerButton: WKInterfaceButton?
    @IBOutlet weak var cancelTimerButton: WKInterfaceButton?
    
    // MARK:- Instance Properties
    
    var timerCompletionTimer: Timer?
    
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
    
    @IBAction func timerSettingsMenuItemSelected() {
        presentController(
            withName: TimerSettingsInterfaceController.storyboardIdentifier,
            context: nil)
    }
    
}
