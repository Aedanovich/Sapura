//
//  FingerPrintScannerDataDecoder.swift
//  iRegistration
//
//  Created by Alex on 27/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

let kDidDecodeIDNotification = "kDidDecodeIDNotification"
let kDidDecodeFingerPrintNotification = "kDidDecodeFingerPrintNotification"
let kDidReceiveFingerPrintNotification = "kDidReceiveFingerPrintNotification"

/**
* Interface class for connecting to Finger Print Scanner
*
* Members:
* sharedInstance Singleton instance
*
*/
class FingerPrintScannerDataDecoder: BluetoothDeviceInterface {
    var bluetoothControl: BluetoothControl?
    var fingerPrintScannerDelegate: FingerPrintScannerDelegate?
    override class var sharedInstance: FingerPrintScannerDataDecoder {
        struct Static {
            static var instance: FingerPrintScannerDataDecoder?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = FingerPrintScannerDataDecoder()
            Static.instance?.bluetoothControl = BluetoothControl()
            Static.instance?.fingerPrintScannerDelegate = FingerPrintScannerDelegate()
        }
        
        return Static.instance!
    }
    
    /**
     * Override the service UUID 1809
     * Override the characteristic UUID 2a1c
     */
    override var deviceNotFoundError: String {
        return "ID Scanner Not Found"
    }
    
    override func linkDevice(progress: ((progress: Float, remainingTime: Float) -> Void)!, completion: ((error: String?) -> Void)!) {
        fingerPrintScannerDelegate?.bluetoothControl = self.bluetoothControl
        bluetoothControl?.setDelegateObject(fingerPrintScannerDelegate, setBluetoothCallback: "BluetoothCallback:Message:")
        bluetoothControl?.callTest()
        bluetoothControl?.Open()
    }
    
    /**
     * Decode the ID from the scanner
     *
     * Params:
     * data The 14-byte data from ID scanner
     *
     */
    override func decodeData(data: NSData?, serviceUUID: String?, characteristicUUID: String?) {
        if data != nil {
            let count = (data?.length)! / sizeof(UInt8)
            
            // Create array of appropriate length:
            var array = [UInt8](count: count, repeatedValue: 0)
            
            // Copy bytes into array
            data!.getBytes(&array, range: NSMakeRange(0, count))

            let string = bluetoothControl!.DecodeIDData(data, message: nil)
            
            // Post the Notification
            NSNotificationCenter.defaultCenter().postNotificationName(kDidDecodeIDNotification, object: string)
        }
    }
    
    /**
    * Send Fingerprint Scan Request
    */
    func scanFingerPrint() {
        bluetoothControl!.SendCommand(UInt8(CMD_CAPTUREHOST), data: nil, size: 0)
    }

    /**
     * Match Fingerprint Templates
     */
    func matchFingerPrint(mfpData1: NSData?, mfpData2: NSData?) -> Bool {
        if(mfpData1 != nil && mfpData2 != nil && mfpData1!.length <= 512 && mfpData2!.length <= 512){
            // Length
            let count1 = mfpData1!.length / sizeof(UInt8)
            // create an array of Uint8
            var array1 = [UInt8](count: 512, repeatedValue: 0)
            // copy bytes into array
            mfpData1!.getBytes(&array1, length:count1)

            // Length
            let count2 = mfpData2!.length / sizeof(UInt8)
            // create an array of Uint8
            var array2 = [UInt8](count: 512, repeatedValue: 0)
            // copy bytes into array
            mfpData2!.getBytes(&array2, length:count2)

            // Full Array
            var fullArray = array1
            fullArray.appendContentsOf(array2)
            
            bluetoothControl!.SendCommand(0x09, data: &fullArray, size: 1024)
            
            return true
        }
        
        return false
    }

    /**
     * Send Scan ID Scan Request
     */
    func scanID() {
        bluetoothControl!.SendCommand(0x0E, data: nil, size: 0)
    }

}
