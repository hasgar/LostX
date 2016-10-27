//
//  DataService.swift
//  LostX
//
//  Created by Hasgar on 25/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class MainService {
    
    static let si = MainService()
    
    var posts = [Post]()
    
    var userPosts = [Post]()
    
    var currentUser: User!
    
    let postPerPage: UInt = 5
    
    var totalPosts = 1000
    
    var isLoadingMore = false
    
    private init() {}
 
    
    // MARK: Properties
    
    // for google places api
    
    var dataTask:NSURLSessionDataTask?
    
    // MARK: Methods
    
    // Hex code to UIColor
    
    func hexStringToUIColor (hex:String) -> UIColor {
        
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Alert Box
    
    func showAlert(title: String = "Something Went Wrong", message: String = "Please try after sometime", Button: String = "OK") {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: Button)
        alert.show()
    }
    
    
    // Check the email is valid or not
    func isEmailValid(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailValidate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailValidate.evaluateWithObject(email)
    }
    
    // Progress Bar
    
    func progressBarDisplayer(msg:String, x: CGFloat, y: CGFloat) -> UIView {
        
        let strLabel = UILabel(frame: CGRect(x: 27, y: 20, width: 200, height: 50))
        strLabel.text = msg
        strLabel.font = UIFont(name: "Raleway-Bold", size: 16)
        strLabel.textColor = self.hexStringToUIColor("212121")
        
        let messageFrame = UIView(frame: CGRect(x: x - 73, y: y - 33, width: 146, height: 64))
        messageFrame.tag = 101
        messageFrame.layer.cornerRadius = 10
        messageFrame.backgroundColor = UIColor(white: 1, alpha: 1)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRect(x: 55, y: 4, width: 30, height: 30)
        activityIndicator.startAnimating()
        messageFrame.addSubview(activityIndicator)
        messageFrame.addSubview(strLabel)
        return messageFrame
        
    }
    
       
    // Loading spinner
    
    func showLoader( x: CGFloat, y: CGFloat, tag: Int, type: UIActivityIndicatorViewStyle) -> UIActivityIndicatorView {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: type)
        activityIndicator.frame = CGRect(x: x - 15 , y: y , width: 30, height: 30)
        activityIndicator.startAnimating()
        activityIndicator.tag = tag
        return activityIndicator
    }
    
    // Add Loader View
    func addLoaderView(view: UIView, message: String) {
        
        view.userInteractionEnabled = false
        
        let loaderBg = UIView()
        loaderBg.tag = 102
        loaderBg.frame = CGRect(x: 0, y: 0, width: view.bounds.width , height: view.bounds.height)
        loaderBg.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.35)
        view.addSubview(loaderBg)
        
        let loaderConatiner = progressBarDisplayer(message, x: view.center.x, y: view.center.y)
        view.addSubview(loaderConatiner)
        
    }
    
    // Remove Loader View
    func removeLoaderView(view: UIView) {
        view.userInteractionEnabled = true
        view.viewWithTag(101)!.removeFromSuperview()
        view.viewWithTag(102)!.removeFromSuperview()
    }
    
    
    // Grab posts from firebase
    
    func getPosts(complete: completionHandler) {
        
        var counter = 0
        //Get total posts count
        FIREBASE.posts.observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
            MainService.si.totalPosts = snapshot.value!.count
        // Grab whole other user posts
        FIREBASE.posts.queryOrderedByKey().queryLimitedToLast(self.postPerPage).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
            MainService.si.posts = []
            
            counter = 0
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                for post in postDict {
                    var postData = post.1 as? Dictionary<String, AnyObject>
                  
                    // Grab user name of every post
                    
                    FIREBASE.users.child(postData!["uid"] as! String).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
                        if let snap = snapshot.value as? Dictionary<String, AnyObject> where snap["name"] != nil {
                            postData?.updateValue(snap["name"]!.lowercaseString, forKey: "userName")
                            
                            if let pic = snap["image"] {
                                postData?.updateValue(pic, forKey: "userImage")
                            }
                        }
                            let postObj = Post(postKey: post.0, data: postData!)
                        
                            counter = counter + 1
                            MainService.si.posts.append(postObj)
                            if (counter == postDict.count) {
                                // Sorting posts with created timestamp
                                MainService.si.posts.sortInPlace({$0.created_at > $1.created_at})
                                 // Grab loginned user posts
                                FIREBASE.posts.queryOrderedByChild("uid").queryEqualToValue(MainService.si.currentUser?.uid!).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
                                    MainService.si.userPosts = []
                                    counter = 0
                                    if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                        for post in postDict {
                                            var postData = post.1 as? Dictionary<String, AnyObject>
                                            
                                            // Grab user name of every post
                                            FIREBASE.users.child(postData!["uid"] as! String).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
                                                if let snap = snapshot.value as? Dictionary<String, AnyObject> where snap["name"] != nil {
                                                    postData?.updateValue(snap["name"]!.lowercaseString, forKey: "userName")
                                                    if let pic = snap["image"] {
                                                        postData?.updateValue(pic, forKey: "userImage")
                                                    }
                                                }
                                                    let postObj = Post(postKey: post.0, data: postData!)
                                                    MainService.si.userPosts.append(postObj)
                                                    counter = counter + 1
                                                    if (counter == postDict.count) {
                                                        
                                                        MainService.si.userPosts.sortInPlace({$0.created_at > $1.created_at})
                                                        
                                                        complete()
                                                    }
                                                
                                            })
                                            
                                            
                                        }
                                        
                                    }
                                    else {
                                        complete()
                                    }
                                })

                            }
                        
                        
                    })
                    
                }
                
                    
                
                
                
                
            }
        })
            
        })
        
        
    }
    
    func loadMorePosts(complete: completionHandler) {
        if !isLoadingMore {
            isLoadingMore = true
        var counter = 0
        var newPosts = [Post]()
            FIREBASE.posts.queryOrderedByKey().queryEndingAtValue(MainService.si.posts[MainService.si.posts.count - 1].postKey).queryLimitedToLast(postPerPage + 1).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
            counter = 0
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                for post in postDict {
                    var postData = post.1 as? Dictionary<String, AnyObject>
                    
                    // Grab user name of every post
                    
                    FIREBASE.users.child(postData!["uid"] as! String).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
                        if let snap = snapshot.value as? Dictionary<String, AnyObject> where snap["name"] != nil {
                            postData?.updateValue(snap["name"]!.lowercaseString, forKey: "userName")
                            
                            if let pic = snap["image"] {
                                postData?.updateValue(pic, forKey: "userImage")
                            }
                        }
                        let postObj = Post(postKey: post.0, data: postData!)
                        
                        counter = counter + 1
                        
                        if  MainService.si.posts[MainService.si.posts.count - 1].postKey != post.0 {
                            newPosts.append(postObj)
                        }
                        
                        if (counter == postDict.count) {
                            // Sorting posts with created timestamp
                            newPosts.sortInPlace({$0.created_at > $1.created_at})
                            MainService.si.posts = MainService.si.posts + newPosts
                            self.isLoadingMore = false
                            complete()
                        }
                    })
                }
            }
        })
        }
        
    }
    
    // Get current user details
    
    func getCurrentUser(complete: completionHandler) {
        if let currentUser = FIREBASE.auth?.currentUser {
            FIREBASE.users.child(currentUser.uid).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
                if let snap = snapshot.value as? Dictionary<String, AnyObject> where snap["name"] != nil {
                    let name = snap["name"]!.lowercaseString
                    let email = snap["email"] as! String
                    let image: String?
                    if let pic = snap["image"] {
                        image = pic as? String
                    } else {
                        image = nil
                    }
                    
                    let provider = snap["provider"] as! String
                    
                    MainService.si.currentUser = User(name: name, email: email, image: image, uid: snapshot.key, provider: provider )
                    complete()
                }
                
                
            })
            
        }
        
    }
    
    
    
    // Fetch places from google api
    
    func fetchAutocompletePlaces(keyword:String, city: AutoCompleteTextField) {
        let urlString = "\(GOOGLEPLACE.baseUrl)?key=\(GOOGLEPLACE.key)&input=\(keyword)"
        let s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        s.addCharactersInString("+&")
        if let encodedString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(s) {
            if let url = NSURL(string: encodedString) {
                let request = NSURLRequest(URL: url)
                dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let predictions = result["predictions"] as? NSArray{
                                        var locations = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            locations.append(dict["description"] as! String)
                                        }
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            city.autoCompleteStrings = locations
                                        })
                                        return
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                city.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
    
    
    func uploadImage(image: UIImage, resize: Int, complete: imageUploadCompleted) {
        var imgUrl:String?
        let img = UIImageJPEGRepresentation(resizeImage(image, newWidth: 800), 0.25)!
            Alamofire.upload(
                .POST,
                IMAGESHACK.uploadUrl,
                multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: img, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: IMAGESHACK.key!, name: "key")
                    multipartFormData.appendBodyPart(data: IMAGESHACK.format!, name: "format")
                    
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                        
                    case .Success(let upload, _, _):
                        
                        upload.responseJSON { response in
                            if let dict = response.result.value {
                                let result = JSON(dict)
                                imgUrl = result["links"]["image_link"].string
                                complete(true, imgUrl!)
                            }
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                        complete(false, imgUrl)
                    }
                }
            )
        }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func dateFormatConverter(from: String, to: String, date: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = from
        let dateObj = dateFormatter.dateFromString(date)
        
        dateFormatter.dateFormat = to
        if dateObj != nil {
           return "\(dateFormatter.stringFromDate(dateObj!))"
        }
        return "..."
    }
    

        
    
    
    
    
}