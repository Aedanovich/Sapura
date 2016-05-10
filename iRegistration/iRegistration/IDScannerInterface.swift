//
//  IDScannerInterface.swift
//  iRegistration
//
//  Created by Alex on 27/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

/**
* Interface class for connecting to Finger Print Scanner
*
* Members:
* sharedInstance Singleton instance
*
*/
class IDScannerInterface: BluetoothDeviceInterface {
    class var sharedInstance: IDScannerInterface {
        struct Static {
            static var instance: IDScannerInterface?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = IDScannerInterface()
        }
        
        return Static.instance!
    }
}