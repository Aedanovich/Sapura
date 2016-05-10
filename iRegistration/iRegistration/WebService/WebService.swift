//
//  WebService.swift
//  iReception
//
//  Created by Alex on 19/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

class WebService: NSObject {

    class var sharedInstance: WebService {
        struct Static {
            static var instance: WebService?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = WebService()
        }
        
        return Static.instance!
    }

    
    /**
     * Server URL
     */
    let server: String = "http://registration.sapuraglobal.com/api/public/"
    class var photoServer: String {
        return "http://registration.sapuraglobal.com/upload/guest_photos/"
    }
    
    /**
    * Login Webservice
    *
    * @param email String email
    * @param password String password
    * @param completion Completion block
    *            error - nil if successful, otherwise error message is passed
    *            result - result object
    */
    func Login(email: String, password: String, completion: ((error: String?, result: AnyObject?) -> Void)!) {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: server))
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()

        let parameters = ["email": email,"password": password]

        manager.POST("user/login",
            parameters: parameters,
            success: { op, data in
                do {
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
                    
                    if let result = jsonDict["result"] as? NSNumber {
                        if result.boolValue {

                            if let userInfo = jsonDict["data"] as? Dictionary<String, AnyObject> {
                                CoreDataManager.sharedInstance.LoginUser(userInfo)
                            }

                            completion(error: nil, result: ["email" : email])
                            return
                        }
                    }
                    
                    completion(error: "The username/password you entered is incorrect. Please try again.", result: nil)
                }
                catch {
                    completion(error: "The username/password you entered is incorrect. Please try again.", result: nil)
                }
            },
            failure: { op, error in
                completion(error: "Could not connect to server. Please try again.", result: nil)
        })
    }


    /**
    * Logout Webservice
    *
    * @param email String email
    * @param completion Completion block
    *            error - nil if successful, otherwise error message is passed
    */
    func Logout(email: String, completion: ((error: String?) -> Void)!) {
        // Delay execution of my block for 10 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            completion(error: nil)
        }
    }
    
    /**
     * ForgetPassword Webservice
     *
     * @param email String email
     * @param completion Completion block
     *            error - nil if successful, otherwise error message is passed
     *            result - result object
     */
    func ForgetPassword(email: String, completion: ((error: String?, result: AnyObject?) -> Void)!) {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: server))
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let parameters = ["email": email]
        
        manager.POST("user/forget-password",
            parameters: parameters,
            success: { op, data in
                do {
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
                    
                    if let result = jsonDict["result"] as? NSNumber {
                        if result.boolValue {
                            completion(error: nil, result: ["email" : email])
                            return
                        }
                    }
                    
                    completion(error: "The username you entered is incorrect. Please try again.", result: nil)
                }
                catch {
                    completion(error: "The username you entered is incorrect. Please try again.", result: nil)
                }
            },
            failure: { op, error in
                completion(error: "Could not connect to server. Please try again.", result: nil)
        })
    }

    
    /**
    * Download Settings
    *
    * @param email String email
    * @param password String password
    * @param completion Completion block
    *            error - nil if successful, otherwise error message is passed
    *            result - result object
    */
    var IsGettingSettings: Bool = false

    func GetSettings(completion: ((error: String?, result: AnyObject?) -> Void)?) {
        IsGettingSettings = true
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.GET("\(server)data-listing",
            parameters: nil,
            success: { op, data in
                self.IsGettingSettings = false
                do {
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
                    
                    if let hosts = jsonDict["hosts"] as? Array<Dictionary<String, AnyObject!>>? {
                        CoreDataManager.sharedInstance.AddHosts(hosts)
                    }

                    if let showPrint = jsonDict["showPrint"] as? NSNumber {
                        CoreDataManager.sharedInstance.showPrint = showPrint.boolValue
                    }

                    if let showTemperature = jsonDict["showTemperature"] as? NSNumber {
                        CoreDataManager.sharedInstance.showTemperature = showTemperature.boolValue
                    }

                    if let purposes = jsonDict["purpose"] as? Array<String>? {
                        CoreDataManager.sharedInstance.AddPurposes(purposes)
                    }
                    
                    completion?(error: nil, result: nil)
                }
                catch {
                    completion?(error: "Cannot update settings.", result: nil)
                }
            },
            failure: { op, error in
                self.IsGettingSettings = false

                completion?(error: "Cannot update settings.", result: nil)
        })
    }
    
    
    
    /**
     * Download Guests
     *
     * Sample Data from API:
     * guests_name: "Angel Wing",
     * guests_nric: "S1122334F",
     * guests_phone: "87655243",
     * guests_organization: "Sapura Synergy",
     * guests_host_staff_id: "1",
     * guests_purpose: "Meeting",
     * guests_temperature: "36",
     *
     * @param completion Completion block
     *            error - nil if successful, otherwise error message is passed
     *            result - result object
     */
    var IsGettingGuests: Bool = false

    func GetGuests(completion: ((error: String?, result: AnyObject?) -> Void)?) {
        IsGettingGuests = true
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.GET("\(server)guest/all",
            parameters: nil,
            success: { op, data in
                self.IsGettingGuests = false
                do {
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)

                    if let guests = jsonDict["data"] as? Array<Dictionary<String, AnyObject!>>? {
                        CoreDataManager.sharedInstance.AddGuests(guests)
                    }
                    
                    completion?(error: nil, result: nil)
                }
                catch {
                    completion?(error: "Cannot update settings.", result: nil)
                }
            },
            failure: { op, error in
                self.IsGettingGuests = false
                
                completion?(error: "Cannot download guests.", result: nil)
        })
    }

    
    /**
     * Upload Guests
     *
     * Sample Data from API:
     * guests_name: "Angel Wing",
     * guests_nric: "S1122334F",
     * guests_phone: "87655243",
     * guests_organization: "Sapura Synergy",
     * guests_host_staff_id: "1",
     * guests_purpose: "Meeting",
     * guests_temperature: "36",
     *
     * @param completion Completion block
     *            error - nil if successful, otherwise error message is passed
     *            result - result object
     */
    var IsUploadingGuests: Bool = false

    func UploadGuests(completion: ((error: String?, result: AnyObject?) -> Void)?) {
        let cdm = CoreDataManager.sharedInstance
        if let guestArray = cdm.GuestsToUpload() {
            if guestArray.count > 0 {
                let guests = cdm.GuestsToUploadDictionaries(guestArray)
                
                IsUploadingGuests = true
                
                let manager = AFHTTPSessionManager(baseURL: NSURL(string: server))
                manager.requestSerializer = AFJSONRequestSerializer()
                manager.responseSerializer = AFHTTPResponseSerializer()
                
                let parameters = ["data": guests]
                
                manager.POST("guest/insert-multiple-guests-data",
                    parameters: parameters,
                    success: { op, data in
                        do {
                            let jsonDict = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
                            
                            if let dictArray = jsonDict["data"] as? NSArray {
                                var index: Int = 0
                                for dict in dictArray {
                                    if guestArray.count > index {
                                        let guest = guestArray[index]
                                        if let guestData = dict["data"] as? NSDictionary {
                                            if let userId = guestData["id"] {
                                                guest.id = String(userId)
                                            }
                                        }
                                    }
                                    index += 1
                                 }
                            }
                        }
                        catch {
                            
                        }
                        
                        for guest in guestArray {
                            guest.shouldUpload = NSNumber(bool: false)
                        }
                        
                        cdm.saveContext(cdm.managedObjectContext)
                        
                        completion?(error: nil, result: nil)
                    },
                    failure: { op, error in
                        self.IsUploadingGuests = false
                        
                        completion?(error: "Cannot upload guests.", result: nil)
                })
                
                return
            }
        }
        
        completion?(error: nil, result: nil)
    }
}
