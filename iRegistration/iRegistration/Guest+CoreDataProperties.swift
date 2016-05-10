//
//  Guest+CoreDataProperties.swift
//  iRegistration
//
//  Created by Alex on 14/1/16.
//  Copyright © 2016 A2. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Guest {

    @NSManaged var id: String?
    @NSManaged var image: NSData?
    @NSManaged var name: String?
    @NSManaged var nric: String?
    @NSManaged var organization: String?
    @NSManaged var phone: String?
    @NSManaged var purpose: String?
    @NSManaged var shouldUpload: NSNumber?
    @NSManaged var temperature: NSNumber?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var imagePath: String?
    @NSManaged var host: Host?

}
