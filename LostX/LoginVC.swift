//
//  LoginVC.swift
//  LostX
//
//  Created by Hasgar on 23/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        
        setupUI()
        
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        let user = User(email: emailTxt.text , password: passwordTxt.text)
        
        MainService.si.addLoaderView(self.view, message: "Signing In..")
        
        
        user.signInWithEmail(){ (complete: Bool) in
            if(complete) {
                MainService.si.getCurrentUser() { () -> () in
                MainService.si.getPosts() { () -> () in
                    self.performSegueWithIdentifier( SEGUE.LoadFeedLogin , sender: nil )
                }
                }
            }
            else {
                self.view.userInteractionEnabled = true
                MainService.si.removeLoaderView(self.view)            }
           
        }

    }
    
    
    // MARK: Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        emailTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        return true;
        
    }
    
    private func setupDelegates() {
        emailTxt.delegate = self
        passwordTxt.delegate = self
    }
    
    private func setupUI() {
        self.hideKeyboardWhenTappedAround()
    }
    

    
    
    

}
