//
//  FeedCell.swift
//  LostX
//
//  Created by Hasgar on 30/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit
import Kingfisher

class FeedCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var reactionIcon: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var reactionText: UIButton!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var userImagePlaceholder: UILabel!
    
    var post: Post!
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        
        userImage.layer.cornerRadius = userImage.bounds.height / 2
        userImage.clipsToBounds = true
        
        userImagePlaceholder.clipsToBounds = true
        userImagePlaceholder.layer.cornerRadius = userImagePlaceholder.bounds.height / 2
        
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    
    // MARK: Actions
    
    
    // MARK: Methods
    
    func configureCell(post: Post)  {
        username.text = post.name
        city.text = post.city
        title.text = post.title
        
        if let status = post.status where status == true {
            setButtonText(reactionText, text: "SOLVED!!")
            reactionText.userInteractionEnabled = false
        }
        else {
            if(post.type == "lost") {
                if post.uid != MainService.si.currentUser.uid {
                    setButtonText(reactionText, text: "I FOUND THIS")
                }
                else {
                    setButtonText(reactionText, text: "SEE REACTIONS")
                }
                reactionIcon.image = UIImage(named: "tabFoundUnfill")
                
                
            }
            if(post.type == "found") {
                if post.uid != MainService.si.currentUser.uid {
                    setButtonText(reactionText, text: "I LOST THIS")
                }
                else {
                   setButtonText(reactionText, text: "SEE REACTIONS")
                }
                reactionIcon.image = UIImage(named: "tabLostUnfill")
            }
        }
        
        date.text = MainService.si.dateFormatConverter("dd-mm-yyyy", to: "DD MMM yyyy", date: post.date)
        if post.image != nil {
            //getting pic from cache or url using kingfisher
            itemImage.kf_setImageWithURL(NSURL(string: post.image!)!, placeholderImage: nil)
        
        }
        
        if post.userImage != nil {
            userImagePlaceholder.hidden = true
            userImage.kf_setImageWithURL(NSURL(string: post.userImage!)!, placeholderImage: nil)
            
        }
        else {
            userImagePlaceholder.text = String(post.name!.characters.first!).uppercaseString
           userImagePlaceholder.hidden = false
        }
        
    
        
    }
    
    func setButtonText(label: UIButton, text: String) {
        label.setTitle(text, forState: .Normal)
        label.setTitle(text, forState: .Highlighted)
    }
    

}
