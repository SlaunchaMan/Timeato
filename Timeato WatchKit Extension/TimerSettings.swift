//
//  TimerSettings.swift
//  Timeato
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import Foundation

fileprivate let miniumumTimerLength = 1

class TimerSettings {
    
    // MARK:- Class Properties
    
    static let sharedSettings = TimerSettings()
    
    fileprivate static var initialTimerLength: Int = {
        return UserDefaults.standard.integer(forKey: .timerLength)
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
    
    // MARK:- Instance Properties
    
    var timerLength = TimerSettings.initialTimerLength {
        didSet {
            UserDefaults.standard.set(timerLength,
                                      forKey: .timerLength)
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
    
    // MARK:- Methods
    
    private init() {

    }
    
}
