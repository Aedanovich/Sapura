//
//  ImageDetailViewController.swift
//  iRegistration
//
//  Created by Alex on 1/2/16.
//  Copyright © 2016 A2. All rights reserved.
//

import UIKit

class ImageDetailViewController: BaseViewController {

    @IBOutlet var imageDetailView: ImageDetailView!
    
    var image: UIImage? {
        didSet {
            if let view = imageDetailView {
                view.image = image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let weakSelf = self
        imageDetailView.closeTask = {
            weakSelf.dismissViewControllerAnimated(true, completion: nil)
        }
        
        imageDetailView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
