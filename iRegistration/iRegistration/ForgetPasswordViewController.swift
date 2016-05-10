//
//  ForgetPasswordViewController.swift
//  iRegistration
//
//  Created by Alex on 1/2/16.
//  Copyright © 2016 A2. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: BaseViewController {

    @IBOutlet var forgetPasswordView: ForgetPasswordView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        forgetPasswordView.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /**
     * Configure the UIViewController
     */
    func configureView() {
        weak var weakSelf = self

        forgetPasswordView.forgetPasswordTask = { email in
            weakSelf?.forgetPassword(email)
        }
    }
    
    /**
     * Close the view
     */
    @IBAction func cancelTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /**
     * Send Forget Password function
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
     * @param email
     */
    func forgetPassword(email: String) {
        weak var weakSelf = self
        
        weakSelf?.showProgressView("Contacting Server...")
        
        WebService.sharedInstance.ForgetPassword(email, completion: { error, result in
            
            weakSelf?.hideProgressView()
            
            if let errorMessage = error {
                weakSelf!.showAlertView("Error", message: errorMessage)
            }
        })
    }
}
