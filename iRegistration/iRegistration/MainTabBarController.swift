//
//  MainTabBarController.swift
//  iReception
//
//  Created by Alex on 18/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configureView() {
//        WebService.sharedInstance.addObserver(self,
//            forKeyPath: "IsGettingSettings",
//            options: .New,
//            context: nil)
        
        tabBar.hidden = true
    }
    
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        if keyPath == "IsGettingSettings" {
//            updateSettingsLoading()
//        }
//    }
//
//    func updateSettingsLoading() {
//        if WebService.sharedInstance.IsGettingSettings {
//            showProgressView("Downloading Settings")
//        }
//        else {
//            hideProgressView()
//        }
//    }
    
    /**
    * Override point for Status Bar Color
    * Use LightContent
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /**
     * Download Point
     *
     * Download all settings and previous guests
     */
    func syncData() {
        self.showProgressView("Downloading Settings...")
        
        WebService.sharedInstance.GetSettings({ error, result in
            
            self.showProgressView("Uploading Guests...")
            
            WebService.sharedInstance.UploadGuests{ error, result in

                self.showProgressView("Downloading Guests...")
                
                WebService.sharedInstance.GetGuests{ error, result in
                    self.hideProgressView()
                }

            }
        })
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
}
