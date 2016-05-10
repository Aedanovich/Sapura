//
//  GuestTableViewCell.swift
//  iReception
//
//  Created by Alex on 22/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

class GuestTableViewCell: UITableViewCell {

    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var guestImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        guestImageView.superview?.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor
        guestImageView.superview?.layer.borderWidth = 2.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if let bg = highlightView {
            bg.hidden = !selected
        }
    }
}
