//
//  DetailViewController.swift
//  iReception
//
//  Created by Alex on 18/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController, DetailViewDelegate, DetailViewDataSource {
    
    @IBOutlet weak var detailView: DetailView!
    
    var detailItem: Guest? {
        didSet {
            self.configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDetailView()
        
        self.configureView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.UpdateData(_:)), name: kDidScanTemperatureNotification, object: nil)
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
        detailView.detailItem = detailItem
        
        //        PrinterInterface.sharedInstance.delegate = self
    }
    
    /**
     * Setup the Detail View
     */
    func setupDetailView() {
        detailView.delegate = self
        detailView.dataSource = self
    }
    
    /**
     * Detail View Delegate Methods
     */
    func AddGuest() {
        addGuest()
    }
    
    func SaveGuest(guestInfo: Dictionary <String, AnyObject>) {
        
    }
    
    func PrintLabel(guestInfo: Dictionary <String, AnyObject>) {
        printLabel(guestInfo)
    }
    
    func PickImage() {
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("ImageDetailViewController") as? ImageDetailViewController {
            vc.image = detailView.imageView.image

            splitViewController!.presentViewController(vc, animated: true, completion: nil)
            
            splitViewController!.providesPresentationContextTransitionStyle = true
            splitViewController!.definesPresentationContext = true
            vc.modalPresentationStyle = .OverCurrentContext
            vc.modalTransitionStyle = .CrossDissolve
        }
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
        let hosts = CoreDataManager.sharedInstance.Hosts()
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
                
                var text: Array<String> = Array<String>()
                text.append((detailItem?.name)!)
                text.append("Org: \((detailItem?.organization)!)")
                text.append("Host: \((detailItem?.host?.name)!) - \((detailItem?.purpose)!)")
                
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
     * BluetoothInterfaceDelegate
     * Delegate callback for receiving temperature
     *
     * @see ThermometerInterfaceDelegate
     */
    func UpdateData(data: AnyObject?) {
        if let notification = data as? NSNotification {
            if let temperature = notification.object as? Double {
                if let addGuestViewController = splitViewController?.presentedViewController as? AddGuestViewController {
                    addGuestViewController.detailView.setTemperature(temperature)
                }
                else {
                    detailView.setTemperature(temperature)
                }
            }
        }
    }
    
    /**
     * Show the Add Guest View
     *
     * @param sender UIButton in the Navigation Bar right side
     *
     * @see AddGuestViewController Storyboard view controller
     */
    @IBAction func addGuest(sender: AnyObject? = nil) {
        let vc : AddGuestViewController = storyboard?.instantiateViewControllerWithIdentifier("AddGuestViewController") as! AddGuestViewController
        
        splitViewController!.presentViewController(vc, animated: true, completion: nil)
        
        splitViewController!.providesPresentationContextTransitionStyle = true
        splitViewController!.definesPresentationContext = true
        vc.modalPresentationStyle = .OverCurrentContext
        vc.modalTransitionStyle = .CrossDissolve
    }
}

