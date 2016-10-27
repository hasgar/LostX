//
//  User.swift
//  LostX
//
//  Created by Hasgar on 25/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import SwiftyJSON

class User {
    
    // MARK: Properties
    
    private var _name: String?
    private var _image: String?
    private var _uid: String?
    private var _email: String!
    private var _password: String!
    private var _provider: String!

    // MARK: Getters
    
    var name: String? {
        return _name
    }
    var uid: String? {
        return _uid
    }
    var email: String? {
        return _email
    }
    var password: String? {
        return _password
    }
    var image: String? {
        return _image
    }
    var provider: String? {
        return _provider
    }
    
    init(name: String?, email: String?, image: String?, uid: String?, provider: String?) {
        self._name = name
        self._email = email
        self._image = image
        self._uid  = uid
        self._provider  = provider
        
    }
    
    init(name: String?, email: String?, password: String?) {
        self._name = name
        self._email = email
        self._password = password
    }
    
    init(email: String?, password: String?) {
        self._email = email
        self._password = password
    }
    
    init() {
    }
    
    // MARK: Methods
    
    func signUpWithEmail(complete: completed) {
        if let uName = name where !uName.isEmpty , let uPass = password where !uPass.isEmpty , let uEmail = email where !uEmail.isEmpty {
            if !(MainService.si.isEmailValid(uEmail)) {
                MainService.si.showAlert(ALERT.invalidEmail, message: "Please enter a valid email address", Button: "OK")
                complete(false)
            } else {
                
            // Add new user in firebase
            FIREBASE.auth?.createUserWithEmail(uEmail, password: uPass, completion: { (user, error) in
                if( error == nil) {
                    if let userUpdate = user {
                        let changeRequest = userUpdate.profileChangeRequest()
                        
                        changeRequest.displayName = uName
                        changeRequest.commitChangesWithCompletion { error in
                            if error != nil {
                                MainService.si.showAlert()
                                complete(false)
                            }
                            else {
                                self.isUserAlreadyExist(uEmail, name: uName,image: nil, provider: "email"){ () -> () in
                                    complete(true)
                                    
                                }
                            }
                        }
                    }
                }
                else if(error?.code != nil) {
                    if error!.code == 17007 {
                        MainService.si.showAlert("User Already Exist", message: "User with this email id already exist.", Button: "OK")
                        complete(false)
                    }
                    else if error!.code == 17026 {
                        MainService.si.showAlert("Invalid Password", message: "The password must be 6 characters long or more.", Button: "OK")
                        complete(false)
                    }
                    else {
                        MainService.si.showAlert()
                        complete(false)
                    }
                }
            })
        }
    }
        else {
            MainService.si.showAlert("Fill the form", message: "Fill your Name, Email and Password", Button: "OK")
            complete(false)
        }

    }
    
    
    func signInWithEmail(complete: completed) {
        if let uPass = password where !uPass.isEmpty , let uEmail = email where !uEmail.isEmpty  {
            if !(MainService.si.isEmailValid(uEmail)) {
                MainService.si.showAlert(ALERT.invalidEmail, message: "Please enter a valid email address", Button: "OK")
            } else {
                FIREBASE.auth?.signInWithEmail(uEmail, password: uPass, completion: { (user, error) in
                    
                    if( error == nil) {
                        complete(true)
                        }
                    else {
                        if error!.code == 17011 {
                            MainService.si.showAlert(ALERT.invalidEmail, message: "This email is not registered in LostX", Button: "OK")
                            complete(false)
                        }
                        else if error!.code == 17009 {
                            MainService.si.showAlert("Incorrect Password", message: "You entered password is incorrect", Button: "OK")
                            complete(false)
                        }
                        else {
                            MainService.si.showAlert()
                            complete(false)
                        }
                        
                    }
                
                })
            }
        }
        else {
            MainService.si.showAlert("Fill the form", message: "Fill your Name, Email and Password", Button: "OK")
            complete(false)
        }
        
    }
    
    func signInWithFacebook(view: UIView, complete: completed) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager .logInWithReadPermissions(["email"] , fromViewController: nil , handler: { (result, error) -> Void in
            if (error == nil){
                
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if fbloginresult.isCancelled {
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    MainService.si.addLoaderView(view, message: "Please Wait..")
                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                    
                    FIREBASE.auth?.signInWithCredential(credential, completion: { (user, error) in
                        if( error == nil) {
                            if let userUpdate = user {
                                let changeRequest = userUpdate.profileChangeRequest()
                                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                                    if (error == nil) {
                                        let resultDec = JSON(result)
                                        if let displayName = resultDec["name"].string {
                                        changeRequest.displayName = displayName
                                        }
                                        
                                        changeRequest.commitChangesWithCompletion { error in
                                            if error != nil {
                                                MainService.si.showAlert()
                                                complete(false)
                                            }
                                            else {
                                                self.isUserAlreadyExist(resultDec["email"].string!, name: resultDec["name"].string!,image: resultDec["picture"]["data"]["url"].string!, provider: "facebook"){ () -> () in
                                                    complete(true)
                                                    
                                                }
                                                
                                            }
                                        }
                                    }
                                })
                            
                            }
                        }
                        else if(error?.code != nil) {
                            if error!.code == 17007 {
                                MainService.si.showAlert("User Already Exist", message: "User with this email id already exist.", Button: "OK")
                                complete(false)
                            }
                            else {
                                MainService.si.showAlert()
                                complete(false)
                            }
                        }

                    })
                    
                    
                }
                else {
                    MainService.si.showAlert("Facebook Login Failed", message: "Didn't get enough permission for login", Button: "OK")
                }
            }
        })

    }
    
    // Check user already added to firebase database or not
    func isUserAlreadyExist(email: String, name: String, image: String?, provider: String, completed: completionHandler) {
        FIREBASE.users.queryOrderedByChild("email").queryEqualToValue(email).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
            if snapshot.childrenCount < 1 {
                if let uid = FIREBASE.auth?.currentUser?.uid {
                    if let img = image {
                        FIREBASE.users.child("\(uid)").setValue([   "name": name as NSString ,
                            "email": email as NSString ,
                            "image": img as NSString ,
                            "provider": provider], withCompletionBlock: { (error, ref) in
                                completed()
                        })
                    } else {
                        FIREBASE.users.child("\(uid)").setValue([   "name": name as NSString ,
                            "email": email as NSString ,
                            "provider": provider], withCompletionBlock: { (error, ref) in
                                completed()
                        })
                    }
                }
                else {
                    MainService.si.showAlert()
                }
                
                    
            }
            else {
                completed()
            }
        })
    }
    
    func setEmail(newEmail: String) {
        _email = newEmail
    }
    
    func setName(newName: String) {
        _name = newName
    }
    
    func setImage(newImageUrl: String?) {
        if let image = newImageUrl {
            _image  = image
        }
        else {
            _image = nil
        }
    }
    
    
    
    
    
    
}