//
//  YourXCell.swift
//  LostX
//
//  Created by Hasgar on 13/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit
import Kingfisher

class YourXCell: UITableViewCell {

    
    // MARK: Properties
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var reactionImage: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var reactionText: UIButton!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var userImagePlaceholder: UILabel!
    @IBOutlet weak var options: UIButton!
    @IBOutlet weak var optionSpinner: UIActivityIndicatorView!
    
    var post: Post!
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    override func layoutSubviews() {
        
        userImage.layer.cornerRadius = userImage.bounds.height / 2
        userImage.clipsToBounds = true
        
        userImagePlaceholder.clipsToBounds = true
        userImagePlaceholder.layer.cornerRadius = userImagePlaceholder.bounds.height / 2
        
    }
    
    // MARK: Actions
    
    
    
    // MARK: Methods
    
    func  configureCell(post: Post)  {

        options.hidden = false
        optionSpinner.hidden = true
        
        self.post = post
        
        userName.text = post.name
        title.text = post.title
        city.text = post.city
        date.text = MainService.si.dateFormatConverter("dd-mm-yyyy", to: "DD MMM yyyy", date: post.date)
        
        if post.image != nil {
            
            //getting pic from cache or url using kingfisher
            mainImage.kf_setImageWithURL(NSURL(string: post.image!)!, placeholderImage: nil)
            
        }
        if post.userImage != nil {
            userImagePlaceholder.hidden = true
            //getting pic from cache or url using kingfisher
            userImage.kf_setImageWithURL(NSURL(string: post.userImage!)!, placeholderImage: nil)
        }
            
        else {
            userImagePlaceholder.text = String(MainService.si.currentUser.name!.characters.first!).uppercaseString
            userImagePlaceholder.hidden = false
        }
        
        
        
    }
}
