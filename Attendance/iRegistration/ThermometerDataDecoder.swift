//
//  ThermometerDataDecoder.swift
//  iRegistration
//
//  Created by Alex on 23/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

let kDidScanTemperatureNotification = "kDidScanTemperatureNotification"

/**
* Interface class for connecting to thermometer
*
* Members:
* sharedInstance Singleton instance
*
*/
class ThermometerDataDecoder: BluetoothDeviceInterface {
    override class var sharedInstance: ThermometerDataDecoder {
        struct Static {
            static var instance: ThermometerDataDecoder?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ThermometerDataDecoder()
        }
        
        return Static.instance!
    }
    
    /**
     * Override the service UUID 1809
     * Override the characteristic UUID 2a1c
     */
    override var deviceNotFoundError: String {
        return "Thermometer Not Found"
    }
    
    /**
     * Parse the data from Scanner
     * Decode 4 bytes to Float32 value
     */
    func parseToFloat32(bytes:[UInt8]) -> Double {
        if bytes.count < 4 {
            return 0.0
        }
        
        let string = NSString(format: "%02x%02x%02x%02x", bytes[0], bytes[1], bytes[2], bytes[3])

        let subStringCode: NSString = string
        
        // Rearrange the hex values
        let hexString = NSString(format: "%@%@%@",
            subStringCode.substringWithRange(NSMakeRange(4, 2)),
            subStringCode.substringWithRange(NSMakeRange(2, 2)),
            subStringCode.substringWithRange(NSMakeRange(0, 2)))
        
        NSLog("hexString: %@", hexString)
        
        // Get the Mantissa
        var outVal: UInt32 = 0
        let scanner: NSScanner = NSScanner(string: hexString as String)
        scanner.scanHexInt(&outVal)
        
        NSLog("Mantissa = %i", outVal)
        
        // Get the Exponent
        let hexDecimaPlaces: NSString = subStringCode.substringWithRange(NSMakeRange(6, 2))
        var decValue: UInt32 = 0
        let scannerValue: NSScanner = NSScanner(string: hexDecimaPlaces as String)
        scannerValue.scanHexInt(&decValue)

        NSLog("Exponent = %i", outVal)

        let power: Double = Double (UInt32(256) - decValue)
        let dividePlace: Double = pow(10, power)
        
        NSLog("dividePlaces = %f", dividePlace)
        NSLog("power = %f", power);

        let floatValue: Double = Double(outVal) / Double(dividePlace)
        return floatValue
    }
    
    /**
     * Decode the temperature from the scanner
     *
     * Params:
     * data The 5-byte data from thermometer scanner
     *
     */
    override func decodeData(data: NSData?, serviceUUID: String?, characteristicUUID: String?) {
        if data != nil {
            let count = (data?.length)! / sizeof(UInt8)
            
            // Create array of appropriate length:
            var array = [UInt8](count: count, repeatedValue: 0)

            // Copy bytes into array
            data!.getBytes(&array, range: NSMakeRange(1, 4))
            
            let temperature = parseToFloat32(array)
            NSLog("%.2f", temperature)

            // Post the Notification
            NSNotificationCenter.defaultCenter().postNotificationName(kDidScanTemperatureNotification, object: temperature)
        }
    }
}
