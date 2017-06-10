//
//  WatchDefaults.swift
//  Timeato
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import Foundation

fileprivate let defaultTimerLength = 25 // minutes

enum SettingsKey: String {
    case timerLength
    case timerStartDate
    case timerEndDate
    case timerIdentifier
}

extension UserDefaults {
    
    func registerWatchDefaults() {
        register(defaults: [.timerLength: defaultTimerLength])
    }
    
    private func register(defaults: [SettingsKey: Any]) {
        var newDefaults: [String: Any] = [:]
        
        for (key, value) in defaults {
            newDefaults[key.rawValue] = value
        }
        
        register(defaults: newDefaults)
    }
    
    func set(_ value: Int?, forKey key: SettingsKey) {
        set(value, forKey: key.rawValue)
    }
    
    func integer(forKey key: SettingsKey) -> Int {
        return integer(forKey: key.rawValue)
    }
    
    func set(_ value: Date?, forKey key: SettingsKey) {
        set(value, forKey: key.rawValue)
    }
    
    func date(forKey key: SettingsKey) -> Date? {
        return object(forKey: key.rawValue) as? Date
    }
    
    func set(_ value: UUID?, forKey key: SettingsKey) {
        set(value?.uuidString, forKey: key.rawValue)
    }
    
    func uuid(forKey key: SettingsKey) -> UUID? {
        guard let uuidString = value(forKey: key.rawValue) as? String
            else { return nil }
        
        return UUID(uuidString: uuidString)
    }
    
}
