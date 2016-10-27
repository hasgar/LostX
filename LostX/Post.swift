//
//  Post.swift
//  LostX
//
//  Created by Hasgar on 01/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import Foundation

class Post {
    
    // MARK: Properties
    
    private var _title: String!
    private var _type: String!
    private var _image: String?
    private var _userImage: String?
    private var _date: String?
    private var _city: String?
    private var _contactNo: String?
    private var _contactEmail: String?
    private var _created_at: Int?
    private var _uid: String?
    private var _name: String?
    private var _status: Bool?
    private var _postKey: String?
    private var _reactions = [Reaction]()
    
    // MARK: Getters
    
    var title: String! {
        return _title
    }
    var type: String! {
        return _type
    }
    var image: String? {
        return _image
    }
    var userImage: String? {
        return _userImage
    }
    var city: String? {
        return _city
    }
    var date: String! {
        return _date
    }
    var uid: String! {
        return _uid
    }
    var status: Bool? {
        return _status
    }
    var name: String! {
        return _name
    }
    var contactNo: String? {
        return _contactNo
    }
    var contactEmail: String? {
        return _contactEmail
    }
    var created_at: Int? {
        return _created_at
    }
    var postKey: String? {
        return _postKey
    }
    var reactions: [Reaction] {
        return _reactions
    }
    
    
    // for add new posts from user
    init(title: String!, type: String!, image: String?, date: String!,  city: String?, contactNo: String?, contactEmail: String?, uid: String?) {
        self._title = title
        self._type = type
        self._image = image
        self._city = city
        self._date = date
        self._contactNo = contactNo
        self._contactEmail = contactEmail
        self._uid = uid
        if let name = MainService.si.currentUser.name {
            _name = name
        }
        if let img = MainService.si.currentUser.image {
            _userImage = img
        }
        if let uid = MainService.si.currentUser.uid {
            _uid = uid
        }
    }
    
    // for retrieve posts from firebase
    init(postKey: String!, data: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        if let title = data["title"] as? String {
            self._title = title
        }
        if let type = data["type"] as? String {
            self._type = type
        }
        if let image = data["image"] as? String {
            self._image = image
        }
        if let uid = data["uid"] as? String {
            self._uid = uid
        }
        
        if let status = data["status"] as? Bool {
            self._status = status
        }
        if let date = data["date"] as? String {
            self._date = date
        }
        if let created_at = data["created_at"] as? Int {
            self._created_at = created_at
        }
        if let city = data["city"] as? String {
            self._city = city
        }
        if let userImage = data["userImage"] as? String {
            self._userImage = userImage
        }
        if let contactNo = data["contactNo"] as? String {
            self._contactNo = contactNo
        }
        if let contactEmail = data["contactEmail"] as? String {
            self._contactEmail = contactEmail
        }
        if let name = data["userName"] as? String {
            self._name = name
        }
        
        
    }
    
    // Add new post to firebase
    
    func add(complete: postCreated) {
        
        let post: [String: AnyObject] = ["contactEmail": contactEmail!,
                    "contactNo": contactNo!,
                    "date": date,
                    "image": image!,
                    "title": title,
                    "city": city!,
                    "type": type,
                    "uid": uid,
                    "created_at": FIREBASE.currentTimeStamp(),
                    "status": false]
        
        
        FIREBASE.posts.childByAutoId().setValue(post) { (error, ref) -> Void in
            if error == nil {
                FIREBASE.users.child("\(self.uid)/posts/\(ref.key)").setValue(true) { (error, ref) -> Void in
                    if error == nil {
                        complete(true, ref.key)
                    } else {
                        complete(false, nil)
                    }
                }
            }
            else {
            complete(false, nil)
            }
        }
        
        
    }
    
    func getReactions(complete: completionHandler) {
        var counter = 0
        var reactions = [Reaction]()
        // Grab whole other user posts
        FIREBASE.posts.child("\(postKey!)/reactions").queryOrderedByKey().queryLimitedToLast(MainService.si.postPerPage).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
            counter = 0
            if let reactionDict = snapshot.value as? Dictionary<String, AnyObject> {
                for reaction in reactionDict {
                    var reactionData = reaction.1 as? Dictionary<String, AnyObject>
                    
                    // Grab user name of every post
                    
                    
                    FIREBASE.users.child(reactionData!["uid"] as! String).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
                        if let snap = snapshot.value as? Dictionary<String, AnyObject> where snap["name"] != nil {
                            reactionData?.updateValue(snap["name"]!.lowercaseString, forKey: "userName")
                            
                            if let pic = snap["image"] {
                                reactionData?.updateValue(pic, forKey: "userImage")
                            }
                        }
                        let reactionObj = Reaction(postKey: self.postKey!, reactionKey: reaction.0,  data: reactionData!)
                        
                        counter = counter + 1
                        reactions.append(reactionObj)
                        if (counter == reactionDict.count) {
                            // Sorting posts with created timestamp
                            reactions.sortInPlace({$0.created_at > $1.created_at})
                            self.addReactions(reactions)
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
    
    
    func remove(complete: completionHandler) {
        
        FIREBASE.posts.child(postKey!).removeValueWithCompletionBlock { (error, ref) in
            if error == nil {
                
                FIREBASE.users.child("\(self.uid!)/posts/\(self.postKey!)").removeValueWithCompletionBlock { (error, ref) in
                    if error == nil {
                        complete()
                    }
                    else {
                        MainService.si.showAlert()
                    }
                }
            }
            else {
                MainService.si.showAlert()
            }
        }
        
       
        
    }
    
    func addReactions(reactions: [Reaction]) {
        _reactions = reactions
    }
    
    func addPostKey(postKey: String) {
        _postKey = postKey
    }
    
    func setStatus(status: Bool) {
        _status = status
    }
    
    func setName(newName: String) {
        _name  = newName
    }
    func setImage(newImageUrl: String?) {
        if let image = newImageUrl {
            _userImage  = image
        }
        else {
            _userImage = nil
        }
    }
    
    
    
    
}