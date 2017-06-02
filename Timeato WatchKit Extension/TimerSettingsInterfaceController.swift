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
    
    // MARK:- Methods
    
    @IBAction func incrementTimerButtonPressed() {
        
    }
    
    @IBAction func decrementTimerButtonPressed() {
        
    }

}
