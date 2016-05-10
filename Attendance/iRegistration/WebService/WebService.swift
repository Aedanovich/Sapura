//
//  WebService.swift
//  iRegistration
//
//  Created by Alex on 19/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

extension NSRange {
    func stringRangeForText(string: String) -> Range<String.Index> {
        let start = string.startIndex.advancedBy(self.location)
        let end = start.advancedBy(self.length)
        return Range<String.Index>(start: start, end: end)
    }
}

class WebService: NSObject {
    let server: String = "http://attendance.api.sapuraglobal.com/"
    class var photoServer: String {
        return "http://ireception.sapuraglobal.com/upload/guest_photos/"
    }
    
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
    * Login Webservice
    *
    * @param email String email
    * @param password String password
    * @param completion Completion block
    *            error - nil if successful, otherwise error message is passed
    *            result - result object
    */
    func LoginWithEmail(email: String, password: String, completion: ((error: String?, result: AnyObject?) -> Void)!) {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: server))
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let parameters = ["email": email,"password": password]
        
        manager.POST("\(server)login",
            parameters: parameters,
            success: { op, data in
                do {
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
                    
                    NSLog("\(jsonDict)")
                    
                    if let result = jsonDict["result"] as? NSNumber {
                        if result.boolValue {
                            completion(error: nil, result: jsonDict["data"])
                            return
                        }
                        else {
                            completion(error: "The username/password you entered is incorrect. Please try again.", result: nil)
                        }
                    }
                    else {
                        completion(error: "The username/password you entered is incorrect. Please try again.", result: nil)
                    }
                }
                catch {
                    completion(error: "The username/password you entered is incorrect. Please try again.", result: nil)
                }
            },
            failure: { op, error in
                completion(error: "The username/password you entered is incorrect. Please try again.", result: nil)
        })
    }


    /**
    * LoginWithFingerPrint Webservice
    *
    * @param data   The finger print data from BT Device
    * @param completion Completion block
    *            error - nil if successful, otherwise error message is passed
    *            result - result object
    */
    func LoginWithFingerPrint(email: String, completion: ((error: String?, result: AnyObject?) -> Void)!) {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: server))
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()

        let parameters = ["email": email]
        
        manager.POST("\(server)login-email",
            parameters: parameters,
            success: { op, data in
                do {
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
                    
                    if let result = jsonDict["result"] as? NSNumber {
                        if result.boolValue {
                            completion(error: nil, result: jsonDict["data"])
                            return
                        }
                    }
                    
                    completion(error: "The email is not valid. Please try again.", result: nil)
                }
                catch {
                    completion(error: "The email is not valid. Please try again.", result: nil)
                }
            },
            failure: { op, error in
                completion(error: "The email is not valid. Please try again.", result: nil)
        })
    }
    
    /**
    * LoginWithID Webservice
    *
    * @param data   The ID data from BT Device
    * @param completion Completion block
    *            error - nil if successful, otherwise error message is passed
    *            result - result object
    */
    func LoginWithID(cardId: String, completion: ((error: String?, result: AnyObject?) -> Void)!) {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: server))
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let parameters = ["cardId": cardId]
        
        manager.POST("\(server)login-card-id",
            parameters: parameters,
            success: { op, data in
                do {
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
                    
                    if let result = jsonDict["result"] as? NSNumber {
                        if result.boolValue {
                            completion(error: nil, result: jsonDict["data"])
                            return
                        }
                    }
                    
                    completion(error: "The card is not valid. Please try again.", result: nil)
                }
                catch {
                    completion(error: "The card is not valid. Please try again.", result: nil)
                }
            },
            failure: { op, error in
                completion(error: "The card is not valid. Please try again.", result: nil)
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
        
        manager.POST("\(server)forgot-password",
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
    func GetSettings(completion: ((error: String?, result: AnyObject?) -> Void)!) {
        
    }

    
    /**
     * Upload Users
     *
     * Sample Data to upload API:
     * email: "test@sapuraglobal.com",
     * temperature: "36",
     * image: ""
     *
     * @param completion Completion block
     *            error - nil if successful, otherwise error message is passed
     *            result - result object
     */
    var IsUploadingUsers: Bool = false
    
    func UploadUsers(completion: ((error: String?, result: AnyObject?) -> Void)?) {
        let cdm = CoreDataManager.sharedInstance
        if let guestArray = cdm.UsersToUpload() {
            if guestArray.count > 0 {
                IsUploadingUsers = true
                
                let manager = AFHTTPSessionManager(baseURL: NSURL(string: server))
                manager.requestSerializer = AFJSONRequestSerializer()
                manager.responseSerializer = AFHTTPResponseSerializer()
                
                let user = cdm.UsersDataToUploadDictionaries(guestArray)
                let parameters = ["data": user]
                
                NSLog("\(parameters)")
                
                manager.POST("\(server)upload-multiple-guest",
                    parameters: parameters,
                    success: { op, data in
                        if let resultData = data as? NSData {
                            let string = String(data: resultData, encoding: 0)
                            NSLog(string!)
                        }
                        completion?(error: nil, result: nil)
                    },
                    failure: { op, error in
                        self.IsUploadingUsers = false
                        
                        completion?(error: "Cannot upload users.", result: nil)
                })
                
                return
            }
        }
        
        completion?(error: nil, result: nil)
    }
}
