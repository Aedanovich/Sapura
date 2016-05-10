//
//  SettingsOptionsViewController.swift
//  iRegistration
//
//  Created by Alex on 25/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

protocol SettingsOptionsViewControllerDelegate {
    func settingsOptionsLogout()
}

class SettingsOptionsViewController: UIViewController {
    var delegate: SettingsOptionsViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        delegate?.settingsOptionsLogout()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
