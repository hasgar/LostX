//
//  Settings.swift
//  LostX
//
//  Created by Hasgar on 23/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import Foundation

struct Section {
    
    var heading : String
    var items : [String]
    
    init(title: String, objects : [String]) {
        
        heading = title
        items = objects
    }
}

class SectionsData {
    
    func getSectionsFromData() -> [Section] {
        
        
        var sectionsArray = [Section]()
        
        let animals = Section(title: "Animals", objects: ["Cats"])
        let vehicles = Section(title: "Vehicles", objects: ["Cars", "Boats"])
        let movies = Section(title: "Movies", objects: ["Blade Runner"])
        
        
        sectionsArray.append(animals)
        sectionsArray.append(vehicles)
        sectionsArray.append(movies)
        
        return sectionsArray
    }
}