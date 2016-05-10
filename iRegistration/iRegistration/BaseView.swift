//
//  BaseView.swift
//  iReception
//
//  Created by Alex on 23/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

extension UITextField {

}

class BaseView: UIView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var containerView: UIView?
    var activeTextField: UITextField? = nil
    var keyboardTap: UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        keyboardTap = UITapGestureRecognizer(target:self, action:#selector(BaseView.tap(_:)))
        keyboardTap!.delegate = self
//        keyboardTap!.enabled = false
        self.addGestureRecognizer(keyboardTap!)
    }
    
    /**
    * UITapGestureRecognizer
    * Dismiss the keyboard if it's visible and the user taps outside the keyboard
    */
    @IBAction func tap(sender: AnyObject) {
        if let recognizer = sender as? UITapGestureRecognizer {
            if let _ = recognizer.view as? UITextField {
                
            }
            else if let _ = recognizer.view as? UIButton {
                
            }
            else {
                self.dismissKeyboard()
            }
        }
    }

    
    /**
    * Dismiss the currently visible keyboard with the active textfield
    */
    func dismissKeyboard() {
        if let textField = activeTextField {
            if textField.isFirstResponder() {
                textField.resignFirstResponder()
            }
        }
    }
    
    /**
     * Get the view for TextField
     */
    func avoidingViewForTextField(textField: UITextField) -> UIView {
        return (textField.superview?.superview)!
    }

    
    /**
    * The delegate callback for all UITextFields
    * Uses IHKeyboardAvoiding to make the UIView visible when UIKeyboard is shown
    *
    * @param textField The UITextField
    *
    * @see IHKeyboardAvoiding Update from Cocoapods
    * @see activeTextField Current active textfield
    */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        activeTextField = textField
        
        IHKeyboardAvoiding.setAvoidingView(avoidingViewForTextField(textField))
        return true
    }
    
    /**
    * The delegate callback for all UITextFields
    * Uses IHKeyboardAvoiding to make the UIView visible when UIKeyboard is shown
    *
    * @param textField The UITextField
    *
    * @see IHKeyboardAvoiding Update from Cocoapods
    */
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
//        activeTextField = textField
//        keyboardTap!.enabled = false
        
        return true
    }
}
