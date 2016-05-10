//
//  AddGuestViewController.swift
//  iReception
//
//  Created by Alex on 23/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

class AddGuestViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DetailViewDataSource, DetailViewDelegate, FSMediaPickerDelegate {
    @IBOutlet weak var detailView: DetailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    * Configure the view
    *
    * Assign the delegate and datasource to detailview
    *
    * @see DetailViewDelegate
    * @see DetailViewDataSource
    */
    func configureView() {
        detailView.delegate = self
        detailView.dataSource = self
    }

    /**
    * Detail View Delegate Methods
    */
    func AddGuest() {
        
    }
    
    func SaveGuest(guestInfo: Dictionary <String, AnyObject>) {
        saveGuestCheck(guestInfo)
    }

    func PrintLabel(guestInfo: Dictionary <String, AnyObject>) {
        printLabel(guestInfo)
    }

    func PickImage() {
        pickImage()
    }
    
    func GetTemperature() {
        linkThermometer()
    }

    /**
    * Detail View Datasource Methods
    */
    func NumberOfHosts() -> Int? {
        let cdm = CoreDataManager.sharedInstance
        if let hosts = cdm.Hosts() {
            return hosts.count
        }
        return 0
    }
    func HostForIndex(index: Int) -> Host! {
        let cdm = CoreDataManager.sharedInstance
        let hosts = cdm.Hosts()
        return hosts[index]
    }
    func NumberOfPurpose() -> Int {
        let cdm = CoreDataManager.sharedInstance
        if let purposes = cdm.Purposes() {
            return purposes.count
        }
        return 0
    }
    func PurposeForIndex(index: Int) -> String! {
        let cdm = CoreDataManager.sharedInstance
        let purposes = cdm.Purposes()
        return purposes[index]
    }


    
    /**
    * Close the view
    */
    @IBAction func cancelTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /**
    * Save the guest info
    *
    * @see saveGuest
    */
    @IBAction func saveTapped(sender: AnyObject) {
        let dictionary = detailView?.getInfoDictionary ()
        saveGuestCheck(dictionary!)
    }

    
    /**
    * Save the guest info
    *
    * @see CoreDataManager
    */
    func saveGuestCheck(dictionary: Dictionary<String, AnyObject>) -> Guest! {
        detailView.highlightRequiredInputs ()
        
        var guest: Guest? = nil
        
        if detailView.canSaveGuest() {
            if let _ = dictionary["temperature"] {
                guest = saveGuest(dictionary)
            }
            else {
                let cdmanager = CoreDataManager.sharedInstance
                if !cdmanager.showTemperature {
                    guest = saveGuest(dictionary)
                }
                else {
                    showAlertView("No Temperature",
                        message: "Temperature has not been captured yet. Proceed?",
                        okAction: {
                            guest = self.saveGuest(dictionary)
                        },
                        cancelAction: {
                            
                    })
                }
            }
        }
        else {
            showAlertView("Incomplete Details", message: "Please fill-up all the required details and try again.")
        }
        
        return guest
    }

    func saveGuest(dictionary: Dictionary<String, AnyObject>) -> Guest! {
        var guest: Guest? = nil
        
        if let g = CoreDataManager.sharedInstance.AddGuest(dictionary) {
            g.shouldUpload = NSNumber(bool: true)
            CoreDataManager.sharedInstance.saveContext()
            
            guest = g
            
            showProgressView("Uploading...")
            
            WebService.sharedInstance.UploadGuests{ error, result in
                self.hideProgressView()
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        return guest
    }


    /**
     * Print the label
     * Block the UI with a progress view
     *
     * @see PrinterInterface
     */
    func printLabel(guestInfo: Dictionary <String, AnyObject>) {
        detailView.highlightRequiredInputs ()
        
        if detailView.canSaveGuest() {
            
            let printerInterface = PrinterInterface.sharedInstance
            
            if !printerInterface.isConnectedToNetwork() {
                showAlertView("Network Error", message: "Please make sure you are connected to a network and try again.")
            }
            else {
                weak var weakSelf = self
                
                let details = detailView.getInfoDictionary ()
                var text: Array<String> = Array<String>()
                text.append((details["name"] as? String)!)
                text.append("Org: \((details["organization"] as? String)!)")
                text.append("Host: \((details["host"] as? Host)!.name!) - \((details["purpose"] as? String)!)")

                if printerInterface.isPrinterReady() {
                    
                    weakSelf?.showProgressView("Printing...")
                    
                    printerInterface.print(text, completion: { error in
                        
                        weakSelf?.hideProgressView()
                        
                        }
                    )
                }
                else {
                    weakSelf?.showProgressView("Searching for Printers...")
                    
                    printerInterface.startSearch()
                    
                    printerInterface.didFindPrinters = { printers in
                        
                        weakSelf?.hideProgressView()
                        
                        weakSelf?.showProgressView("Printing...")
                        
                        printerInterface.print(text, completion: { error in
                            
                            weakSelf?.hideProgressView()
                            
                            }
                        )
                    }
                }
            }
        }
    }
    
    func showPrinterList(list: Array<AnyObject>? = nil) {
        let pv = storyboard?.instantiateViewControllerWithIdentifier("PrinterView") as? PrinterView
        pv?.aryListData = list
        pv?.modalPresentationStyle = .Popover
        pv?.preferredContentSize = CGSizeMake(320, 320)
        
        let popoverMenuViewController = pv!.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .Right;
        
        popoverMenuViewController?.sourceView = detailView
        popoverMenuViewController?.sourceRect = detailView.convertRect(detailView.printGroupView.frame, fromView: detailView.printGroupView.superview)
        presentViewController(
            pv!,
            animated: true,
            completion: nil)

    }
    
    /**
     * Link the Thermometer
     * Block the UI with a progress view
     *
     * @see ThermometerDataDecoder
     */
    func linkThermometer() {
        weak var weakSelf = self
        
        BluetoothDeviceInterface.sharedInstance.linkDevice ({ progress, remainingTime in
            
            weakSelf?.showProgressViewWithTime(progress, title: "Connecting to Thermometer...")
            
            },
            completion: { error in
                
                weakSelf?.hideProgressView()
        })
    }
    
    /**
    * Show a camera/image picker controller
    */
    func pickImage() {
        let picker = FSMediaPicker()
        picker.editMode = FSEditModeNone; // defualt is FSEditModeStandard
        picker.delegate = self
        picker.showFromView(detailView.imageView)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func mediaPicker(mediaPicker: FSMediaPicker!, didFinishWithMediaInfo mediaInfo: [NSObject : AnyObject]!) {
        let userImage = mediaInfo[UIImagePickerControllerOriginalImage] as? UIImage
        detailView.setImage(userImage)
    }
}
