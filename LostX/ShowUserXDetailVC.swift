//
//  ShowUserXDetailVC.swift
//  LostX
//
//  Created by Hasgar on 13/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class ShowUserXDetailVC: UIViewController {

    // MARK: Properties
    
    var postId: Int!
    
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var postTitle: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var contactNo: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var contactEmail: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var postAction: UIButton!
    @IBOutlet weak var imageBg: UIImageView!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        
        loadData()
        
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowReactions" {
            if let showReaction = segue.destinationViewController as? ShowReactionsVC {
                if let post = sender as? Int {
                    showReaction.postId = post
                }
            }
        }
        
    }
    
    // MARK: Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postActionPressed(sender: AnyObject) {
        performSegueWithIdentifier("ShowReactions", sender: sender.tag)
    }
    
    // MARK: Methods
    
    func loadData() {
        
        postTitle.text = MainService.si.posts[postId].title
        city.text = "  \(MainService.si.posts[postId].city!)"
        date.text = "  \(MainService.si.dateFormatConverter("dd-mm-yyyy", to: "DD MMM yyyy", date: MainService.si.posts[postId].date))"
        contactNo.text = "  \(MainService.si.posts[postId].contactNo!)"
        contactEmail.text = "  \(MainService.si.posts[postId].contactEmail!)"
        
        //getting pic from cache or url using kingfisher
        image.kf_setImageWithURL(NSURL(string: MainService.si.posts[postId].image!), placeholderImage: UIImage(named: "imgPlaceholder"))
        imageBg.kf_setImageWithURL(NSURL(string: MainService.si.posts[postId].image!), placeholderImage: nil)
        
        if MainService.si.posts[postId].type == "lost" {
            status.text = "LOST!!"
            typeImage.image = UIImage(named: "tabLostFill")
        } else {
            status.text = "FOUND!!"
            typeImage.image = UIImage(named: "tabFoundFill")
        }
        
        makeImageBgBlur()
        
    }
    
    private func makeImageBgBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageBg.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        imageBg.addSubview(blurEffectView)
    }
    
    private func setPostActionText(text: String) {
        postAction.setTitle(text, forState: .Normal)
        postAction.setTitle(text, forState: .Highlighted)
    }
    
    private func setupUI(){
        city.layer.addBorder(UIRectEdge.Left, color: MainService.si.hexStringToUIColor("6FA66D"), thickness: 1)
        date.layer.addBorder(UIRectEdge.Left, color: MainService.si.hexStringToUIColor("6FA66D"), thickness: 1)
        contactNo.layer.addBorder(UIRectEdge.Left, color: MainService.si.hexStringToUIColor("6FA66D"), thickness: 1)
        contactEmail.layer.addBorder(UIRectEdge.Left, color: MainService.si.hexStringToUIColor("6FA66D"), thickness: 1)
    }


}
