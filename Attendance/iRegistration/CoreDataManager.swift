//
//  CoreDataManager.swift
//  iRegistration
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
    
    
    /**
    * Add a User object to Core Data
    */
    func SaveUser(userInfo: Dictionary<String, AnyObject!>!) -> User! {
        let context = managedObjectContext
        
        var predicate: NSPredicate? = nil
        if let email = userInfo["email"] as? String {
            predicate = NSPredicate(format: "email == %@", email)
        }
        
        var user: User? = nil
        if let users = self.fetchEntity(context, entity: "User", predicate: predicate) as? Array<User> {
            user = users.first
        }
        
        if user == nil {            
            let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
            if let newUser = NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: context) as? User {
                user = newUser
            }
        }
    
        if let value = userInfo["name"] as? String {
            user!.name = value
        }
        else {
            user!.name = "User"
        }
        
        if let value = userInfo["timeStamp"] as? String {
            let df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mma"
            user!.timeStamp = df.dateFromString(value)
        }
        else {
            user!.timeStamp = nil
        }
        
        if let value = userInfo["email"] as? String {
            user!.email = value
        }
        else {
            user!.email = nil
        }
        
        if let value = userInfo["isLate"] {
            user!.isLate = NSNumber(bool: (value.boolValue)!)
        }
        else {
            user!.isLate = NSNumber(bool: false)
        }
        
        if let value = userInfo["lateCount"] {
            user!.lateCount = NSNumber(int: (value.intValue)!)
        }
        else {
            user!.lateCount = NSNumber(int: 0)
        }
        
        if let value = userInfo["fingerprintTemplate"] as? String {
            user!.fingerprintTemplate = value
        }

        if let value = userInfo["cardId"] as? String {
            user!.cardId = value
        }

        saveContext()
        
        return user
    }

    
    /**
    * Add a User
    */
    var _user: User? = nil
    var LoggedInUser: User? {
        if let _ = _user {
            return _user
        }
        return _user
    }
    
    func LoginUser(userInfo: Dictionary<String, AnyObject>!) -> User? {
        if let users = getAllUsers() {
            let context = managedObjectContext
            for user in users {
                context.deleteObject(user)
            }
            saveContext(context)
        }
        
        _user = SaveUser(userInfo)
        
        return _user
    }

    func LogoutUser() {
        if let user = self.LoggedInUser {
            let context = managedObjectContext
            context.deleteObject(user)
            saveContext(context)
        }
    }

    
    /**
     * Get ALL list of Users to upload
     */
    func getAllUsers() -> Array<User>! {
        let context = managedObjectContext
        
        return self.fetchEntity(context, entity: "User") as? Array<User>
    }

    
    /**
     * Get the list of Users to upload
     */
    func getUsersToUpload() -> Array<User>! {
        let context = managedObjectContext

        let predicate = NSPredicate(format: "upload != %d", true)

        return self.fetchEntity(context, entity: "User", predicate: predicate) as? Array<User>
    }
    
    /**
     * Get the list of Users to upload
     */
    func getUsersToUploadLoginData() -> Array<User>! {
        let context = managedObjectContext
        
        let predicate = NSPredicate(format: "fingerprintTemplate != NULL OR cardId != NULL")
        
        return self.fetchEntity(context, entity: "User", predicate: predicate) as? Array<User>
    }
    
    
    /**
     * Returns an Array of Dictionaries from all User objects to upload
     *
     * Sample Data to upload API:
     "email": "Angel Wing",
     "temperature": "36",
     "image": "",
     
     */
    func UsersDataToUploadDictionaries(guestArray: Array<User>? = nil) -> Array<Dictionary<String, AnyObject>>! {
        var parameters = Array<Dictionary<String, AnyObject>>()
        
        let users = guestArray != nil ? guestArray : UsersToUpload()
        for user in users {
            // Fill with Default value
            let email = user.email != nil ? user.email! : ""
            let temperature = user.temperature != nil ? "\(user.temperature!.floatValue)" : ""
            var image = ""
            if let i = user.image {
                let value = i.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                image = value
            }
            
            var dict:[String:String] = [
                "email": email,
                "temperature": temperature,
                "image": image]

            
            if user.fingerprintTemplate != nil {
                dict["fingerprintTemplate"] = user.fingerprintTemplate
            }
            if user.cardId != nil {
                dict["cardId"] = user.cardId
            }
//            dict["fingerprintTemplate"] = "ABCDEFG"
//            dict["cardId"] = "ABCDEFG"

            parameters.append(dict)
        }
        
        return parameters
    }

    
    /**
     * Returns an Array of User objects with isUploaded = 0
     */
    func UsersToUpload() -> Array<User>! {
        let context = managedObjectContext
        
        if let array = fetchEntity(context, entity: "User") as? Array<User> {
            var users = Array<User>()
            for user in array {
//                if ((user.shouldUpload?.boolValue) == true) {
                    users.append(user)
//                }
            }
            if users.count > 0 {
                return users
            }
        }
        
        return nil
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
            
            dict[NSUnderlyingErrorKey] = error as! NSError
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
