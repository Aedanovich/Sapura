//
//  CoreDataManager.swift
//  iReception
//
//  Created by Alex on 22/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit
import CoreData

/**
* Class for managing ALL CoreData related logic.
*
* Members:
* sharedInstance Singleton instance
*
*/
class CoreDataManager: NSObject {
    class var sharedInstance: CoreDataManager {
        struct Static {
            static var instance: CoreDataManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CoreDataManager()
        }
        
        return Static.instance!
    }
    
    private var _showTemperature: Bool!
    var showTemperature: Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let value = defaults.valueForKey("showTemperature") {
                _showTemperature = value as? Bool
            }
            if let _ = _showTemperature {
                return _showTemperature
            }
            else {
                _showTemperature = false
                return _showTemperature
            }
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newValue, forKey: "showTemperature")
            _showTemperature = newValue
        }
    }
    
    private var _showPrint: Bool!
    var showPrint: Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let value = defaults.valueForKey("showPrint") {
                _showPrint = value as? Bool
            }
            if let _ = _showPrint {
                return _showPrint
            }
            else {
                _showPrint = false
                return _showPrint
            }
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newValue, forKey: "showPrint")
            _showPrint = newValue
        }
    }
    
    /**
    * Add a Guest object to Core Data
    */
    func AddGuest(dictionary: Dictionary<String, AnyObject!>!) -> Guest! {
        let context = managedObjectContext
        let entity = NSEntityDescription.entityForName("Guest", inManagedObjectContext: context)
        
        var mo: Guest! = nil
        
        if let guestId = dictionary["guests_id"] as? String {
            let predicate = NSPredicate(format: "id = %@", guestId)

            if let array = fetchEntity(context, entity: "Guest", predicate: predicate) as? Array<Guest> {
                mo = array.count > 0 ? array[0] : nil
            }            
        }

        if mo == nil {
            mo = NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: context) as! Guest
        }
        
        mo.timeStamp = NSDate()

        let properties = entity!.propertiesByName
        let propertyNames = properties.map { $0.0 }
        
        for key in dictionary.keys {
            let decodedKey = key.stringByReplacingOccurrencesOfString("guests_", withString: "")
            
            let value = dictionary[key]

            if (propertyNames.contains(decodedKey)) {
                if let image = value as? UIImage {
                    let resizedImage = image.resizedImageWithMaximumSize(CGSize(width: 300, height: 300))
                    mo.setValue(UIImagePNGRepresentation(resizedImage), forKey: decodedKey)
                }
                else if decodedKey == "temperature" {
                    mo.setValue(Float(value as! String), forKey: decodedKey)
                }
                else {
                    mo.setValue(value, forKey: decodedKey)
                }
            }
            else if decodedKey == "host_staff_id" {
                if let id = value as? String {
                    if let host = HostWithId(id) {
                        mo.host = host
                    }
                }
            }
            else if decodedKey == "photo_name" {
                if let imageName = value as? String {
                    if imageName.characters.count > 0 {
                        let path = "\(WebService.photoServer)\(imageName)"
                        mo.imagePath = path
                    }
                }
            }
//            else if decodedKey == "last_attend_datetime" {
            else if decodedKey == "creation_datetime" {
                if let date = value as? String {
                    let df = NSDateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let timeStamp = df.dateFromString(date) {
                        mo.timeStamp = timeStamp
                    }
                }
            }
        }
    
        saveContext(context)
        
        return mo
    }

    
    /**
     * Returns an Array of Dictionaries from all Guest objects to upload
     *
     * Sample Data from API:
     * guests_id: 1,
     * image: <Base64>
     */
    func GuestsToUploadImageDictionaries(guestArray: Array<Guest>? = nil) -> Array<Dictionary<String, AnyObject>>! {
        var parameters = Array<Dictionary<String, AnyObject>>()
        
        let guests = guestArray != nil ? guestArray : GuestsToUpload()
        for guest in guests {
            if let id = guest.id {
                if let base64Data = guest.image?.base64EncodedDataWithOptions(.Encoding64CharacterLineLength) {
                    let dict: Dictionary<String, AnyObject>! = ["guests_id": id, "image": base64Data]
                    parameters.append(dict)
                }
            }
        }
        
        return parameters
    }

    /**
     * Returns an Array of Dictionaries from all Guest objects to upload
     *
     * Sample Data from API:
     "guests_name": "Angel Wing",
     "guests_nric": "S1122334F",
     "guests_phone": "87655243",
     "guests_organization": "Sapura Synergy",
     "guests_host_staff_id": "1",
     "guests_purpose": "Meeting",
     "guests_temperature": "36",
     "guests_image": "",
     "guests_fingerprintTemplate": ""
     
     */
    func GuestsToUploadDictionaries(guestArray: Array<Guest>? = nil) -> Array<Dictionary<String, AnyObject>>! {
        var parameters = Array<Dictionary<String, AnyObject>>()
        
        let guests = guestArray != nil ? guestArray : GuestsToUpload()
        for guest in guests {
            // Fill with Default value
            let name = guest.name != nil ? guest.name : ""
            let nric = guest.nric != nil ? guest.nric : ""
            let phone = guest.phone != nil ? guest.phone : ""
            let organization = guest.organization != nil ? guest.organization : ""
            var host = ""
            if let h = guest.host {
                if let value = h.id {
                    host = value
                }
            }
            let purpose = guest.purpose != nil ? guest.purpose : ""
            let temperature = guest.temperature != nil ? "\(guest.temperature!.floatValue)" : ""
            var image = ""
            if let i = guest.image {
                let value = i.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                image = value
            }
            let df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestamp = df.stringFromDate(guest.timeStamp!)

            let dict:[String:String] = [
                "guests_name": name!,
                "guests_nric": nric!,
                "guests_phone": phone!,
                "guests_organization": organization!,
                "guests_host_staff_id": host,
                "guests_purpose": purpose!,
                "guests_temperature": temperature,
                "guests_creation_datetime": timestamp,
                "guests_image": image,
                "guests_fingerprintTemplate": ""]

            parameters.append(dict)
        }
        
        return parameters
    }

     /**
     * Returns an Array of Guest objects with isUploaded = 0
     */
    func GuestsToUpload() -> Array<Guest>! {
        let context = managedObjectContext
        
        if let array = fetchEntity(context, entity: "Guest") as? Array<Guest> {
            var guests = Array<Guest>()
            for guest in array {
                if ((guest.shouldUpload?.boolValue) == true) {
                    guests.append(guest)
                }
            }
            if guests.count > 0 {
                return guests
            }
        }
        
        return nil
    }

    
    /**
    * Add a User
    */
    var _user: User? = nil
    var LoggedInUser: User! {
        if let _ = _user {
            return _user!
        }
        
        let context = managedObjectContext
        
        if let array = fetchEntity(context, entity: "User") as? Array<User> {
            _user = array.count > 0 ? array[0] : nil
        }
        
        return _user
    }
    
    func LoginUser(userInfo: Dictionary<String, AnyObject>!) {
        let context = managedObjectContext
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
        let user: User = NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: context) as! User
        
        if let value = userInfo["name"] as? String {
            user.name = value
        }
        
        saveContext()
    }

    func LogoutUser() {
        if let user = self.LoggedInUser {
            // Delete user
            let context = managedObjectContext
            context.deleteObject(user)
            saveContext(context)
        }
    }

    
    /**
     * Save Guest list
     */
    func AddGuests(array : Array<Dictionary<String, AnyObject!>>!) {
        for info in array {
            AddGuest(info)
        }
        
    }

    /**
     * Delete Guest list
     */
    func DeleteGuests() -> Bool {
        let context = managedObjectContext
        var guests = Array<Guest>()
        if let array = fetchEntity(context, entity: "Guest") as? Array<Guest> {
            for guest in array {
                if ((guest.shouldUpload?.boolValue) == false) {
                    guests.append(guest)
                }
            }
        }

        for guest in guests {
            context.deleteObject(guest)
        }

        do {
            try context.save()
            
            if let array = fetchEntity(context, entity: "Guest") as? Array<Guest> {
                NSLog("Guests Deleted: \(array.count)")
            }
            else {
                NSLog("Guests Deleted: ZERO")
            }
            return true
        }
        catch {
            return false
        }
    }

    /**
     * Save Host list
     */
    func AddHosts(array : Array<Dictionary<String, AnyObject!>>!) {
        for hostInfo in array {
            AddHost(hostInfo)
        }
    }

    /**
     * Add a Host object to Core Data
     *
     * Sample Data from API:
     * "staff_id": "1",
     * "staff_name": "Hebe",
     * "staff_title": "Go go",
     * "staff_department": "12313",
     * "staff_phone": "123123132",
     * "staff_email": "123123",
     * "staff_redirect_id": "1",
     * "deleted": "0",
     * "created_at": "2015-12-07 00:00:00",
     * "updated_at": "2015-12-07 00:00:00"
     */
    func AddHost(dictionary: Dictionary<String, AnyObject!>!) -> Host! {
        let context = managedObjectContext
        let entity = NSEntityDescription.entityForName("Host", inManagedObjectContext: context)
        let mo: Host = NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: context) as! Host
        
        let properties = entity!.propertiesByName
        let propertyNames = properties.map { $0.0 }
        
        for key in dictionary.keys {
            let decodedKey = key.stringByReplacingOccurrencesOfString("staff_", withString: "")

            if (propertyNames.contains(decodedKey)) {
                let value = dictionary[key]
                mo.setValue(value, forKey: decodedKey)
            }
        }
        
        saveContext(context)
        
        return mo
    }

    
    /**
    * Get all Host objects
    */
    var _hosts: Array<Host>? = nil
    func Hosts() -> Array<Host>! {
        if let _ = _hosts {
            return _hosts!
        }
        
        let context = managedObjectContext

        if let array = fetchEntity(context, entity: "Host") as? Array<Host> {
            if array.count > 0 {
                _hosts = array
            }
        }
        
        return _hosts
    }

    func HostWithId(id: String) -> Host! {
        let context = managedObjectContext

        let predicate = NSPredicate(format: "id = %@", id)

        if let array = fetchEntity(context, entity: "Host", predicate: predicate) as? Array<Host> {
            if array.count > 0 {
                return array.first
            }
        }
        
        return nil
    }

    /**
     * Save Host list
     */
    func AddPurposes(array : Array<String>?) {
        NSUserDefaults.standardUserDefaults().setValue(array, forKey: "kGuestPurposes")
    }
    

    /**
    * Get all Purpose Types
    */
    var _purposes: Array<String>? = nil
    func Purposes() -> Array<String>! {
        if let _ = _purposes {
            return _purposes!
        }
        
        if let array = NSUserDefaults.standardUserDefaults().valueForKey("kGuestPurposes") as? Array<String> {
            if array.count > 0 {
                _purposes = array
            }
        }

        return _purposes
    }


    // MARK: - Core Data stack

    func fetchEntity (context: NSManagedObjectContext, entity: String, predicate: NSPredicate? = nil, sortDescriptors: Array<NSSortDescriptor>? = nil, grouping: Array<String>? = nil, limit: Int = 0) -> AnyObject! {
        let moc: NSManagedObjectContext = context
        let entity = NSEntityDescription.entityForName(entity, inManagedObjectContext: context)
        
        
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entity
        request.fetchLimit = limit
        
        if let _ = grouping {
            request.propertiesToGroupBy = grouping
            request.resultType = .DictionaryResultType
        }
        
        if let _ = predicate {
            request.predicate = predicate
        }
        
        if let _ = sortDescriptors {
            request.sortDescriptors = sortDescriptors
        }
        
        
        do {
            let array = try moc.executeFetchRequest(request)
            if let _ = array as? AnyObject {
                return array
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.a2.iRegistration" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("iRegistration", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    /**
    * Save the context
    *
    * @params context The NSManagedObjectContext to save
    */
    func saveContext(context: NSManagedObjectContext? = nil) {
        var contextToSave: NSManagedObjectContext?

        if context == nil {
           contextToSave = managedObjectContext
        }
        else {
            contextToSave = context
        }

        if contextToSave!.hasChanges {
            do {
                try contextToSave!.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}
