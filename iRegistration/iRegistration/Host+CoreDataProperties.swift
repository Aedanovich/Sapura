//
//  Host+CoreDataProperties.swift
//  iRegistration
//
//  Created by Alex on 22/12/15.
//  Copyright © 2015 A2. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Host {

    @NSManaged var name: String?
    @NSManaged var phone: String?
    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var department: String?
    @NSManaged var email: String?
    @NSManaged var guests: NSSet?

}
