//
//  BluetoothDeviceInterface.swift
//  Attendance
//
//  Created by Alex on 2/12/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

typealias ProgressTask = (Float, Float)->()

/**
 * Interface class for connecting to thermometer
 *
 * Members:
 * sharedInstance Singleton instance
 *
 */
class BluetoothDeviceInterface: NSObject {
    var progressBlock : ProgressTask? = nil
    
    var targetPeripheral: Dictionary<String, LGPeripheral>?
    var targetService: Dictionary<String, LGService>?
    var targetCharacteristic: Dictionary<String, LGCharacteristic>?
    
    let scanDuration: UInt = 3
    var scanStart: NSDate? = nil
    var timer: NSTimer? = nil
    
    class var sharedInstance: BluetoothDeviceInterface {
        struct Static {
            static var instance: BluetoothDeviceInterface?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = BluetoothDeviceInterface()
        }
                
        return Static.instance!
    }

    /**
     * Service UUID
     * 1809 Thermometer Service UUID
     * fff0 ID Scanner Service UUID
     *
     * Characteristic UUID
     * 2a1c Thermometer Temperature Char UUID
     * fff1 ID Scanner Char UUID
     * fff2 Finger Print Scanner Char UUID
     */
    
    let thermometerServiceID = "1809"
    let scannerServiceID = "fff0"

    let thermometerTempCharID = "2a1c"
    let scannerIDCharID = "fff1"
    let scannerFingerPrintCharID = "fff2"
    
    
    var serviceUUID: String {
//        return "\(scannerServiceID),\(thermometerServiceID)"
        return "\(thermometerServiceID)"
    }
    var characteristicUUID: String {
//        return "\(thermometerTempCharID),\(scannerIDCharID),\(scannerFingerPrintCharID)"
        return "\(thermometerTempCharID)"
    }
    
    var deviceNotFoundError: String {
        return "Device Not Found"
    }
    
    /**
     * Bluetooth
     *
     * Members:
     * completion Completion callback
     *       error String description of error
     *       result Float value of the temperature in Celcius
     */
    func initialize() {
        // Get the singleton shared instance of LGCentralManager
        let lgcm = LGCentralManager.sharedInstance()
        lgcm.scanForPeripherals()
    }
    
    /**
     * Bluetooth
     *
     * Members:
     * completion Completion callback
     *       error String description of error
     *       result Float value of the temperature in Celcius
     */
    func scanForDevice(progress: ProgressTask, completion: (error: String?) -> Void) {
        weak var weakSelf = self
        
        // Reset service & characteristic
        targetService = nil
        targetCharacteristic = nil
        
        // Set the progress block
        progressBlock = progress
        
        // Save the start time of scanning
        scanStart = NSDate()
        
        // Call the progress block
        progressBlock!(0.0, Float(scanDuration))
        
        // Start the timer for the progress block
        if (timer == nil) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(BluetoothDeviceInterface.scanProgress), userInfo: nil, repeats: true)
        }
        
        // Get the singleton shared instance of LGCentralManager
        let lgcm = LGCentralManager.sharedInstance()
        
        // 1. Scan for BLE devices
        lgcm.scanForPeripheralsByInterval(scanDuration, completion: { peripherals in
            
            // 2. Kill timer after the scan duration
            if let _ = weakSelf?.timer {
                weakSelf?.timer!.invalidate()
                weakSelf?.timer = nil
            }
            
            // 3. Return Error if no devices were located
            if peripherals.count == 0 {
                completion (error: self.deviceNotFoundError)
            }
            // 4. Return Error if no devices were located
            else {
                // 5. Connect to all AVAILABLE peripherals
                for peripheral in peripherals {
                    
                    peripheral.connectWithCompletion { error in
                        
                        peripheral.discoverServicesWithCompletion{ services, error in
                            
                            // 6. Search for the service with UDID
                            for service in services {
                                NSLog("service.UUIDString: %@", service.UUIDString)

                                var serviceFound = false
                                if self.serviceUUID.containsString(service.UUIDString.lowercaseString)  {
                                    serviceFound = true
                                    if weakSelf?.targetService == nil {
                                        weakSelf?.targetService = Dictionary<String, LGService>()
                                    }
                                    weakSelf?.targetService![service.UUIDString.lowercaseString] = service as? LGService
                                    
                                    service.discoverCharacteristicsWithCompletion { characteristics, error in
                                        
                                        // 7. Search for the characteristic with UDID
                                        for characteristic in characteristics {
                                            NSLog("characteristic.UUIDString: %@", characteristic.UUIDString)
                                            if self.characteristicUUID.containsString(characteristic.UUIDString.lowercaseString) {
                                                if weakSelf?.targetCharacteristic == nil {
                                                    weakSelf?.targetCharacteristic = Dictionary<String, LGCharacteristic>()
                                                }
                                                weakSelf?.targetCharacteristic![characteristic.UUIDString.lowercaseString] = characteristic as? LGCharacteristic

                                                if weakSelf?.targetPeripheral == nil {
                                                    weakSelf?.targetPeripheral = Dictionary<String, LGPeripheral>()
                                                }
                                                weakSelf?.targetPeripheral![characteristic.UUIDString.lowercaseString] = peripheral as? LGPeripheral

                                                // 8. Set the notifier when the device updates a value
                                                characteristic.setNotifyValue(true,
                                                    completion: { error in

                                                        // 9. Call the completion block, notify of error or success
                                                        NSLog("completion for \(self.characteristicUUID)")
                                                        
                                                        if let _ = error {
                                                            completion (error: self.deviceNotFoundError)
                                                        }
                                                        else {
                                                            completion (error: nil)
                                                        }
                                                        
                                                    }, onUpdate: { data, error in
                                                        // 10. Wait for an update from the connected device and decode data
                                                        NSLog("onUpdate for \(self.characteristicUUID)")
                                                        weakSelf?.decodeData(data, serviceUUID: service.UUIDString, characteristicUUID: characteristic.UUIDString)
                                                })
                                            }
                                        }
                                        
                                        completion (error: "")
                                    }
                                }
                                
                                if !serviceFound {
                                    completion (error: "Device Service Not Found")
                                }
                           }
                            
//                            if weakSelf?.targetService == nil {
//                                completion (error: self.deviceNotFoundError)
//                            }
                        }
                    }
                }
            }
        })
    }
    
    
    /**
     * Progress block when linking to a device
     */
    func scanProgress() {
        if let _ = progressBlock {
            let currentTime = Float(NSDate().timeIntervalSinceDate(scanStart!))
            let duration = Float(scanDuration)
            progressBlock!(currentTime / duration, duration - currentTime)
        }
    }
    
    
    /**
     * Establishes a connection to the bluetooth device
     *
     * Params:
     * progress The Progress callback
     *       - progress The progress of the process, value is 0.0->1.0
     *       - remainingTime The remaining time of the process in seconds
     * completion The Completion callback
     *       - error The String description of error
     */
    func linkDevice(progress:((progress: Float, remainingTime: Float) -> Void)!, completion: ((error: String?) -> Void)!) {
        
        scanForDevice(progress, completion: {
            error -> Void in
            if (error == nil) {
                completion(error: error)
            }
            else {
                completion(error: nil)
            }
        })
        
    }
    
    /**
     * Decode the data the bluetooth device
     *
     * Params:
     * data Data received from BLE device
     *
     */
    func decodeData(data: NSData?, serviceUUID: String?, characteristicUUID: String?) {
        if serviceUUID == "1809" {
            ThermometerDataDecoder.sharedInstance.decodeData(data, serviceUUID: serviceUUID, characteristicUUID: characteristicUUID)
        }
    }
}
