//
//  DetailViewController.swift
//  iRegistration
//
//  Created by Alex on 18/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController, FSMediaPickerDelegate, DetailViewDelegate, DetailViewDataSource {
    private var shouldConfigure: Bool = true
    var userImage: UIImage? = nil
    @IBOutlet weak var detailView: DetailView!

    var detailItem: User? {
        didSet {
            self.configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupDetailView()
        
        linkThermometer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !shouldConfigure {
            shouldConfigure = true
            configureView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unconfigureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /**
    * Configure the view
    *
    * Assign the delegate and datasource to detailview
    * Connect to the thermometer
    *
    * @see DetailViewDelegate
    * @see DetailViewDataSource
    */
    func configureView() {
        if let _ = detailView {
            detailView.detailItem = detailItem
        }
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(DetailViewController.ReceiveCardID(_:)), name: kDidDecodeIDNotification, object: nil)
        nc.addObserver(self, selector: #selector(DetailViewController.ReceiveFingerPrint(_:)), name: kDidReceiveFingerPrintNotification, object: nil)
        nc.addObserver(self, selector: #selector(DetailViewController.UpdateData(_:)), name: kDidScanTemperatureNotification, object: nil)
    }
    
    /**
     * Unconfigure the UIViewController
     */
    func unconfigureView() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
        
        detailView.reload()
    }
    
    /**
    * Setup the Detail View
    */
    func setupDetailView() {
        detailView.delegate = self
        detailView.dataSource = self
    }
    
    /**
     * BluetoothInterfaceDelegate
     * Delegate callback for receiving data from Scanners
     *
     * @see ThermometerDataDecoderDelegate
     */
    func ReceiveCardID(data: AnyObject?) {
        if let notification = data as? NSNotification {
            if let string = notification.object as? String {
                detailItem?.cardId = string
            }
        }
    }
    
    func ReceiveFingerPrint(data: AnyObject?) {
        if let notification = data as? NSNotification {
            if let fingerprintData = notification.object as? NSData {
                detailItem?.fingerprintTemplate = fingerprintData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            }
        }
    }
    
    /**
     * Delegate method - DetailViewDelegate
     *
     * @see DetailViewDelegate
     */

     /**
     * Show a camera/image picker controller
     */
    func DetailViewPickImage() {
        shouldConfigure = false
        
        let picker = FSMediaPicker()
        picker.editMode = FSEditModeNone
        picker.delegate = self
        picker.showFromView(detailView.getPictureButton)
    }
    
    /**
     * Get the temperature from Bluetooth device
     */
    func DetailViewGetTemperature() {
        linkThermometer()
    }
    
    /**
     * Save the current logged in user
     */
    func DetailViewSaveUser(guestInfo: Dictionary <String, AnyObject>?) {
        // Save the User
        // Upload the changes to the server
        saveUserCheck(guestInfo!)
    }
    
    /**
     * Save a new fingerprint template
     */
    func DetailViewAddFingerprint() {
        FingerPrintScannerDataDecoder.sharedInstance.scanFingerPrint()
    }

    /**
     * Add an ID Card
     */
    func DetailViewAddIDCard() {
        FingerPrintScannerDataDecoder.sharedInstance.scanID()
    }

    
    /**
     * Save the user info
     *
     * @see CoreDataManager
     */
    func saveUserCheck(dictionary: Dictionary<String, AnyObject>, ignoreTemperature: Bool? = false) -> User! {
        detailView.highlightRequiredInputs ()
        
        var user: User? = nil
        
        if detailView.canSaveUser() {
            if let temperature = dictionary["temperature"] {
                if temperature.floatValue > 0 || ignoreTemperature! {
                    if let _ = dictionary["image"] {
                        user = saveUser(dictionary)
                    }
                    else {
                        showAlertView("No Photo",
                            message: "Check-in photo has not been taken yet. Proceed?",
                            okAction: {
                                var newDictionary = dictionary
                                newDictionary["image"] = ""
                                user = self.saveUserCheck(newDictionary, ignoreTemperature: ignoreTemperature)
                            },
                            cancelAction: {
                                
                        })
                    }
                }
                else {
                    showAlertView("No Temperature",
                        message: "Temperature has not been captured yet. Proceed?",
                        okAction: {
                            var newDictionary = dictionary
                            newDictionary["temperature"] = "0"
                            user = self.saveUserCheck(newDictionary, ignoreTemperature: true)
                        },
                        cancelAction: {
                            
                    })
                }
            }
            else {
                showAlertView("No Temperature",
                    message: "Temperature has not been captured yet. Proceed?",
                    okAction: {
                        var newDictionary = dictionary
                        newDictionary["temperature"] = "0"
                        user = self.saveUserCheck(newDictionary, ignoreTemperature: ignoreTemperature)
                    },
                    cancelAction: {
                        
                })
            }
        }
        else {
            showAlertView("Incomplete Details", message: "Please fill-up all the required details and try again.")
        }
        
        return user
    }
    
    func saveUser(dictionary: Dictionary<String, AnyObject>) -> User! {
        var user: User? = nil

        if let u = CoreDataManager.sharedInstance.SaveUser(dictionary) {
            
            user = u
            
            showProgressView("Uploading Info...")
            
            WebService.sharedInstance.UploadUsers{ error, result in
                self.hideProgressView()
                
                self.tabBarController?.selectedIndex = 0
            }
        }
        
        return user
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func mediaPicker(mediaPicker: FSMediaPicker!, didFinishWithMediaInfo mediaInfo: [NSObject : AnyObject]!) {
        if let _ = detailItem {
            if let image = mediaInfo[UIImagePickerControllerOriginalImage] as? UIImage {
                let resizedImage = image.resizedImageWithMaximumSize(CGSize(width: 300, height: 300))
                userImage = resizedImage
                detailView.setImage(resizedImage)
                detailItem?.image = UIImagePNGRepresentation(resizedImage)
            }
        }
    }
    

    /**
    * Link the Thermometer
    * Block the UI with a progress view
    *
    * @see ThermometerDataDecoder
    */
    func linkThermometer() {
        BluetoothDeviceInterface.sharedInstance.linkDevice ({ [weak self] progress, remainingTime in
            
            self?.showProgressViewWithTime(progress, title: "Connecting to Thermometer...")
            
            },
            completion: { [weak self] error in
                self?.hideProgressView()
        })
    }

    /**
     * Link the Fingerprint Scanner
     */
    func linkFingerprint() {
        weak var weakSelf = self
        
        BluetoothDeviceInterface.sharedInstance.linkDevice ({ progress, remainingTime in
            
            weakSelf?.showProgressViewWithTime(progress, title: "Connecting to Thermometer...")
            
            },
            completion: { error in
                
                weakSelf?.hideProgressView()
        })
    }
    
    /**
     * BluetoothInterfaceDelegate
     * Delegate callback for receiving temperature
     *
     * @see ThermometerDataDecoderDelegate
     */
    func UpdateData(data: AnyObject?) {
        if let notification = data as? NSNotification {
            if let temperature = notification.object as? Double {
                detailView.setTemperature(temperature)
                detailItem?.temperature = temperature
            }
        }
    }

    /**
    * Handler for tapping the settings button at the left side of the navigation bar
    *
    * @param sender UIButton
    */
    func logout() {
        CoreDataManager.sharedInstance.LogoutUser()
        detailItem = nil
        
        if let tbc = tabBarController {
            tbc.selectedIndex = 0
        }
    }
}

