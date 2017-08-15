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
    @IBOutlet weak var timerSlider: WKInterfaceSlider?
    
    // MARK:- WKInterfaceController Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        configureUI()
    }
    
    override func willActivate() {
        super.willActivate()
        
        configureUI()
    }
    
    // MARK:- Methods
    
    func configureUI() {
        let timerComponents = TimerSettings.timerComponents
        let timerPreviewFormatter = TimerSettings.timerPreviewFormatter
        
        timerLabel?.setText(timerPreviewFormatter.string(
            from: timerComponents))
        
        let timerLength = TimerSettings.sharedSettings.timerLength
        timerSlider?.setValue(Float(timerLength))
    }
    
    @IBAction func sliderValueChanged(_ value: Float) {
        TimerSettings.sharedSettings.timerLength = Int(max(value, 1))
        configureUI()
    }
    
}
