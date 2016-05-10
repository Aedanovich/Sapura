//
//  User+CoreDataProperties.swift
//  Attendance
//
//  Created by Alex on 3/29/16.
//  Copyright © 2016 A2. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var cardId: String?
    @NSManaged var email: String?
    @NSManaged var fingerprintTemplate: String?
    @NSManaged var image: NSData?
    @NSManaged var isLate: NSNumber?
    @NSManaged var lateCount: NSNumber?
    @NSManaged var name: String?
    @NSManaged var nric: String?
    @NSManaged var organization: String?
    @NSManaged var phone: String?
    @NSManaged var purpose: String?
    @NSManaged var temperature: NSNumber?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var upload: NSNumber?

}
