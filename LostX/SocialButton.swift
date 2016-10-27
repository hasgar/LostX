//
//  SocialButton.swift
//  LostX
//
//  Created by Hasgar on 23/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class SocialButton: UIButton {

    override func awakeFromNib() {
        layer.borderWidth = 2;
        layer.borderColor = MainService.si.hexStringToUIColor("#6e84b5").CGColor
        
    }
    

}
