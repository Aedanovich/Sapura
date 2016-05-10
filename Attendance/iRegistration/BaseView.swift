//
//  BaseView.swift
//  iRegistration
//
//  Created by Alex on 23/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

class BaseView: UIView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var activeTextField: UITextField? = nil
    var keyboardTap: UITapGestureRecognizer?
    @IBOutlet weak var avoidingView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        keyboardTap = UITapGestureRecognizer(target:self, action:#selector(BaseView.tap(_:)))
        keyboardTap!.delegate = self
        keyboardTap!.enabled = false
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
        keyboardTap!.enabled = true
        
        if let _ = avoidingView {
            IHKeyboardAvoiding.setAvoidingView(avoidingView)
        }
        else {
            IHKeyboardAvoiding.setAvoidingView(textField.superview?.superview)
        }
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
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = textField
        keyboardTap!.enabled = false
    }
}
