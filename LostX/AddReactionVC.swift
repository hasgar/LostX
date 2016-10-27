//
//  AddReactionVC.swift
//  LostX
//
//  Created by Hasgar on 09/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class AddReactionVC: UIViewController,  UITextFieldDelegate {
    
    // MARK: Properties
    
    var postId: Int!

    @IBOutlet weak var message: TextField!
    @IBOutlet weak var date: TextField!
    @IBOutlet weak var city: AutoCompleteTextField!
    @IBOutlet weak var contactNumber: TextField!
    @IBOutlet weak var contactEmail: TextField!
    @IBOutlet weak var heading: UILabel!
    
    private var responseData:NSMutableData?
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        
        setupUI()
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let postDetail = segue.destinationViewController as? ShowDetailVC {
                if let post = sender as? Int {
                    postDetail.postId = post
                }
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func dateFieldTapped(sender: UITextField) {
        //Create the view
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        inputView.backgroundColor = MainService.si.hexStringToUIColor("8FCF8F")
        let datePickerView  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 40, 0, 0))
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.backgroundColor = UIColor.whiteColor()
        inputView.addSubview(datePickerView) // add date picker to UIView
        
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), -5 , 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(iLostVC.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        
        date.inputView = inputView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        handleDatePicker(datePickerView) // Set the date on start.
        
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        
        
        if date.text?.characters.count < 1 {
            MainService.si.showAlert("Date field is empty", message: "Please enter the date", Button: "OK")
        }
        else if city.text?.characters.count < 1 {
            MainService.si.showAlert("City field empty", message: "Please select the city", Button: "OK")
        }
        else if contactNumber.text?.characters.count < 1 {
            MainService.si.showAlert("Contact number empty", message: "Please enter your contact number", Button: "OK")
        }
        else if contactEmail.text?.characters.count < 1 {
            MainService.si.showAlert("Contact email empty", message: "Please enter your contact email", Button: "OK")
        }
        else if message.text?.characters.count < 1 {
            MainService.si.showAlert("Message field is empty", message: "Please enter the message", Button: "OK")
        }
        else if MainService.si.posts[postId].uid == MainService.si.currentUser.uid! {
            MainService.si.showAlert("You can't react", message: "You can't react to your own post", Button: "OK")
        }
        else {
            MainService.si.addLoaderView(self.view, message: "Please Wait..")
            let reaction = Reaction(message: message.text, type: MainService.si.posts[postId].type,  date:  date.text, contactNo: contactNumber.text, contactEmail: contactEmail.text, postKey: MainService.si.posts[postId].postKey!, city: city.text, uid: MainService.si.currentUser.uid)
            reaction.add({ (complete: Bool, already: Bool) -> () in
                if(complete) {
                    MainService.si.removeLoaderView(self.view)
                    if(already) {
                        
                        MainService.si.showAlert("Failed!!", message: "You already reacted to this post", Button: "OK")
                    }
                    else {
                        
                        self.showSuccessAndRedirect()
                        
                    }
                    
                }
                else {
                    
                    MainService.si.showAlert()
                }
            })
        }
        
        
    }
    
    // MARK: Methods
    
    func handleDatePicker(sender: UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        date.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    
    func doneButton(sender:UIButton)
    {
        
        date.resignFirstResponder() // To resign the inputView on clicking done.
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        date.resignFirstResponder()
        message.resignFirstResponder()
        city.resignFirstResponder()
        contactNumber.resignFirstResponder()
        contactEmail.resignFirstResponder()
        return true;
        
    }
    
    private func configureTextField(){
        
        city.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        city.autoCompleteTextFont = UIFont(name: "Raleway-Regular", size: 12.0)!
        city.autoCompleteCellHeight = 35.0
        city.maximumAutoCompleteCount = 20
        city.hidesWhenSelected = true
        city.hidesWhenEmpty = true
        city.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont(name: "Raleway-Medium", size: 12.0)
        city.autoCompleteAttributes = attributes
        
    }
    
    private func handleTextFieldInterfaces(){
        city.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = MainService.si.dataTask {
                    dataTask.cancel()
                }
                MainService.si.fetchAutocompletePlaces(text,city: self!.city)
            }
        }
        
        
    }
    
    private func showSuccessAndRedirect() {
        let alertController = UIAlertController(title: "Success!!", message: "Your reaction submitted successfully!", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.performSegueWithIdentifier("ShowDetail", sender: self.postId)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func setupDelegates() {
        
        message.delegate = self
        date.delegate = self
        city.delegate = self
        contactEmail.delegate = self
        contactNumber.delegate = self
        
        
    }
    
    private func setupUI() {
        
        if MainService.si.posts[postId].type == "lost" {
            
            date.placeholder = "When you got the item?"
            city.placeholder = "From which city you got the item?"
            heading.text = "Found Item Details"
            
        }
        else {
            
            date.placeholder = "When you lost the item?"
            city.placeholder = "From which city you lost the item?"
            heading.text = "Lost Item Details"
            
        }
        self.hideKeyboardWhenTappedAround()
        configureTextField()
        handleTextFieldInterfaces()

    }
    



    

}
