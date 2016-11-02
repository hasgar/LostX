//
//  Constants.swift
//  LostX
//
//  Created by Hasgar on 25/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


    typealias completedAddition = (Bool,Bool) -> ()
    typealias completionHandler = () -> ()
    typealias completed = (Bool) -> ()
    typealias postingCompleted = (Bool,Post) -> ()
    typealias imageUploadCompleted = (Bool, String?) -> ()
    typealias postCreated = (Bool, String?) -> ()


    // MAKE: Segue

    struct SEGUE {
        static let LoadFeed = "LoadFeed"
        static let LoadFeedAuth = "LoadFeedAfterAuth"
        static let LoadFeedLogin = "LoadFeedAfterLogin"
        static let auth = "ShowAuth"
    }

    // MAKE: Alert

    struct ALERT {
        static let invalidEmail = "Invalid Email Address"
    }


    // MAKE: Firebase

    struct FIREBASE {
        static let ref = FIRDatabase.database().reference()
        static let auth = FIRAuth.auth();
        static let users = ref.child("users")
        static let posts = ref.child("posts")
        static let reactions = ref.child("reactions")
        static let dataEventTypeValue = FIRDataEventType.Value
        static let dataEventTypeChildAdded = FIRDataEventType.ChildAdded
        static let currentTimeStamp = FIRServerValue.timestamp
        
    }

    // MAKE: Google Maps

    struct GOOGLEPLACE {
        static let key = MainService.si.getApiKey("googleplace")
        static let baseUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    }

    // MAKE: Imageshack API

    struct IMAGESHACK {
        static let key = MainService.si.getApiKey("imageshack").dataUsingEncoding(NSUTF8StringEncoding)
        static let format = "json".dataUsingEncoding(NSUTF8StringEncoding)
        static let uploadUrl = "https://post.imageshack.us/upload_api.php"
    }








