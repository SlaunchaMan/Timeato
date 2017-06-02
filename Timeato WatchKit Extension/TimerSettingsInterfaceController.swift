//
//  TimerSettingsInterfaceController.swift
//  Timeato
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import WatchKit
import Foundation

class TimerSettingsInterfaceController: WKInterfaceController {

    static let storyboardIdentifier = "TimerSettings"
    
    // MARK:- UI Elements
    
    @IBOutlet weak var timerLabel: WKInterfaceLabel?
    @IBOutlet weak var incrementTimerButton: WKInterfaceButton?
    @IBOutlet weak var decrementTimerButton: WKInterfaceButton?
    
    // MARK:- WKInterfaceController Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        configureTimerLabel()
    }
    
    override func willActivate() {
        super.willActivate()
        
        configureTimerLabel()
    }
    
    // MARK:- Methods
    
    func configureTimerLabel() {
        let timerComponents = TimerSettings.timerComponents
        let timerPreviewFormatter = TimerSettings.timerPreviewFormatter
        
        timerLabel?
            .setText(timerPreviewFormatter.string(from: timerComponents))
    }
    
    func configureDecrementButton() {
        decrementTimerButton?.setEnabled(TimerSettings.canDecrementTimer)
    }
    
    @IBAction func incrementTimerButtonPressed() {
        TimerSettings.sharedSettings.incrementTimer()
        configureDecrementButton()
        configureTimerLabel()
    }
    
    @IBAction func decrementTimerButtonPressed() {
        TimerSettings.sharedSettings.decrementTimer()
        configureDecrementButton()
        configureTimerLabel()
    }

}
