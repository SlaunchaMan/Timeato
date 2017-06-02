//
//  TimerSettings.swift
//  Timeato
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import Foundation

fileprivate let defaultTimerLength = 25 // minutes
fileprivate let miniumumTimerLength = 1

class TimerSettings {
    
    // MARK:- Class Properties
    
    static var sharedSettings = TimerSettings()
    
    fileprivate static var initialTimerLength: Int = {
        UserDefaults.standard.register(defaults: ["TimerLength": defaultTimerLength])
        
        return UserDefaults.standard.integer(forKey: "TimerLength")
    }()
    
    class var timerLength: Int {
        return sharedSettings.timerLength
    }
    
    class var timerPreviewFormatter: DateComponentsFormatter {
        return sharedSettings.timerPreviewFormatter
    }
    
    class var timerComponents: DateComponents {
        return sharedSettings.timerComponents
    }
    
    class var canDecrementTimer: Bool {
        return sharedSettings.canDecrementTimer
    }
    
    // MARK:- Instance Properties
    
    var timerLength = TimerSettings.initialTimerLength {
        didSet {
            UserDefaults.standard.set(timerLength, forKey: "TimerLength")
        }
    }
    
    lazy var timerPreviewFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .positional
        
        return formatter
    }()
    
    var timerComponents: DateComponents {
        return DateComponents(minute: timerLength, second: 0)
    }
    
    var canDecrementTimer: Bool {
        return timerLength > miniumumTimerLength
    }
    
    // MARK:- Methods
    
    private init() {

    }
    
    func incrementTimer() {
        timerLength += 1
    }
    
    func decrementTimer() {
        let targetLength = timerLength - 1
        
        guard targetLength >= miniumumTimerLength else { return }
        
        timerLength = targetLength
    }

}
