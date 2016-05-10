//
//  Guest.swift
//  iReception
//
//  Created by Alex on 23/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import Foundation
import CoreData

class Guest: NSManagedObject {

    var date: String {
        let time = timeStamp?.getStringDate()
        return time!
    }
}
