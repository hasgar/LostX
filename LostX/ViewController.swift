//
//  ViewController.swift
//  LostX
//
//  Created by Hasgar on 22/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {

    // MARK: Properties
    
    var counter = 0
    @IBOutlet weak var noInternetLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var logoHolderView: UIView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewDidAppear(animated: Bool) {
        
       checkInternetAndAuth()
        
    }
    
    
    // MARK: Actions
    
    @IBAction func connectAgain(sender: AnyObject) {
        loadingSpinner.hidden = false
        checkInternetAndAuth()
    }
    
    
    // MARK: Methods
    
    private func checkInternetAndAuth() {
        
        if(NetworkService.si.isConnected()) {
            
            hideNoInternetInfo()
            
            FIREBASE.auth?.addAuthStateDidChangeListener { auth, user in
                if self.counter == 0 {
                self.counter = 1
                if let user = user {
                    let changeRequest = user.profileChangeRequest()
                    changeRequest.displayName = user.displayName
                        changeRequest.commitChangesWithCompletion { error in
                        if error != nil {
                            self.performSegueWithIdentifier( SEGUE.auth, sender: nil)
                        } else {
                            
                            MainService.si.getCurrentUser() { () -> () in
                            MainService.si.getPosts() { () -> () in
                                
                            self.performSegueWithIdentifier( SEGUE.LoadFeed , sender: nil )
                                
                        }
                        }
                            
                        }
                }
                }
                else {
                   self.performSegueWithIdentifier(SEGUE.auth, sender: nil)
                }
            }
            }
            
        }
        else {
            loadingSpinner.hidden = true
            showNoInternetInfo()
            MainService.si.showAlert("No Internet Connection", message: "Make sure your device is connected to the internet.", Button: "OK")
            
        }
    }
    
    private func hideNoInternetInfo() {
        
        noInternetLabel.hidden = true
        tryAgainButton.hidden = true
        
    }
    
    private func showNoInternetInfo() {
        
        noInternetLabel.hidden = false
        tryAgainButton.hidden = false
        
    }
    
    
    
    
    


}

