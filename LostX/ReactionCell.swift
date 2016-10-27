//
//  ReactionCell.swift
//  LostX
//
//  Created by Hasgar on 21/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class ReactionCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var correctReaction: UIButton!
    @IBOutlet weak var wrongReaction: UIButton!
    @IBOutlet weak var reactionResult: UIButton!
    @IBOutlet weak var userImagePlaceholder: UILabel!
    
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mobile.layer.addBorder(UIRectEdge.Left, color: MainService.si.hexStringToUIColor("6FA66D"), thickness: 1)
        email.layer.addBorder(UIRectEdge.Left, color: MainService.si.hexStringToUIColor("6FA66D"), thickness: 1)
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
    
    func  configureCell(reactionId: Int, postId:Int)  {
        username.text = MainService.si.posts[postId].reactions[reactionId].userName
        city.text = MainService.si.posts[postId].reactions[reactionId].city
        email.text = "  \(MainService.si.posts[postId].reactions[reactionId].contactEmail!)"
        mobile.text = "  \(MainService.si.posts[postId].reactions[reactionId].contactNo!)"
        userImagePlaceholder.text = String(MainService.si.posts[postId].reactions[reactionId].userName.characters.first!).uppercaseString
        wrongReaction.hidden = false
        correctReaction.hidden = false
        reactionResult.hidden = true
        if let postStatus = MainService.si.posts[postId].status {
            if postStatus {
                if let reactionStatus = MainService.si.posts[postId].reactions[reactionId].status where reactionStatus == true {
                       setReactionButtonAsCorrect()
                    }
                    else {
                        setReactionButtonAsWrong()
                    }
                
            }
            else {
                if let reactionStatus = MainService.si.posts[postId].reactions[reactionId].status {
                    if reactionStatus {
                        setReactionButtonAsCorrect()
                    }
                    else {
                        setReactionButtonAsWrong()
                    }
                }
                else {
                    reactionResult.hidden = true
                }
            }
        }
       
        
        if MainService.si.posts[postId].reactions[reactionId].userImage != nil {
            userImagePlaceholder.hidden = true
            userImage.kf_setImageWithURL(NSURL(string: MainService.si.posts[postId].reactions[reactionId].userImage!)!, placeholderImage: nil)
            
        }
        else {
            userImagePlaceholder.hidden = false
        }
        
    }
    
    func setReactionButtonAsCorrect() {
        wrongReaction.hidden = true
        correctReaction.hidden = true
        reactionResult.hidden = false
        reactionResult.setTitle("Reaction Marked as Correct", forState: .Normal)
        reactionResult.backgroundColor = MainService.si.hexStringToUIColor("FFEC57")
        reactionResult.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
    }
    
    func setReactionButtonAsWrong() {
        wrongReaction.hidden = true
        correctReaction.hidden = true
        reactionResult.hidden = false
        reactionResult.setTitle("Reaction Marked as Wrong", forState: .Normal)
        reactionResult.backgroundColor = MainService.si.hexStringToUIColor("FA3E3E")
        reactionResult.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

    }

}
