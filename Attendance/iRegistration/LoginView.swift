//
//  LoginView.swift
//  iRegistration
//
//  Created by Alex on 19/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

/**
* Protocol for Login View
* Implement all the callbacks fot Storyboard actions
*
* func Login(email: String, password: String)
* func ScanFingerPrintTask();
* func ScanIDCardTask();
*/
protocol LoginViewDelegate {
    func Login(email: String, password: String)
    func ForgetPassword(email: String?)
    func ScanFingerPrintTask(email: String)
    func ScanIDCardTask()
    func LinkScannerTask()
}

/**
* UIView class for Login View.
*
* Members:
* signInButton: Button
*       > sign in button
*       > disabled if emailTextField and passwordTextField are empty
* emailTextField: Label The email textfield
* passwordTextField: Label The password textfield, secure entry
*/
class LoginView: BaseView {

    var delegate: LoginViewDelegate? = nil
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    /**
     * Self updating time label
     * @see RCRTimeLabel
     */
    @IBOutlet weak var dateLabel: RCRTimeLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
     
        // Setup Time Label Formal
        dateLabel.dateStyle = NSDateFormatterStyle.FullStyle
        dateLabel.timeStyle = NSDateFormatterStyle.MediumStyle
        
        // Set TextField Placeholders
        let emailTextFieldPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        emailTextField.attributedPlaceholder = emailTextFieldPlaceholder
        
        let passwordTextFieldPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = passwordTextFieldPlaceholder

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDate:", name: "", object: nil)
        
        updateSignInButtonState()
    }
    
    /**
     * IBAction Linked in storyboard file
     * Calls the delegate implementation of LinkScanner()
     *
     * @param sender The UIButton
     *
     * @see LoginViewDelegate LinkScannerTask()
     */
    @IBAction func linkScannerButtonTapped(sender: AnyObject) {
        linkScanner()
    }
    
    /**
    * IBAction Linked in storyboard file
    * Calls the delegate implementation of Login()
    *
    * @param sender The UIButton
    * 
    * @see LoginViewDelegate Login(email: String, password: String)
    */
    @IBAction func signInButtonTapped(sender: AnyObject) {
        signIn()
    }
    
    /**
     * IBAction Linked in storyboard file
     * Calls the delegate implementation of ForgotPassword()
     *
     * @param sender The UIButton
     *
     * @see LoginViewDelegate ForgetPassword(email: String)
     */
    @IBAction func forgotPasswordButtonTapped(sender: AnyObject) {
        dismissKeyboard()
        
        if let del = delegate {
            del.ForgetPassword(emailTextField.text!)
        }
    }
    
    /**
     * Function for LinkScannerTask
     *
     * Calls the LinkScannerTask block
     */
    func linkScanner() {
        if let del = delegate {
            del.LinkScannerTask()
        }
    }
    
    /**
    * Function for signin
    *
    * Calls the loginTask block
    *
    * @see loginTask
    */
    func signIn() {
        dismissKeyboard()
        
        if let del = delegate {
            del.Login(emailTextField.text!, password: passwordTextField.text!)
        }
    }
    
    /**
    * IBAction Linked in storyboard file
    * Calls the delegate implementation of ScanFingerPrintTask()
    *
    * @param sender The UIButton
    *
    * @see LoginViewDelegate ScanFingerPrintTask()
    */
    @IBAction func scanFingerPrintTapped(sender: AnyObject) {
        dismissKeyboard()
        
        if let del = delegate {
            del.ScanFingerPrintTask(emailTextField.text!)
        }
    }
    
    /**
    * IBAction Linked in storyboard file
    * Calls the delegate implementation of ScanIDCardTask()
    *
    * @param sender The UIButton
    *
    * @see LoginViewDelegate ScanIDCardTask()
    */
    @IBAction func scanIDCardTapped(sender: AnyObject) {
        dismissKeyboard()
        
        if let del = delegate {
            del.ScanIDCardTask()
        }
    }
    
    /**
    * Disables signInButton if emailTextField and passwordTextField are empty
    *
    * @param email The current text in emailTextField
    * @param password The current text in passwordTextField
    *
    * @see textField(textField:shouldChangeCharactersInRange:replacementString:)
    * @see signInButton The button linked in storyboard
    */
    func updateSignInButtonState(email: String = "", password: String = "") {
        let enable = email.characters.count > 0 && password.characters.count > 0
        signInButton.alpha = enable ? 1.0 : 0.5
        signInButton.userInteractionEnabled = enable
    }
    
    
    /**
    * The delegate callback for both emailTextField and passwordTextField
    *
    * @param textField The UITextField
    * @param range The range of the text to insert
    * @param string The string to replace the text in range
    *
    * @see updateSignInButtonState The method to update the signInButton state (enabled or disabled)
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        let range = range.stringRangeForText(textField.text!)
        let output = textField.text!.stringByReplacingCharactersInRange(range, withString: string)

        if textField == emailTextField {
            updateSignInButtonState(output, password: passwordTextField.text!)
        }
        else if textField == passwordTextField {
            updateSignInButtonState(emailTextField.text!, password: output)
        }
        
        return true
    }
    
    /**
    * The delegate callback for both emailTextField and passwordTextField
    * textFieldShouldReturn(textField: UITextField) -> Bool
    * Handle to automatically change focus to next field
    *
    * @param textField The UITextField
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            signIn()
        }
        return true
    }
}
