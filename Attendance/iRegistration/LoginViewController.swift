//
//  LoginViewController.swift
//  iRegistration
//
//  Created by Alex on 18/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

/**
* UIViewController class for Login.
*
* Members:
* loginView The LoginView class for all UIView components
*
* @see WebService The class wrapper for all AFNetworking calls
*/
class LoginViewController: BaseViewController, LoginViewDelegate {

    @IBOutlet var loginView: LoginView!

    var currentEmail: String! = nil
    var fingerPrintDataFromDevice: AnyObject! = nil
    var currentUserData: AnyObject! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        unconfigureView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeBluetooth()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    /**
    * Configure the UIViewController
    *
    * @see loginView.login The callback when the signInButton is tapped
    */
    func configureView() {
        loginView.delegate = self
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(LoginViewController.LoginWithID(_:)), name: kDidDecodeIDNotification, object: nil)
        nc.addObserver(self, selector: #selector(LoginViewController.LoginWithFingerPrint(_:)), name: kDidDecodeFingerPrintNotification, object: nil)
        nc.addObserver(self, selector: #selector(LoginViewController.ReceiveFingerPrint(_:)), name: kDidReceiveFingerPrintNotification, object: nil)
    }

    /**
     * Unconfigure the UIViewController
     */
    func unconfigureView() {
        loginView.delegate = nil
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
    }
    
    /**
     * Initialize Bluetooth Connection
     */
    var initialized = false
    func initializeBluetooth() {
        if !initialized {
            initialized = true
            
            BluetoothDeviceInterface.sharedInstance.initialize()
            
            linkIDScanner()
            
//            linkThermometer()
        }
    }

    /**
    * Login View Delegate
    * Implement the followign functions:
    *   func Login(email: String, password: String);
    *   func ScanFingerPrintTask();
    *   func ScanIDCardTask();
    *
    * @see LoginView
    */
    
    func LinkScannerTask() {
        linkIDScanner()
    }
    
    func Login(email: String, password: String) {
        loginWithEmail(email, password: password)
    }
    
    func ScanFingerPrintTask(email: String) {
        if email.characters.count == 0 {
            showAlertView("Enter Email Address", message: "Please enter email address before scanning fingerprint.")
            return
        }
        scanFingerPrint(email)
    }
    
    func ScanIDCardTask() {
        scanID()
    }
    
    func ForgetPassword(email: String?) {
         forgetPassword(email)
    }
    
    /**
    * Login function
    *
    * Flow
    * 1. Display an activity indicator that blocks UI
    * 2. Call WebService Login
    *   3. Hide activity indicator
    *   4. If successful
    *       > Switch Tabbar Controller index
    *   5. If not successful
    *       > Show error
    *
    * @param email      The email string
    * @param password   The password string
    *
    * @see LoginView
    * @see LoginViewDelegate
    */
    func loginWithEmail(email: String, password: String) {
        SendLoginWithEmail(email, password: password)
    }

    /**
    * Scan Finger Print function
    *
    * Flow
    * 1. Display an activity indicator that blocks UI
    * 2. Connect to Finger Print Scanner
    *
    * @see LoginView
    * @see LoginViewDelegate
    */
    func scanFingerPrint(email: String) {
        currentEmail = email
        FingerPrintScannerDataDecoder.sharedInstance.scanFingerPrint()
    }
    
    func scanID() {
        FingerPrintScannerDataDecoder.sharedInstance.scanID()
    }

    func linkIDScanner() {
        FingerPrintScannerDataDecoder.sharedInstance.linkDevice ({ progress, remainingTime in
            
            },
            completion: { error in
                
        })
    }
    
    /**
     * Link with Bluetooth Device
     */
    func linkThermometer() {
        weak var weakSelf = self
        BluetoothDeviceInterface.sharedInstance.linkDevice ({ progress, remainingTime in
            
            weakSelf?.showProgressViewWithTime(progress, title: "Connecting to ID Scanner...")
            
            },
            completion: { error in
                weakSelf?.hideProgressView()
        })
    }
    
    /**
     * BluetoothInterfaceDelegate
     * Delegate callback for receiving data from Scanners
     *
     * @see ThermometerDataDecoderDelegate
     */
    func LoginWithID(data: AnyObject?) {
        if let notification = data as? NSNotification {
            if let string = notification.object as? String {
                SendLoginWithID(string)
            }
        }
    }
    
    func ReceiveFingerPrint(data: AnyObject?) {
        if let notification = data as? NSNotification {
            if let fingerprint = notification.object as? NSData {
                fingerPrintDataFromDevice = fingerprint
                SendLoginWithFingerprint(currentEmail)
            }
            else {
                showAlertView("Sign In Failed", message: "")
            }
        }
        else {
            showAlertView("Sign In Failed", message: "")
        }
    }

    func LoginWithFingerPrint(data: AnyObject?) {
        NSLog("[LoginViewController] Received Fingerprint Match Results")

        if let notification = data as? NSNotification {
            if let value = notification.object as? Bool {
                NSLog("[LoginViewController] Result: \(value)")
                
                if value {
                    let dictionary = currentUserData as! Dictionary<String, AnyObject>
                    CoreDataManager.sharedInstance.LoginUser(dictionary)
                    loginUser()
                }
                else {
                    showAlertView("Sign In Failed", message: "")
                }
            }
            else {
                showAlertView("Sign In Failed", message: "")
            }
        }
        else {
            showAlertView("Sign In Failed", message: "")
        }
    }

    
    /**
     * Login function
     *
     * Flow
     * 1. Display an activity indicator that blocks UI
     * 2. Call WebService Login
     *   3. Hide activity indicator
     *   4. If successful
     *       > Switch Tabbar Controller index
     *   5. If not successful
     *       > Show error
     *
     * @param email      The email string
     * @param password   The password string
     *
     * @see LoginView
     * @see LoginViewDelegate
     */
    func SendLoginWithEmail(email: String, password: String, completion:((result: Bool)->())? = nil) {
        weak var weakSelf = self
        
        weakSelf?.showProgressView("Signing In...")
        
        WebService.sharedInstance.LoginWithEmail(email, password: password, completion: { error, result in
            
            weakSelf?.hideProgressView()

            weakSelf?.LoginCompletion(error, result: result)
        })
    }

    func SendLoginWithFingerprint(email: String) {
        weak var weakSelf = self
        
        weakSelf?.showProgressView("Signing In...")
        
        WebService.sharedInstance.LoginWithFingerPrint(email, completion: { error, result in
            
            weakSelf?.hideProgressView()
            
            weakSelf?.LoginCompletionWithFingerprint(error, result: result)
        })
    }

    func SendLoginWithID(cardId: String) {
        weak var weakSelf = self
        
        weakSelf?.showProgressView("Signing In...")

        WebService.sharedInstance.LoginWithID(cardId, completion: { error, result in
            
            weakSelf?.hideProgressView()
            
            weakSelf?.LoginCompletionWithCardID(error, result: result)
        })
    }
    
    
    /**
     * WebService Calls Successful
     * Login with email/password
     */
    func LoginCompletion (error: String?, result: AnyObject?) {
        if let errorMessage = error {
            showAlertView("Sign In Failed", message: errorMessage)
        }
        else {
            if let data = result as? NSDictionary {
                let dictionary = data as! Dictionary<String, AnyObject>
                CoreDataManager.sharedInstance.LoginUser(dictionary)
                loginUser()
            }
            else {
                showAlertView("Sign In Failed", message: "")
            }
        }
    }

    /**
     * WebService Calls Successful
     * Login with Fingerprint
     */
    func LoginCompletionWithFingerprint (error: String?, result: AnyObject?) {
        if let errorMessage = error {
            showAlertView("Sign In Failed", message: errorMessage)
        }
        else {
            if let data = result as? NSDictionary {
                if let fingerprintData = data["fingerprintTemplate"] {
                    currentUserData = result
                    
                    // Data from Scanner
                    var data1: NSData!
                    if let data = fingerPrintDataFromDevice as? NSData {
                        data1 = data
                    }
                    
                    // Base 64 String Data from API -> convert to NSData
                    var data2: NSData!
                    if let data = fingerprintData as? NSData {
                        data2 = data
                    }
                    else
                        if let data = fingerprintData as? NSString {
                        data2 = NSData(base64EncodedString: data as String, options: .IgnoreUnknownCharacters)
                    }
                    
                    NSLog("[LoginViewController] LoginCompletionWithFingerprint Comparing Fingerprint Templates")
                    NSLog("Device: \(data1.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))")
                    NSLog("API: \(data2.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))")
                    
                    /* Use this to test the complete flow
                     * If the 2 fingerprints match,
                     * in this case identical templates are sent to the device
                     * Login will be successful
                     */
//                    data2 = data1
                    
                    if !FingerPrintScannerDataDecoder.sharedInstance.matchFingerPrint(data1, mfpData2: data2) {
                        showAlertView("Sign In Failed", message: "")
                    }
                }
            }
            else {
                showAlertView("Sign In Failed", message: "")
            }
        }
    }

    /**
     * WebService Calls Successful
     * Login with Card ID
     */
    func LoginCompletionWithCardID (error: String?, result: AnyObject?) {
        if let errorMessage = error {
            showAlertView("Sign In Failed", message: errorMessage)
        }
        else {
            if let data = result as? NSDictionary {
                let dictionary = data as! Dictionary<String, AnyObject>
                CoreDataManager.sharedInstance.LoginUser(dictionary)
                loginUser()
            }
            else {
                showAlertView("Sign In Failed", message: "")
            }
        }
    }

    
    /**
     * Switch from Login Tab
     */
    func loginUser () {
        tabBarController?.selectedIndex = 1
        
        if let nc = tabBarController?.viewControllers![1] as? UINavigationController {
            if let dvc = nc.viewControllers[0] as? DetailViewController {
                if let user = CoreDataManager.sharedInstance.LoggedInUser {
                    user.timeStamp = NSDate()
                    CoreDataManager.sharedInstance.saveContext(user.managedObjectContext)
                    dvc.detailItem = user
                }
                
            }
        }
    }
    
    /**
     * Forget Password function
     */
    func forgetPassword(email: String? = nil) {
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("ForgetPasswordViewController") as? ForgetPasswordViewController {
            presentViewController(vc, animated: true, completion: nil)
            
            providesPresentationContextTransitionStyle = true
            definesPresentationContext = true
            vc.modalPresentationStyle = .OverCurrentContext
            vc.modalTransitionStyle = .CrossDissolve
        }
        
    }
}
