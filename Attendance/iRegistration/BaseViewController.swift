//
//  BaseViewController.swift
//  iRegistration
//
//  Created by Alex on 21/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    * Override point for Status Bar Color
    * Use LightContent
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /**
    * Show a MBProgressHUD view
    * 
    * @param title
    *
    * @see MBProgressHUD The class for showing a progress view
    */
    func showProgressView(title: String) {
        SVProgressHUD.showWithStatus(title, maskType: SVProgressHUDMaskType.Gradient)
    }

    func showProgressViewWithTime(progress: Float, title: String) {
        SVProgressHUD.showProgress(progress, status: title, maskType: SVProgressHUDMaskType.Black)
    }

    
    /**
    * Hide the MBProgressHUD view
    *
    * @see MBProgressHUD The class for progress view
    */
    func hideProgressView() {
        SVProgressHUD.dismiss()
    }


    /**
    * Show an Alert Message View
    *
    * @param title
    * @param message
    *
    */
    func showAlertView (title: String, message: String, okAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if let _ = cancelAction {
            let ca = UIAlertAction(title: "Cancel", style: .Cancel) { action in
                cancelAction!()
            }
            ac.addAction(ca)
        }
        else {
            let ca = UIAlertAction(title: "Cancel", style: .Cancel) { action in
                
            }
            ac.addAction(ca)
        }
        
        if let _ = okAction {
            let ok = UIAlertAction(title: "OK", style: .Default) { action in
                okAction!()
            }
            ac.addAction(ok)
        }
        else {
            let ok = UIAlertAction(title: "OK", style: .Default) { action in
                
            }
            ac.addAction(ok)
        }
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    /**
    * Hide the Alert view
    *
    * @see MBProgressHUD The class for progress view
    */
    func hideAlertView () {

    }
}

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    * Show a MBProgressHUD view
    *
    * @param title
    *
    * @see MBProgressHUD The class for showing a progress view
    */
    func showProgressView(title: String) {
        SVProgressHUD.showWithStatus(title, maskType: SVProgressHUDMaskType.Gradient)
    }
    
    
    /**
    * Hide the MBProgressHUD view
    *
    * @see MBProgressHUD The class for progress view
    */
    func hideProgressView() {
        SVProgressHUD.dismiss()
    }
    
    
    /**
    * Show an Alert Message View
    *
    * @param title
    * @param message
    *
    */
    func showAlertView (title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            
        }
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    /**
    * Hide the Alert view
    *
    * @see MBProgressHUD The class for progress view
    */
    func hideAlertView () {
        
    }
    
    
    /**
    * Handler for tapping the settings button at the left side of the navigation bar
    *
    * @param sender UIButton
    */
    func logout() {
        CoreDataManager.sharedInstance.LogoutUser()
        
        if let svc = self.splitViewController {
            if let tbc = svc.tabBarController {
                tbc.selectedIndex = 0
            }
        }
    }
}

extension UIImagePickerController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Landscape, .Portrait]
    }
}