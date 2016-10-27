//
//  AuthVC.swift
//  LostX
//
//  Created by Hasgar on 26/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class AuthVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var nameTxt: UITextField!    
    @IBOutlet weak var facebookLoginButton: SocialButton!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        
        setupUI()
        
        
    }
    
    // MARK: Actions
    
    @IBAction func signUpPressed(sender: AnyObject) {
        
        let user = User(name: nameTxt.text, email: emailTxt.text , password: passwordTxt.text)
        
        MainService.si.addLoaderView(self.view, message: "Signing Up..")

        user.signUpWithEmail(){ (complete: Bool) -> () in
            if(complete) {
                MainService.si.getCurrentUser() { () -> () in
                MainService.si.getPosts() { () -> () in
                    self.performSegueWithIdentifier( SEGUE.LoadFeedAuth , sender: nil )
                    
                }
                }
            }
            else {
                
                MainService.si.removeLoaderView(self.view)

            }
        }
    }
    
    @IBAction func facebookLoginPressed(sender: AnyObject) {
        
        let user = User()
        
        user.signInWithFacebook(self.view){ (complete: Bool) -> () in
            if(complete) {
                MainService.si.getCurrentUser() { () -> () in
                MainService.si.getPosts() { () -> () in
                    self.performSegueWithIdentifier( SEGUE.LoadFeedAuth , sender: nil )
                    MainService.si.removeLoaderView(self.view)
                }
                }

            }
            else {
                
                MainService.si.removeLoaderView(self.view)

            }
        }
        
        
        
        
    }
    
    // MARK: Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        nameTxt.resignFirstResponder()
        return true;
    }
    
    private func setupDelegates() {
        emailTxt.delegate = self
        passwordTxt.delegate = self
        nameTxt.delegate = self
    }
    
    private func setupUI() {
        self.hideKeyboardWhenTappedAround()
    }
    

    
    
    
}

