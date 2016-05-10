//
//  Host+CoreDataProperties.swift
//  Attendance
//
//  Created by Alex on 28/1/16.
//  Copyright © 2016 A2. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Host {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var phone: String?

}
