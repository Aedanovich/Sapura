//
//  LoginView.swift
//  iReception
//
//  Created by Alex on 19/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

typealias LoginTask = (String, String)->()
typealias ForgetPasswordTask = (String)->()

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

    var loginTask : LoginTask!
    var forgetPasswordTask : ForgetPasswordTask!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let emailTextFieldPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha:0.5)])
        emailTextField.attributedPlaceholder = emailTextFieldPlaceholder

        let passwordTextFieldPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha:0.5)])
        passwordTextField.attributedPlaceholder = passwordTextFieldPlaceholder
        
        updateSignInButtonState()
    }
    
    /**
    * IBAction
    * Linked in storyboard file
    *
    * @param sender The UIButton
    * 
    * @see signIn
    */
    @IBAction func signInButtonTapped(sender: AnyObject) {
        signIn()
    }
    
    /**
     * IBAction
     * Linked in storyboard file
     *
     * @param sender The UIButton
     *
     * @see forgetPassword
     */
    @IBAction func forgetPasswordButtonTapped(sender: AnyObject) {
        forgetPassword()
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
        
        if let task = loginTask {
            task(emailTextField.text!, passwordTextField.text!);
        }
    }

    /**
     * Function for forgetPassword
     *
     * Calls the forgetPasswordTask block
     *
     * @see forgetPasswordTask
     */
    func forgetPassword() {
        dismissKeyboard()
        
        if let task = forgetPasswordTask {
            task(emailTextField.text!);
        }
    }

    
    /**
     * Function for refreshing the textfields
     *
     * Clears all the text fields (name, password)
     */
    func refresh() {
        if let tf = emailTextField {
            tf.text = ""
        }
        if let tf = passwordTextField {
            tf.text = ""
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
    * textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    *
    * @param textField The UITextField
    * @param range The range of the text to insert
    * @param string The string to replace the text in range
    *
    * @see updateSignInButtonState The method to update the signInButton state (enabled or disabled)
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = textField.text ?? ""
        let output = textFieldText.stringByReplacingCharactersInRange(range, withString: string)

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
