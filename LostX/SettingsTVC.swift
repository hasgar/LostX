//
//  SettingsTVC.swift
//  LostX
//
//  Created by Hasgar on 25/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties

    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var email: TextField!
    @IBOutlet weak var changeEmail: UILabel!
    @IBOutlet weak var changeEmailArrow: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var changePassword: UILabel!
    @IBOutlet weak var passwordSpinner: UIActivityIndicatorView!
    @IBOutlet weak var emailSpinner: UIActivityIndicatorView!
    @IBOutlet weak var changePasswordArrow: UILabel!
    
    @IBOutlet weak var changePasswordCell: UITableViewCell!
    @IBOutlet weak var changeUserInfoCell: UITableViewCell!
    
    @IBOutlet weak var editImage: UIButton!
    
    @IBOutlet weak var editImageSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var userInfoArrow: UILabel!
    @IBOutlet weak var newName: UITextField!
    @IBOutlet weak var userInfoSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var changeEmailCell: UITableViewCell!
    
    let imagePicker = UIImagePickerController()
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        
        setupUI()
        
        disableOptionsIfFacebookUser()
        
        loadUserData()
        
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(tableView: UITableView,
                            didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            // Change Password
            
            editField("name")
            
            endEditing("email")
            endEditing("password")
            
            newName.becomeFirstResponder()
            
            
        }
        
        if indexPath.section == 1 {
            // Change Password
            
            editField("password")
            
            endEditing("email")
            endEditing("name")
            
            password.becomeFirstResponder()
            
            
        }
        if indexPath.section == 2 {
            // Change Email
            
            editField("email")
            
            endEditing("password")
            
            endEditing("name")
            
            email.becomeFirstResponder()
        }
        
        
        
        
    }
    
    
    // MARK: Actions
    
    @IBAction func changeImagePressed(sender: AnyObject) {
    
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let changeOrSet: String!
        if MainService.si.currentUser.image != nil {
            changeOrSet = "Change"
        }
        else {
            changeOrSet = "Set"
        }
        let changePicture = UIAlertAction(title: "\(changeOrSet) Profile Pictire", style: .Default) { (action) in
            
        
        let alertController = UIAlertController(title: nil, message: "Select new profile picture", preferredStyle: .ActionSheet)
        
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
        
        alertController.addAction(changePicture)
        
        if MainService.si.currentUser.image != nil {
        let deletePicture = UIAlertAction(title: "Delete this picture", style: .Destructive) { (action) in
            FIREBASE.users.child("\(MainService.si.currentUser.uid!)/image").removeValueWithCompletionBlock { (error, ref) in
                if error == nil {
                    self.updateImageOnPosts(nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadFeedData", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadYourXData", object: nil)
                    self.userImage.image = UIImage(named: "avatar")
                    self.editImageSpinner.hidden = true
                    self.editImage.hidden = false
                    MainService.si.showAlert("Success!", message: "Your profile picture has been deleted successfully!", Button: "OK")
                }
                else {
                    MainService.si.showAlert()
                }
            }
            
            
        }
        alertController.addAction(deletePicture)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }

        
    }
    
   
    @IBAction func userNamePressed(sender: AnyObject) {
        editField("name")
        
        endEditing("email")
        endEditing("password")
        
        newName.becomeFirstResponder()
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "Do you really want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            do {
                
                try FIREBASE.auth?.signOut()
                UIApplication.sharedApplication().setStatusBarStyle(.Default , animated: true)
                self.performSegueWithIdentifier("ShowAuth", sender: nil)
                
            }
            catch {
                MainService.si.showAlert()
            }
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        
        self.presentViewController(confirmAlert, animated: true, completion: nil)
        
        

    }
    
    
    // MARK: Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            if let password = password.text where password.characters.count > 6 {
                passwordSpinner.hidden = false
                FIREBASE.auth?.currentUser?.updatePassword(password) { error in
                    self.endEditing("password")
                    if let error = error {
                        
                        if error.code == 17026 {
                            MainService.si.showAlert("Invalid Password", message: "The password must be 6 characters long or more.", Button: "OK")
                        }
                        else {
                            MainService.si.showAlert()
                        }
                    } else {
                        MainService.si.showAlert("Success!!", message: "Your password has been changed successfully", Button: "OK")
                        self.endEditing("password")
                    }
                }
                
            }
            else {
                
                self.endEditing("password")
                
            }
            
            
        }
            
            
        if textField.tag == 2 {
            
            if let email = email.text where email.characters.count > 3  {
                if email != MainService.si.currentUser.email! {
                if MainService.si.isEmailValid(email) {
                    emailSpinner.hidden = false
                    FIREBASE.auth?.currentUser?.updateEmail(email) { error in
                        
                        self.endEditing("email")
                        
                        if let error = error {
                            
                            if error.code == 17007 {
                                MainService.si.showAlert("Already Exist", message: "This email already registered with LostX", Button: "OK")
                            }
                            else {
                                MainService.si.showAlert()
                            }
                        } else {
                            FIREBASE.users.child("\(MainService.si.currentUser.uid!)/email").setValue(email as NSString , withCompletionBlock: { (error, ref) in

                                if error != nil {
                                   
                                        MainService.si.showAlert()
                                    
                                } else {
                                    MainService.si.currentUser.setEmail(email)
                                    MainService.si.showAlert("Success!!", message: "Your email has been changed successfully", Button: "OK")
                                    self.endEditing("email")
                                    
                                    
                                }
                            })
                            
                        }
                    }
                }
                    
            }
                else {
                    self.endEditing("email")
                }
            }
            else {
                
                self.endEditing("email")
                
            }
            
        }
        
        if textField.tag == 3 {
            if let name = newName.text where name.characters.count > 0  {
                if name != MainService.si.currentUser.name! {
                    userInfoSpinner.hidden = false
            FIREBASE.users.child("\(MainService.si.currentUser.uid!)/name").setValue(name as NSString , withCompletionBlock: { (error, ref) in
                
                if error != nil {
                    
                    MainService.si.showAlert()
                    
                } else {
                    
                    self.updateNameOnPosts(name)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadFeedData", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadYourXData", object: nil)
                    self.userName.setTitle(name, forState: .Normal)
                    MainService.si.showAlert("Success!!", message: "Your name has been changed successfully", Button: "OK")
                    self.endEditing("name")                }
            })
                }
                else {
                    self.endEditing("name")
                }
            }
            else {
                
                self.endEditing("name")
                
            }
            
        }
        newName.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        return true;
    }
    
    func setupDelegates() {
        newName.delegate = self
        email.delegate = self
        password.delegate = self
        imagePicker.delegate = self
    }
    
    func setupUI(){
        
        addBorders(changePasswordCell,changeEmailCell,changeUserInfoCell)
        
    }
    
    func disableOptionsIfFacebookUser() {
        if MainService.si.currentUser.provider! == "facebook" {
            changePasswordCell.userInteractionEnabled = false
            changeEmailCell.userInteractionEnabled = false
            changeEmailCell.backgroundColor = MainService.si.hexStringToUIColor("E7E7E7")
            changePasswordCell.backgroundColor = MainService.si.hexStringToUIColor("E7E7E7")
        }
        else {
            changePasswordCell.userInteractionEnabled = true
            changeEmailCell.userInteractionEnabled = true
        }
    }
    
    func loadUserData() {
        if MainService.si.currentUser.image != nil {
            
            userImage.kf_setImageWithURL(NSURL(string: MainService.si.currentUser.image!)!, placeholderImage: nil)
            
        }
        
        newName.text = MainService.si.currentUser.name
        
        userName.setTitle(MainService.si.currentUser.name, forState: .Normal)
        changeEmail.text = "Change Email - \(MainService.si.currentUser.email!)"
        
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.bounds.height / 2
    }
    
    func addBorders(cells: UITableViewCell...) {
        for cell in cells {

        let topBorder = CALayer()
        topBorder.frame = CGRectMake(0, 0, cell.bounds.size.width, 1)
        topBorder.backgroundColor = MainService.si.hexStringToUIColor("DEDEDE").CGColor
        
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, cell.bounds.size.height-1, cell.bounds.size.width, 1)
        bottomBorder.backgroundColor = MainService.si.hexStringToUIColor("DEDEDE").CGColor
        
        
        cell.layer.addSublayer(topBorder)
        cell.layer.addSublayer(bottomBorder)
            
        }
        
    }
    
    
    func endEditing(item: String) {
        if item == "email" {
            self.emailSpinner.hidden = true
            self.email.hidden = true
            self.changeEmail.hidden = false
            self.changeEmailArrow.hidden = false
        }
        if  item == "password" {
            self.passwordSpinner.hidden = true
            self.password.hidden = true
            self.changePassword.hidden = false
            self.changePasswordArrow.hidden = false
        }
        if item == "name" {
            userInfoArrow.hidden = false
            userName.hidden = false
            newName.hidden = true
            self.userInfoSpinner.hidden = true
        }
    }
    
    func editField(field: String){
        if field == "email" {
        self.emailSpinner.hidden = true
        self.email.hidden = false
        self.changeEmail.hidden = true
        self.changeEmailArrow.hidden = true
        }
        
        if field == "password" {
            self.passwordSpinner.hidden = true
            self.password.hidden = false
            self.changePassword.hidden = true
            self.changePasswordArrow.hidden = true
        }
        
        if field == "name" {
            userInfoArrow.hidden = true
            userName.hidden = true
            
            newName.hidden = false
            newName.becomeFirstResponder()
        }
        
    }
    
    private func updateNameOnPosts(newName: String) {
        
        MainService.si.currentUser.setName(newName)
        
        updatePostsWithNewName(newName, postArray: MainService.si.posts)
        updatePostsWithNewName(newName, postArray: MainService.si.userPosts)
       
    }
    
    private func updatePostsWithNewName(newName: String, postArray: [Post]) {
        
        for i in 0..<postArray.count {
            if postArray[i].uid == MainService.si.currentUser.uid!  {
                postArray[i].setName(newName)
            }
        }
        
    }
    
    private func updateImageOnPosts(newImageUrl: String?) {
        
        MainService.si.currentUser.setImage(newImageUrl)
        
        updatePostsWithNewImage(newImageUrl, postArray: MainService.si.posts)
        updatePostsWithNewImage(newImageUrl, postArray: MainService.si.userPosts)
        
    }
    
    private func updatePostsWithNewImage(newImageUrl: String?, postArray: [Post]) {
        
        for i in 0..<postArray.count {
            if postArray[i].uid == MainService.si.currentUser.uid!  {
                postArray[i].setImage(newImageUrl)
            }
        }
        
    }
    
    private func fireImagePickerAndGesture(sourceType: UIImagePickerControllerSourceType) {
        
        self.imagePicker.sourceType = sourceType
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImage.contentMode = .ScaleAspectFill
            userImage.image = pickedImage
            editImage.hidden = true
            editImageSpinner.hidden = false
            
            MainService.si.uploadImage(pickedImage, resize: 50) { (completed, image) -> () in
                
                if(completed) {
                    FIREBASE.users.child("\(MainService.si.currentUser.uid!)/image").setValue(image! as NSString , withCompletionBlock: { (error, ref) in
                        
                        if error != nil {
                            
                            MainService.si.showAlert()
                            
                        } else {
                            self.updateImageOnPosts(image!)
                            NSNotificationCenter.defaultCenter().postNotificationName("reloadFeedData", object: nil)
                            NSNotificationCenter.defaultCenter().postNotificationName("reloadYourXData", object: nil)
                            self.editImageSpinner.hidden = true
                            self.editImage.hidden = false
                        }
                    })
                    
                }
                else {
                    self.editImageSpinner.hidden = true
                    self.editImage.hidden = false
                    if let image = MainService.si.currentUser.image {
                        self.userImage.kf_setImageWithURL(NSURL(string: image)!, placeholderImage: nil)
                    }
                    else {
                        self.userImage.image = UIImage(named: "avatar")
                    }
                    MainService.si.showAlert()
                }
            }
        }
        
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    
}

