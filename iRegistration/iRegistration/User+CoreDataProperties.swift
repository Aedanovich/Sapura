//
//  User+CoreDataProperties.swift
//  iReception
//
//  Created by Alex on 25/11/15.
//  Copyright © 2015 A2. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var image: NSData?
    @NSManaged var name: String?
    @NSManaged var nric: String?
    @NSManaged var organization: String?
    @NSManaged var phone: String?
    @NSManaged var purpose: String?
    @NSManaged var temperature: NSNumber?
    @NSManaged var timeStamp: NSDate?

}
