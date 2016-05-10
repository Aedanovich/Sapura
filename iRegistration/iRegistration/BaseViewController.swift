//
//  BaseViewController.swift
//  iReception
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
    func showAlertView (title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            
        }
        ac.addAction(cancelAction)
        showViewController(ac, sender: nil)
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
    }
    
    /**
     * Show Login
     */
    func showLogin() {
        if let svc = self.splitViewController {
            // Hide Master
            UIView.animateWithDuration(0.3,
                                       delay: 0.0,
                                       options: UIViewAnimationOptions.AllowUserInteraction,
                                       animations: {
                                        svc.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
                }, completion: { finished in
                    svc.preferredDisplayMode = UISplitViewControllerDisplayMode.Automatic
            })
            
            // Switch to Login View
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
