//
//  DetailView.swift
//  iRegistration
//
//  Created by Alex on 23/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

protocol DetailViewDelegate {
    func DetailViewSaveUser(guestInfo: Dictionary <String, AnyObject>?)
    func DetailViewPickImage()
    func DetailViewGetTemperature()
    func DetailViewAddFingerprint()
    func DetailViewAddIDCard()
}

protocol DetailViewDataSource {
}

class DetailView: BaseView {
    var fingerprintTemplate: String? = nil
    var cardId: String? = nil
    
    var detailItem: User? {
        didSet {
            self.configureView()
        }
    }
    
    var hasNewLoginInfo: Bool {
        return fingerprintTemplate != nil || cardId != nil
    }

    var delegate: DetailViewDelegate? = nil
    var dataSource: DetailViewDataSource? {
        didSet {
            self.reload()
        }
    }
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var timeStatusLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var getTemperatureButton: UIButton!
    @IBOutlet weak var getTemperatureLabel: UILabel!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var tempLevelImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempStatusLabel: UILabel!

    @IBOutlet weak var getPictureButton: UIButton!
    @IBOutlet weak var getPictureLabel: UILabel!
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.borderWidth = 5.0
        imageView.layer.borderColor = UIColor.whiteColor().CGColor

        reload()
        
        configureView()
    }
    
    /**
    * Configure the view
    *
    * @see detailItem
    * @see setImage()
    * @see setTemperature()
    */
    func configureView() {
        let now = NSDate()
        
        // User
        let user = CoreDataManager.sharedInstance.LoggedInUser
        
        // Greeting & Name
        let name = user?.name ?? ""
        let greeting = now.getTimeGreeting()
        greetingLabel.text = "\(greeting), \(name)"

        // Time
        let df = NSDateFormatter()
        df.dateFormat = "dd MMM\nHH:mma"
        if let item = detailItem {
            if let _ = item.timeStamp {
                dateTimeLabel.text = df.stringFromDate((item.timeStamp)!)
            }
        }
        else {
            dateTimeLabel.text = df.stringFromDate(now)
        }

        // Status
        var status = "ON TIME"
        if let item = detailItem {
            if item.isLate?.boolValue == true {
                status = "LATE"
            }
        }
        timeStatusLabel.text = status

        // Late Count
        var warning = ""
        if let item = detailItem {
            if let lateCount = item.lateCount?.intValue {
                if lateCount > 0 {
                    warning = "Number of times late this month: \(lateCount)"
                }
            }
        }
        warningLabel.text = warning
    }
    
    /**
    * Reload
    */
    func reload() {
        // Set Image
        setImage()
        // Set the Temperature
        setTemperature()
    }
    
    /**
    * Reload the dropdown views
    */
    func getInfoDictionary() -> Dictionary<String, AnyObject>? {
        var dictionary: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()

        if let item = detailItem {
            let keys = item.entity.attributesByName.keys
            for key in keys {
                dictionary[key] = item.valueForKey(key)
            }
        }
        
        if let value = imageView.image {
            dictionary["image"] = value
        }

        if let value = fingerprintTemplate {
            dictionary["fingerprintTemplate"] = value
        }

        if let value = cardId {
            dictionary["cardId"] = value
        }

        if let valueText = tempLabel.text {
            if let value = Float((valueText.stringByReplacingOccurrencesOfString("°", withString: ""))) {
                if value > 0 {
                    dictionary["temperature"] = "\(value)"//NSNumber(float: value)
                }
            }
        }
        return dictionary
    }
    
    /**
    * Button tap for Save User
    *
    * @see UIStoryboard Save button at right side of UINavigationBar
    */
    @IBAction func saveUser(sender: AnyObject) {
        let dictionary = getInfoDictionary ()
        delegate?.DetailViewSaveUser(dictionary)
    }

    /**
    * Button tap for Pick Image
    * 
    * @see UIStoryboard UIButton overlayed with the user UIImageView
    */
    @IBAction func pickImage(sender: AnyObject) {
        delegate?.DetailViewPickImage()
    }
    
    /**
    * Button tap for Pick Image
    *
    * @see UIStoryboard UIButton with thermometer image
    */
    @IBAction func takeTemp(sender: AnyObject) {
        delegate?.DetailViewGetTemperature()
    }

    /**
     * Button tap for Add Fingerprint
     *
     * @see UIStoryboard UIButton with Fingerprint Image
     */
    @IBAction func addFingerprintButtonTapped(sender: AnyObject) {
        delegate?.DetailViewAddFingerprint()
    }

     /**
     * Button tap for Add ID Card
     *
     * @see UIStoryboard UIButton with Barcode Image
     */
    @IBAction func addIDCardButtonTapped(sender: AnyObject) {
        delegate?.DetailViewAddIDCard()
    }

    
    /**
     * Set Image
     */
    func setImage(image: UIImage? = nil) {
        if let img = image {
            getPictureButton.setImage(nil, forState: .Normal)
            getPictureLabel.hidden = true
            pictureView.hidden = false
            imageView.image = img
            imageView.backgroundColor = UIColor.blackColor()
        }
        else {
            getPictureButton.setImage(UIImage(named: "button-photo.png"), forState: .Normal)
            getPictureLabel.hidden = false
            pictureView.hidden = true
            imageView.image = nil
            imageView.backgroundColor = UIColor.clearColor()
        }
    }
    
    
    /**
     * Sets the float value for the temperature label
     *
     * @see UIStoryboard
     * @see tempLabel
     * @see tempLevelImageView
     * @see tempStatusLabel
     */
    func setTemperature(temperature: Double? = 0.0) {
        if let view = temperatureView {
            let isVisible = temperature > 0
            if isVisible {
                if view.hidden {
                    view.hidden = !isVisible
                    view.alpha = 0
                    UIView.animateWithDuration(0.4, delay: 0.0, options: .AllowUserInteraction, animations: {
                        view.alpha = 1.0
                        }, completion: nil)
                }
            }
            else {
                view.hidden = true
            }
        }
        
        if temperature <= 0 {
            getTemperatureButton.setImage(UIImage(named: "button-thermometer.png"), forState: .Normal)
            getTemperatureLabel.hidden = false
        }
        else {
            getTemperatureButton.setImage(nil, forState: .Normal)
            getTemperatureLabel.hidden = true
        }
        
        tempLabel.text = String(format: "%.1f°", temperature!)
        
        let isHighTemp = temperature > 36.8
        tempStatusLabel.text = isHighTemp ? "High" : "Normal"
        tempLevelImageView.image = UIImage(named: isHighTemp ? "temp-high.png" : "temp-normal.png")
    }

    /**
     * Function to check if the current user data in the UI can be saved
     *
     * @return boolean TRUE if can save, otherwise return FALSE
     */
    func canSaveUser () -> Bool {
        return true
    }
    
    /**
     * Highlight required values
     */
    func highlightRequiredInputs () {
        let red = UIColor(red: 210.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        
        if imageView.image == nil {
            getPictureButton.setImage(UIImage(named: "button-photo-error.png"), forState: .Normal)
            getPictureLabel.textColor = red
        }
        else {
            getPictureButton.setImage(nil, forState: .Normal)
            getPictureLabel.textColor = UIColor.whiteColor()
        }
        
        let temp = tempLabel.text! as String
        if temp.characters.count > 0 && Float((temp.stringByReplacingOccurrencesOfString("°", withString: ""))) > 0.0 {
            getTemperatureButton.setImage(nil, forState: .Normal)
            getTemperatureLabel.textColor = UIColor.whiteColor()
        }
        else {
            getTemperatureButton.setImage(UIImage(named: "button-thermometer-error.png"), forState: .Normal)
            getTemperatureLabel.textColor = red
        }
    }

}
