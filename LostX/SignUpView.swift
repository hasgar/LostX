//
//  SignUpView.swift
//  LostX
//
//  Created by Hasgar on 23/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class SignUpView: UIView {
    
    override func awakeFromNib() {
        layer.borderWidth = 1;
        layer.borderColor = MainService.si.hexStringToUIColor("#acacac").CGColor
    }


}
