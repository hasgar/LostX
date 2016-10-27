//
//  TextField.swift
//  LostX
//
//  Created by Hasgar on 04/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 3);

    override func awakeFromNib() {
        
        layer.borderWidth = 1;
        layer.borderColor = MainService.si.hexStringToUIColor("#acacac").CGColor
        
    }
   
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}
