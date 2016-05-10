//
//  LoginViewController.swift
//  iReception
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
class LoginViewController: BaseViewController {

    @IBOutlet var loginView: LoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loginView.refresh()
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
        weak var weakSelf = self
        
        loginView.loginTask = { email, password in
            weakSelf?.login(email, password: password)
        }
        loginView.forgetPasswordTask = { email in
            weakSelf?.forgetPassword(email)
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
    * @param email
    * @param password
    *
    * @see loginView.login The callback when the signInButton is tapped
    */
    func login(email: String, password: String) {
        weak var weakSelf = self

        weakSelf?.showProgressView("Signing In...")
        
        WebService.sharedInstance.Login(email, password: password, completion: { error, result in

            weakSelf?.hideProgressView()
            
            if let errorMessage = error {
                weakSelf!.showAlertView("Sign In Failed", message: errorMessage)
            }
            else {
                weakSelf!.tabBarController?.selectedIndex = 1
                
                if let tbc = weakSelf!.tabBarController as? MainTabBarController {
                    tbc.syncData()
                }
            }
        })
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
