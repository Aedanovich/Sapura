//
//  NSDate+IRegistration.swift
//  iReception
//
//  Created by Alex on 24/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

extension NSDate {
    func getStringTime() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "h:mma"
        return df.stringFromDate(self)
    }
    func getStringDate() -> String {
        let df = NSDateFormatter()
        df.dateStyle = .MediumStyle
        df.timeStyle = .NoStyle
//        df.dateFormat = "dd MMM yyyy"
        df.doesRelativeDateFormatting = true
        return df.stringFromDate(self)
    }
    func getStringDateTime() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "dd MMM yyyy h:mma"
        return df.stringFromDate(self)
    }
}
