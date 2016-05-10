//
//  ImageDetailView.swift
//  iRegistration
//
//  Created by Alex on 1/2/16.
//  Copyright © 2016 A2. All rights reserved.
//

import UIKit

typealias CloseTask = ()->()

class ImageDetailView: UIView {

    var closeTask : CloseTask!
    var image: UIImage? {
        didSet {
            self.configureView()
        }
    }

    @IBOutlet weak var imageView: UIImageView!

    
    func configureView() {
        if let i = image {
            imageView.image = i
        }
        else {
            imageView.image = UIImage(named: "user-placeholder-large.png")
        }
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        if let _ = closeTask {
            closeTask()
        }
    }
}
