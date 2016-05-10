//
//  PrinterInterface.swift
//  iRegistration
//
//  Created by Alex on 23/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

typealias DidFindPrinters = (Array<AnyObject>?)->()

/**
* Interface class for connecting to printer
*
* Members:
* sharedInstance Singleton instance
*
*/
class PrinterInterface: BluetoothDeviceInterface, BRPtouchNetworkDelegate {
    override class var sharedInstance: PrinterInterface {
        struct Static {
            static var instance: PrinterInterface?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PrinterInterface()
        }
        
        return Static.instance!
    }

    var _printTouchNetwork: BRPtouchNetwork?
    var printTouchNetwork: BRPtouchNetwork {
        if _printTouchNetwork == nil {
            _printTouchNetwork = BRPtouchNetwork()
            _printTouchNetwork?.delegate = self
        }
        return _printTouchNetwork!
    }
    
    func startSearch() {
        if let path = NSBundle.mainBundle().pathForResource("PrinterList", ofType: "plist") {
            
            let printerDict: NSDictionary! = NSDictionary(contentsOfFile: path)
            
            let printerList = NSArray(array: printerDict.allKeys)
            printTouchNetwork.setPrinterNames(printerList as [AnyObject])
        }
        
        //	Start printer search
        printTouchNetwork.startSearch(5)
    }
    
    var printers: Array<AnyObject>? = nil
    var didFindPrinters: DidFindPrinters? = nil
    func didFinishedSearch(sender: AnyObject!) {
        printers = _printTouchNetwork?.getPrinterNetInfo()
        
        if let _ = printers {
            if printers?.count > 0 {
                selectPrinter(printers![0] as? BRPtouchNetworkInfo)
            }
        }
        
        if let _ = didFindPrinters {
            didFindPrinters! (printers)
        }
    }
    
    // Printer Connection
    var _currentPrinterIP: String? = nil
    var currentPrinterIP: String? {
        if _currentPrinterIP == nil {
            if let value = NSUserDefaults.standardUserDefaults().stringForKey("currentPrinterIP") {
                _currentPrinterIP = value
            }
        }
        return _currentPrinterIP
    }
    
    var _currentPrinterName: String? = nil
    var currentPrinterName: String? {
        if _currentPrinterName == nil {
            if let value = NSUserDefaults.standardUserDefaults().stringForKey("currentPrinterName") {
                _currentPrinterName = value
            }
        }
        return _currentPrinterName
    }
    
    func selectPrinter (touchNetworkInfo: BRPtouchNetworkInfo? = nil) {
        //Save IP Address
        _currentPrinterIP = touchNetworkInfo?.strIPAddress
        NSUserDefaults.standardUserDefaults().setObject(_currentPrinterIP, forKey: "currentPrinterIP")
        
        // Save Printer Name
        _currentPrinterName = touchNetworkInfo?.strModelName
        NSUserDefaults.standardUserDefaults().setObject(_currentPrinterName, forKey: "currentPrinterName")
    }
    
    func isConnectedToNetwork() -> Bool {
        let wifiReachability: Reachability = Reachability.reachabilityForLocalWiFi()
        if wifiReachability.currentReachabilityStatus() == NotReachable {
            return false
        }
        return true
    }

    var _printInfo: BRPtouchPrintInfo? = nil
    var printInfo: BRPtouchPrintInfo {
        if let _ = _printInfo {
            return _printInfo!
        }

        let pi = BRPtouchPrintInfo()
        pi.strPaperName = "Custom"
        pi.ulOption = 0
        pi.nPrintMode = 1
        pi.nDensity = 0
        pi.nOrientation = 1
        pi.nHalftone = 2
        pi.nHorizontalAlign = 1
        pi.nVerticalAlign = 1
        pi.nPaperAlign = 0
        pi.nExtFlag = 0
        pi.nAutoCutFlag = 0
        pi.nAutoCutCopies = 0
        pi.nExMode = 0
        
        _printInfo = pi
        
        return _printInfo!
    }

    var _touchPrinter: BRPtouchPrinter? = nil
    var touchPrinter: BRPtouchPrinter {
        if let _ = _touchPrinter {
            return _touchPrinter!
        }
        
        let ptp = BRPtouchPrinter(printerName: currentPrinterName)
        
        ptp.setIPAddress(currentPrinterIP!)
        if (printInfo.strPaperName == "Custom") {
            let strPath = NSBundle.mainBundle().pathForResource("51_20_700", ofType: "bin")
            ptp.setCustomPaperFile(strPath)
        }
        
        ptp.setPrintInfo(printInfo)
        
        _touchPrinter = ptp
        
        return _touchPrinter!
    }

    func isPrinterReady() -> Bool {
        if currentPrinterIP == nil {
            return false
        }
        
        if currentPrinterName == nil {
            return false
        }
        
        let ptp = touchPrinter
        
        return ptp.isPrinterReady()
    }
    
    func print(text: Array<String>, completion: (error: String?)->()) {
        if currentPrinterIP == nil {
            completion (error: "Printer IP Not Found.")
            return
        }

        if currentPrinterName == nil {
            completion (error: "Printer Name Not Found.")
            return
        }

        // Get Print Info
        let app = UIApplication.sharedApplication()
        let bgTask = app.beginBackgroundTaskWithExpirationHandler { () -> Void in
            
        }
    
        //	Get ImageRef
        let image = printImage(text)
        let	imgRef = image!.CGImage

        if (nil == imgRef) {
            completion(error: "Image Blank!")
            return
        }
        
        let ptp = touchPrinter
        
        if (ptp.isPrinterReady()) {
            ptp.printImage(imgRef, copy: 1, timeout: 500)
        }
        else {
            completion(error: "Printing error. Please check your network settings and try again.")
            return
        }
        
        completion(error: nil)

        app.endBackgroundTask(bgTask)
    }
    
    func printImage(text: Array<String>)-> UIImage? {
        let view = UIView()
        view.frame = CGRectMake(0, 0, 250, 65)
        view.backgroundColor = UIColor.whiteColor()

        let fontSize: CGFloat = 16
        let width: CGFloat = view.frame.size.width - 10
        let height: CGFloat = 19
        var currentY: CGFloat = 0
        
        var index = 0
        for t in text {
            let label = UILabel(frame: CGRectMake(0, currentY, width, height))
            label.text = t
            label.backgroundColor = UIColor.clearColor()
            label.font = index == 0 ? UIFont(name: "HelveticaNeue-Bold", size: fontSize + 4) : UIFont(name: "HelveticaNeue", size: fontSize)
            label.clipsToBounds = false
            label.textColor = UIColor.blackColor()
            view.addSubview(label)
            currentY = label.frame.origin.y + label.frame.size.height + (index == 0 ? 4 : 0)
            index += 1
        }

        let image = UIImage(named: "logo-print.png")
        let imageHeight: CGFloat = 34
        let imageWidth: CGFloat = (image?.size.width)! * (imageHeight / (image?.size.height)!)
        let imageView = UIImageView(frame: CGRectMake(view.frame.size.width - imageWidth, 0, (image?.size.width)! * (imageHeight / (image?.size.height)!), imageHeight))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        view.addSubview(imageView)

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 1.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img
    }
}
