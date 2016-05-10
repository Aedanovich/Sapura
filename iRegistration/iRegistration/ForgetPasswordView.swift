//
//  ForgetPasswordView.swift
//  iRegistration
//
//  Created by Alex on 1/2/16.
//  Copyright © 2016 A2. All rights reserved.
//

import UIKit

class ForgetPasswordView: BaseView {

    var forgetPasswordTask : ForgetPasswordTask!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let emailTextFieldPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha:0.5)])
        emailTextField.attributedPlaceholder = emailTextFieldPlaceholder
        
        updateSendButtonState()
    }

    /**
     * Configure the view
     *
     * Call on viewDidAppear of the View Controller
     *
     * Shows the Keyboard
     */
    func configureView() {
        if let _ = emailTextField {
            emailTextField.becomeFirstResponder()
        }
    }

    /**
     * IBAction
     * Linked in storyboard file
     *
     * @param sender The UIButton
     *
     * @see signIn
     */
    @IBAction func sendButtonTapped(sender: AnyObject) {
        send()
    }
    
    /**
     * Function for signin
     *
     * Calls the loginTask block
     *
     * @see loginTask
     */
    func send() {
        dismissKeyboard()
        
        if let task = forgetPasswordTask {
            task(emailTextField.text!)
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
    func updateSendButtonState(email: String = "") {
        let enable = email.characters.count > 0
        sendButton.alpha = enable ? 1.0 : 0.5
        sendButton.userInteractionEnabled = enable
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
            updateSendButtonState(output)
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
            send()
        }
        return true
    }
    
    /**
     * Get the view for TextField
     */
    override func avoidingViewForTextField(textField: UITextField) -> UIView {
        if let _ = containerView {
            return containerView!
        }
        return super.avoidingViewForTextField(textField)
    }
}
