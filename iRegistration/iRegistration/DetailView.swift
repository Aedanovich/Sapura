//
//  DetailView.swift
//  iReception
//
//  Created by Alex on 23/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit

protocol DetailViewDelegate {
    func AddGuest()
    func SaveGuest(guestInfo: Dictionary <String, AnyObject>)
    func PrintLabel(guest: Dictionary<String, AnyObject>)
    func PickImage()
    func GetTemperature()
}

protocol DetailViewDataSource {
    func NumberOfHosts() -> Int?
    func HostForIndex(index: Int) -> Host!
    func NumberOfPurpose() -> Int
    func PurposeForIndex(index: Int) -> String!
}

class DetailView: BaseView, IQDropDownTextFieldDelegate {
    var detailItem: Guest? {
        didSet {
            self.configureView()
        }
    }

    var delegate: DetailViewDelegate? = nil
    var dataSource: DetailViewDataSource? {
        didSet {
            self.reload()
        }
    }
    
    @IBOutlet weak var detailInfoView: UIView!
    @IBOutlet weak var addGuestButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nricTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var organizationTextField: UITextField!
    @IBOutlet weak var hostTextField: IQDropDownTextField!
    @IBOutlet weak var purposeTextField: IQDropDownTextField!
    
    @IBOutlet weak var tempGroupView: UIView!
    @IBOutlet weak var tempLevelImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempStatusLabel: UILabel!
    
    @IBOutlet weak var printGroupView: UIView!
    
    @IBOutlet weak var takeTempGroupView: UIView!
    @IBOutlet weak var takeTempButton: UIButton!
    @IBOutlet weak var takeTempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }
    
    /**
    * Configure the view
    * Hides the add guest button and shows the info view if detailItem is not null and vice versa
    *
    * @see detailItem
    */
    func configureView() {
        reload()
        
        imageView.superview?.layer.borderWidth = 5.0
        imageView.superview?.layer.borderColor = UIColor(white: 1, alpha: 0.5).CGColor
        
        let cdmanager = CoreDataManager.sharedInstance
        if let _ = tempGroupView {
            tempGroupView.hidden = true
        }
        if let _ = takeTempGroupView {
            takeTempGroupView.hidden = !cdmanager.showTemperature
        }
        if let _ = printGroupView {
            printGroupView.hidden = !cdmanager.showPrint
        }
        
        let hasDetail = detailItem != nil
        if let b = addGuestButton {
            b.hidden = hasDetail
        }
        if let v = detailInfoView {
            v.hidden = !hasDetail
            
            // Set Guest Main Info
            if let label = nameLabel {
                label.text = detailItem?.name
            }
            if let label = companyLabel {
                label.text = detailItem?.organization
            }
            if let label = dateLabel {
                if let time = detailItem?.timeStamp {
                    label.text = time.getStringDateTime()
                }
            }
            
            // Set Guest Other Info
            if let label = nameTextField {
                label.text = detailItem?.name
            }
            if let label = organizationTextField {
                label.text = detailItem?.organization
            }
            if let label = nricTextField {
                label.text = detailItem?.nric
            }
            if let label = phoneNumberTextField {
                label.text = detailItem?.phone
            }
            if let label = hostTextField {
                label.selectedItem = detailItem?.host?.name
            }
            if let label = purposeTextField {
                label.selectedItem = detailItem?.purpose
            }
            
            // Set Guest Temperature
            if let temperature = detailItem?.temperature {
                setTemperature(temperature.doubleValue)
            }
            else {
                setTemperature()
            }
            
            // Set Image
            if let image = detailItem?.image {
                setImage(UIImage(data: image))
            }
            else if let imagePath = detailItem?.imagePath {
                setImage(imagePath: imagePath)
            }
            else {
                setImage()
            }
        }
    }
    
    /**
    * Reload the dropdown views
    */
    func reload() {
        hostTextField.isOptionalDropDown = false
        hostTextField.delegate = self
        var hostNames: Array<String>! = [""]
        if let hCount = dataSource?.NumberOfHosts() {
            for i in 0..<hCount {
                let host = dataSource?.HostForIndex(i)
                if let name = host?.name {
                    hostNames.append(name)
                }
            }
        }
        hostTextField.itemList = hostNames
        
        
        purposeTextField.isOptionalDropDown = false
        purposeTextField.delegate = self
        var purposes: Array<String>! = [""]
        if let pCount = dataSource?.NumberOfPurpose() {
            for i in 0..<pCount {
                let purpose = dataSource?.PurposeForIndex(i)
                purposes.append(purpose!)
            }
        }
        purposeTextField.itemList = purposes
    }
    
    /**
     * IQDropdown Delegate Methods
     * 
     * Handle selection of item. Auto-dismiss the picker when selecting
     */
    func textField(textField: IQDropDownTextField, didSelectItem item: String?) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
     
    /**
    * Get the info input from the view
    *
    * @return Dictionary<String, AnyObject>
    */
    func getInfoDictionary () -> Dictionary<String, AnyObject> {
        if let item = detailItem {
            let keys = item.entity.attributesByName.keys
            var dictionary: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            for key in keys {
                dictionary[key] = item.valueForKey(key)
            }
            return dictionary
        }
        else {
            var dictionary: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            if let value = nameTextField.text {
                dictionary["name"] = value
            }
            if let value = nricTextField.text {
                dictionary["nric"] = value
            }
            if let value = organizationTextField.text {
                dictionary["organization"] = value
            }
            if let value = phoneNumberTextField.text {
                dictionary["phone"] = value
            }
            if purposeTextField.selectedRow > 0 {
                if let value = dataSource?.PurposeForIndex(purposeTextField.selectedRow - 1) {
                    dictionary["purpose"] = value
                }
            }
            if hostTextField.selectedRow > 0 {
                if let value = dataSource?.HostForIndex(hostTextField.selectedRow - 1) {
                    dictionary["host"] = value
                }
            }
            if let value = imageView.image {
                dictionary["image"] = value
            }
            if let value = Float((tempLabel.text?.stringByReplacingOccurrencesOfString("°", withString: ""))!) {
                dictionary["temperature"] = "\(value)"//NSNumber(float: value)
            }
            return dictionary
        }
    }
    
    /**
    * Function to check if the current guest data in the UI can be saved
    *
    * @return boolean TRUE if can save, otherwise return FALSE
    */
    func canSaveGuest () -> Bool {
        let dictionary = getInfoDictionary ()
//        let propKeys = ["name", "nric", "organization", "phone", "purpose", "image", "temperature"]
        let propKeys = ["name", "nric", "organization", "phone", "purpose"]
        for key in propKeys {
            if let value = dictionary[key] {
                if let s = value as? String {
                    if s.characters.count == 0 {
                        return false
                    }
                }
            }
            else {
                return false
            }
        }
        return true
    }
    
    /**
    * Highlight required values
    */
    func highlightRequiredInputs () {
        let red = UIColor(red: 210.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        
        let textFields = [nameTextField, nricTextField, phoneNumberTextField, organizationTextField, hostTextField, purposeTextField]
        for tf in textFields {
            if let _ = tf {
                if tf.text?.characters.count == 0 {
                    tf.superview?.layer.borderColor = red.CGColor
                    tf.superview?.layer.borderWidth = 1.0
                }
                else {
                    tf.superview?.layer.borderColor = UIColor.clearColor().CGColor
                    tf.superview?.layer.borderWidth = 0.0
                }
            }
        }

//        if imageView.image == nil {
//            imageView.superview?.layer.borderColor = red.CGColor
//        }
//        else {
//            imageView.superview?.layer.borderColor = UIColor(white: 1, alpha: 0.5).CGColor
//        }
        
        if tempLabel.text?.characters.count == 0 {
            takeTempButton.setImage(UIImage(named: "icon-temp-error.png"), forState: .Normal)
            takeTempLabel.textColor = red
        }
        else {
            takeTempButton.setImage(UIImage(named: "icon-temp.png"), forState: .Normal)
            takeTempLabel.textColor = UIColor.whiteColor()
        }
    }

    /**
    * Button tap for Add Guest
    *
    * @see UIStoryboard Big UIButton at the center of the Detail View
    */
    @IBAction func addGuest(sender: AnyObject) {
        delegate?.AddGuest()
    }

    /**
    * Button tap for Save Guest
    *
    * @see UIStoryboard Save button at right side of UINavigationBar
    */
    @IBAction func saveGuest(sender: AnyObject) {
        let dictionary = getInfoDictionary ()
        delegate?.SaveGuest(dictionary)
    }

    /**
    * Button tap for Pick Image
    * 
    * @see UIStoryboard UIButton overlayed with the guest UIImageView
    */
    @IBAction func pickImage(sender: AnyObject) {
        delegate?.PickImage()
    }
    
    /**
    * Button tap for Pick Image
    *
    * @see UIStoryboard UIButton with print image
    */
    @IBAction func printLabel(sender: AnyObject) {
        highlightRequiredInputs()
        
        if canSaveGuest() {
            let dictionary = getInfoDictionary ()
            delegate?.PrintLabel(dictionary)
        }
    }
    
    /**
    * Button tap for Pick Image
    *
    * @see UIStoryboard UIButton with thermometer image
    */
    @IBAction func takeTemp(sender: AnyObject) {
        delegate?.GetTemperature()
    }
    
    /**
    * Sets the image value for the guest image view
    *
    * Background is changed to blackColor if image is not NIL
    * Otherwise, background is set to clearColor
    */
    func setImage(image: UIImage? = nil, imagePath: String? = nil) {
//        image = UIImage(named:"iReception-iPad-1a-add.jpg")
        
        imageView.image = nil

        if let img = image {
            imageView.image = img
            imageView.backgroundColor = UIColor.blackColor()
        }
        else if let imgPath = imagePath {
            imageView.setImageWithURL(NSURL(string: imgPath), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            imageView.backgroundColor = UIColor.blackColor()
        }
        else {
            imageView.image = nil
            imageView.backgroundColor = UIColor.clearColor()
        }
    }

    /**
    * Sets the float value for the temperature label
    *
    * @see UIStoryboard
    * @see takeTempGroupView
    * @see takeTempButton
    * @see takeTempLabel
    */
    func setTemperature(temperature: Double? = 0.0) {
        let cdmanager = CoreDataManager.sharedInstance
        if let _ = tempGroupView {
            tempGroupView.hidden = !cdmanager.showTemperature
        }

        if let view = tempGroupView {
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
        
        tempLabel.text = String(format: "%.1f°", temperature!)
        
        let isHighTemp = temperature > 36.8
        tempStatusLabel.text = isHighTemp ? "High" : "Normal"
        tempLevelImageView.image = UIImage(named: isHighTemp ? "temp-high.png" : "temp-normal.png")
    }
    
    /**
     * The delegate callback for  UITextFields
     * Manage the Next button behavior in Keyboard
     *
     * @param textField The UITextField
     *
     * @see IHKeyboardAvoiding Update from Cocoapods
     * @see activeTextField Current active textfield
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.Done {
            saveGuest(saveButton)
        }
        else {
            let nextTag: NSInteger = textField.tag + 1;
            
            if let nextResponder: UIResponder! = viewWithTag(nextTag){
                nextResponder.becomeFirstResponder()
            }
            else {
                textField.resignFirstResponder()
            }
        }
        
        return false // We do not want UITextField to insert line-breaks.
    }
}
