//
//  iLostVC.swift
//  LostX
//
//  Created by Hasgar on 04/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class iLostVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    // MARK: Properties
    
    @IBOutlet weak var postTitle: TextField!
    @IBOutlet weak var date: TextField!
    @IBOutlet weak var contactNumber: TextField!
    @IBOutlet weak var contactEmail: TextField!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var city: AutoCompleteTextField!
    @IBOutlet weak var selectImageButton: UIButton!
    
    
    let imagePicker = UIImagePickerController()
    
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
    
    
    
    
    @IBAction func submitPressed(sender: AnyObject) {
        
        if postTitle.text?.characters.count < 1 {
            MainService.si.showAlert("Title field is empty", message: "Please enter the title", Button: "OK")
        }
        else if date.text?.characters.count < 1 {
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
        else if itemImage.image == nil {
             MainService.si.showAlert("Post image not selected", message: "Please select an image", Button: "OK")
        }
        else {
            MainService.si.addLoaderView(self.tabBarController!.view, message: "Please Wait..")
            MainService.si.uploadImage(itemImage.image!, resize: 800) { (completed, image) -> () in
         
            }

        }
        
        
        MainService.si.uploadImage(itemImage.image!, resize: 800) { (completed, image) -> () in
            
            let post = Post(title: self.postTitle.text, type: "lost", image: image, date:  self.date.text, city: self.city.text, contactNo: self.contactNumber.text, contactEmail: self.contactEmail.text, uid: MainService.si.currentUser.uid)
            post.add({ (complete: Bool, postKey: String?) -> () in
                if(complete) {
                    post.addPostKey(postKey!)
                    MainService.si.removeLoaderView(self.tabBarController!.view)
                    self.clearFields()
                    self.selectImageButton.hidden = false
                    MainService.si.posts.insert(post, atIndex: 0)
                    MainService.si.userPosts.insert(post, atIndex: 0)
                    NSNotificationCenter.defaultCenter().postNotificationName("addPost", object: nil)
                    self.performSegueWithIdentifier("ShowDetail", sender: 0)

                }
                else {
                    MainService.si.removeLoaderView(self.view)
                    MainService.si.showAlert()
                }
            })

          

        }
        
        
        
    }
    
    @IBAction func selectImageTapped(sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        
        let alertController = UIAlertController(title: nil, message: "Select any photo related to this item", preferredStyle: .ActionSheet)
        
        let fromCamera = UIAlertAction(title: "Take from Camera", style: .Default) { (action) in
            self.fireImagePickerAndGesture(.Camera)
            
        }
        alertController.addAction(fromCamera)
        
        let fromGallery = UIAlertAction(title: "Choose from gallery", style: .Default) { (action) in
            self.fireImagePickerAndGesture(.PhotoLibrary)
        }
        alertController.addAction(fromGallery)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            itemImage.contentMode = .ScaleAspectFill
            itemImage.image = pickedImage
        }
        
        selectImageButton.hidden = true
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: Methods
    
    func peekImage(gestureRecognizer:UIGestureRecognizer) {
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Began)
        {
            let alertView = UIAlertView(title: nil, message: nil, delegate: nil, cancelButtonTitle: "OK")
            
            let imvImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            imvImage.contentMode = UIViewContentMode.ScaleAspectFit
            imvImage.image = itemImage.image
            alertView.setValue(imvImage, forKey: "accessoryView")
            alertView.show()
        }
        
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        date.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    
    func doneButton(sender:UIButton)
    {
        
        date.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        date.resignFirstResponder()
        postTitle.resignFirstResponder()
        city.resignFirstResponder()
        contactNumber.resignFirstResponder()
        contactEmail.resignFirstResponder()
        return true;
        
    }
    
    private func configureCity(){
        
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
    
    private func handleCityInterfaces(){
        city.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = MainService.si.dataTask {
                    dataTask.cancel()
                }
                MainService.si.fetchAutocompletePlaces(text,city: self!.city)
            }
        }
        
        
    }
    
    
    private func fireImagePickerAndGesture(sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.sourceType = sourceType
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(iLostVC.selectImageTapped(_:)))
        self.itemImage.userInteractionEnabled = true
        self.itemImage.addGestureRecognizer(tapGestureRecognizer)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target:self, action: #selector(iLostVC.peekImage(_:)))
        self.itemImage.addGestureRecognizer(longPressGestureRecognizer)

    }
    
    
    private func clearFields() {
        
        self.postTitle.text  = nil
        self.date.text = nil
        self.contactNumber.text = nil
        self.contactEmail.text = nil
        self.itemImage.image = nil
        self.city.text = nil
        self.city.textFieldDidChange()
        self.selectImageButton.hidden = false
        
    }
    
    private func setupDelegates() {
        postTitle.delegate = self
        date.delegate = self
        city.delegate = self
        contactEmail.delegate = self
        contactNumber.delegate = self
        imagePicker.delegate = self
    }
    
    private func setupUI(){
        self.hideKeyboardWhenTappedAround()
        configureCity()
        handleCityInterfaces()
    }
    
    
    
    

}
