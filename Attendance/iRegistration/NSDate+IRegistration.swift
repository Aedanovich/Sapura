//
//  NSDate+IRegistration.swift
//  iRegistration
//
//  Created by Alex on 24/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

extension NSDate {
    func getTimeGreeting() -> String {
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = gregorian.components(NSCalendarUnit.Hour, fromDate: self)
        
        let hour = components.hour
        if hour < 12 {
            return "Good Morning"
        }
        else if (hour > 12 && hour <= 16)
        {
            return "Good Afternoon"
        }
        else
        {
            return "Good Night"
        }
    }
    func getStringTime() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "h:mma"
        return df.stringFromDate(self)
    }
    func getStringDate() -> String {
        let df = NSDateFormatter()
        df.dateStyle = .ShortStyle
        df.timeStyle = .NoStyle
        df.doesRelativeDateFormatting = true
        return df.stringFromDate(self)
    }
    func getStringDateTime() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "dd MMM yyyy h:mma"
        return df.stringFromDate(self)
    }
}
