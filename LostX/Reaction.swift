//
//  Post.swift
//  LostX
//
//  Created by Hasgar on 10/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import Foundation

class Reaction {
    
    // MARK: Properties
    
    private var _message: String!
    private var _type: String!
    private var _date: String?
    private var _city: String?
    private var _userName: String?
    private var _userImage: String?
    private var _contactNo: String?
    private var _contactEmail: String?
    private var _uid: String?
    private var _status: Bool?
    private var _created_at: String?
    private var _postKey: String?
    private var _reactionKey: String?
    
    // MARK: Getters
    
    var message: String! {
        return _message
    }
    var type: String! {
        return _type
    }
    var userName: String! {
        return _userName
    }
    var userImage: String! {
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
    var contactNo: String? {
        return _contactNo
    }
    var contactEmail: String? {
        return _contactEmail
    }
    var status: Bool? {
        return _status
    }
    var created_at: String? {
        return _created_at
    }
    var postKey: String? {
        return _postKey
    }
    var reactionKey: String? {
        return _reactionKey
    }
    
    
    
    // for add new reaction from user
    init(message: String!, type: String!, date: String!, contactNo: String?, contactEmail: String?, postKey: String?, city: String?, uid: String?) {
        self._message = message
        self._type = type
        self._date = date
        self._city = city
        self._postKey = postKey
        self._contactNo = contactNo
        self._contactEmail = contactEmail
        self._uid = uid
    }
    
    // for retrieve reactions from firebase
    
    init(postKey: String!, reactionKey: String!, data: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        self._reactionKey = reactionKey
        if let message = data["message"] as? String {
            self._message = message
        }
        if let type = data["type"] as? String {
            self._type = type
        }
        if let uid = data["uid"] as? String {
            self._uid = uid
        }
        if let city = data["city"] as? String {
            self._city = city
        }
        if let date = data["date"] as? String {
            self._date = date
        }
        if let contactNo = data["contactNo"] as? String {
            self._contactNo = contactNo
        }
        if let contactEmail = data["contactEmail"] as? String {
            self._contactEmail = contactEmail
        }
        if let name = data["userName"] as? String {
            self._userName = name
        }
        if let userImage = data["userImage"] as? String {
            self._userImage = userImage
        }
        if let status = data["status"] as? Bool {
            self._status = status
        }
    }
    
    // Add new reaction to firebase
    
    func add(complete: completedAddition) {
        
        let reaction: [String: AnyObject] = ["contactEmail": contactEmail!,
                                         "contactNo": contactNo!,
                                         "date": date,
                                         "message": message,
                                         "type": type,
                                         "uid": uid,
                                         "city": city!,
                                         "created_at": FIREBASE.currentTimeStamp()]
        FIREBASE.posts.child("\(postKey!)/reactions/").queryOrderedByChild("uid").queryEqualToValue(uid).observeSingleEventOfType(FIREBASE.dataEventTypeValue, withBlock: { (snapshot) in
            if let _ = snapshot.value as? Dictionary<String,AnyObject>  {
                complete(true,true)
            }
            else {
                FIREBASE.posts.child("\(self.postKey!)/reactions/").childByAutoId().setValue(reaction, andPriority: FIREBASE.currentTimeStamp()) { (error, ref) -> Void in
                    if error == nil {
                        FIREBASE.users.child("\(self.uid)/reactions/\(self.postKey!)").setValue(true, andPriority: FIREBASE.currentTimeStamp()) { (error, ref) -> Void in
                            if error == nil {
                                
                                complete(true,false)
                            } else {
                                complete(false,false)
                            }
                        }
                    }
                    else {
                        complete(false,false)
                    }
                }
            }
            
            })
        
        
        
        
    }
    
    
    
    func mark(postId: Int, mark: Bool, complete: completed) {
        FIREBASE.posts.child("\(postKey!)/reactions/\(reactionKey!)/status").setValue(mark) { (error, ref) -> Void in
            if error == nil {
                self._status = mark
                MainService.si.posts[postId].setStatus(mark)
                if mark {
                    FIREBASE.posts.child("\(self.postKey!)/status").setValue(mark) { (error, ref) -> Void in
                    if error == nil {
                        complete(true)
                    }
                    else {
                        complete(false)
                        }
                    
                    }
                }
                else {
                complete(true)
                }
            }

        }
    }
    
    func setStatus(status: Bool) {
        _status = status
    }
    
    
    
    
}