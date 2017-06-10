//
//  ComplicationController.swift
//  Timeato WatchKit Extension
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(TimerController.sharedController.currentTimer?.startDate)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(TimerController.sharedController.currentTimer?.endDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        if let timer = TimerController.sharedController.currentTimer {
            handler(entry(for: complication.family, timer: timer))
        }
        else {
            handler(noTimerEntry(for: complication.family))
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        if let timer = TimerController.sharedController.currentTimer,
            timer.endDate < date {
            handler([entry(for: complication.family, timer: timer)]
                .flatMap { $0 })
        }
        else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        if let timer = TimerController.sharedController.currentTimer,
            timer.endDate > date {
            handler([entry(for: complication.family, timer: timer)]
                .flatMap { $0 })
        }
        else {
            handler(nil)
        }
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(template(for: complication))
    }
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(template(for: complication))
    }
    
    // MARK:- Timeline Templates
    
    func template(for complication: CLKComplication) -> CLKComplicationTemplate? {
        let textProvider = CLKSimpleTextProvider(text: "25:00", shortText: "25", accessibilityLabel: "25 minutes")
        
        switch complication.family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.fillFraction = 1
            template.textProvider = textProvider
            return template
            
        case .extraLarge:
            if #available(watchOSApplicationExtension 3.0, *) {
                let template = CLKComplicationTemplateExtraLargeRingText()
                template.fillFraction = 1
                template.textProvider = textProvider
                return template
            } else {
                return nil
            }
            
        case .modularLarge:
            // We don't support this complication.
            return nil
            
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.fillFraction = 1
            template.textProvider = textProvider
            return template
            
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = textProvider
            return template
            
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.fillFraction = 1
            template.textProvider = textProvider
            return template
            
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = textProvider
            return template
            
        }
    }
    
    // MARK:- Timeline Entries
    
    func entry(for complicationFamily: CLKComplicationFamily,
               timer: Timer) -> CLKComplicationTimelineEntry? {
        let fillFraction = Float(timer.percentElapsed)
        
        let textProvider = CLKRelativeDateTextProvider(
            date: timer.endDate,
            style: .timer,
            units: [.minute, .second])
        
        let template = { () -> CLKComplicationTemplate? in
            switch complicationFamily {
            case .circularSmall:
                let template = CLKComplicationTemplateCircularSmallRingText()
                template.fillFraction = fillFraction
                template.textProvider = textProvider
                return template
                
            case .extraLarge:
                if #available(watchOSApplicationExtension 3.0, *) {
                    let template = CLKComplicationTemplateExtraLargeRingText()
                    template.fillFraction = fillFraction
                    template.textProvider = textProvider
                    return template
                } else {
                    return nil
                }
                
            case .modularLarge:
                // We don't support this complication.
                return nil
                
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallRingText()
                template.fillFraction = fillFraction
                template.textProvider = textProvider
                return template
                
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = textProvider
                return template
                
            case .utilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallRingText()
                template.fillFraction = fillFraction
                template.textProvider = textProvider
                return template
                
            case .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = textProvider
                return template
                
            }
        }()
        
        if let template = template {
            return CLKComplicationTimelineEntry(
                date: timer.endDate,
                complicationTemplate: template)
        }
        else {
            return nil
        }
    }
    
    lazy var noTimerFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        return formatter
    }()
    
    lazy var noTimerShortFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .positional
        return formatter
    }()
    
    lazy var noTimerAccessibilityFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .spellOut
        return formatter
    }()
    
    func noTimerEntry(for complicationFamily: CLKComplicationFamily) -> CLKComplicationTimelineEntry? {
        let comps = TimerSettings.sharedSettings.timerComponents
        
        guard let defaultText = noTimerFormatter.string(from: comps)
            else { return nil}
        
        let textProvider = CLKSimpleTextProvider(
            text: defaultText,
            shortText: noTimerShortFormatter.string(from: comps),
            accessibilityLabel: noTimerAccessibilityFormatter.string(from: comps))
        
        let template = { () -> CLKComplicationTemplate? in
            switch complicationFamily {
            case .circularSmall:
                let template = CLKComplicationTemplateCircularSmallSimpleText()
                template.textProvider = textProvider
                return template
                
            case .extraLarge:
                if #available(watchOSApplicationExtension 3.0, *) {
                    let template = CLKComplicationTemplateExtraLargeSimpleText()
                    template.textProvider = textProvider
                    return template
                } else {
                    return nil
                }
                
            case .modularLarge:
                // We don't support this complication.
                return nil
                
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallSimpleText()
                template.textProvider = textProvider
                return template
                
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = textProvider
                return template
                
            case .utilitarianSmall, .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = textProvider
                return template
                
            }
        }()
        
        if let template = template {
            return CLKComplicationTimelineEntry(
                date: Date(),
                complicationTemplate: template)
        }
        else {
            return nil
        }
    }
}
