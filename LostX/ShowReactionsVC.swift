//
//  ShowReactionsVC.swift
//  LostX
//
//  Created by Hasgar on 13/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class ShowReactionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    // MARK: Properties
    
    var postId: Int!
    
    @IBOutlet weak var reactionTable: UITableView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var noResultFound: UILabel!
    
    var pullRefresh: UIRefreshControl!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegatesAndTableFooter()
        
        addPullToRefresh()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if MainService.si.posts[postId].reactions.isEmpty {
            reactionTable.hidden = true
            MainService.si.posts[postId].getReactions() { () -> () in
                self.hideLoadingSpinner()
                if MainService.si.posts[self.postId].reactions.isEmpty {
                    
                    self.noResultFound.hidden = false
                    self.reactionTable.hidden = true
                    
                }
                else {
                    self.noResultFound.hidden = true
                    self.reactionTable.hidden = false
                    self.reactionTable.reloadData()
                    
                }
                
            }
            
        }
        else {
            noResultFound.hidden = true
            self.hideLoadingSpinner()
            reactionTable.hidden = false
            reactionTable.reloadData()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainService.si.posts[postId].reactions.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("ReactionCell") as? ReactionCell  {
            
            cell.configureCell(indexPath.row, postId: postId)
            cell.wrongReaction.tag = indexPath.row
            cell.correctReaction.tag = indexPath.row
            cell.wrongReaction.addTarget(self, action: #selector(ShowReactionsVC.markReactionWrong(_:)), forControlEvents: .TouchUpInside)
            cell.correctReaction.addTarget(self, action: #selector(ShowReactionsVC.markReactionCorrect(_:)), forControlEvents: .TouchUpInside)
            
            return cell
        }
        else {
            return ReactionCell()
        }
        
        
    }
    
    
    // MARK: Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Methods
    
    func contactAction(contact:String, type: String) {
        var url: NSURL!
        if type == "Email" {
            url = NSURL(string:"mailto://\(contact)")
        }
        if type == "Call" {
            url = NSURL(string:"tel://\(contact)")
        }
        let confirmAlert = UIAlertController(title: contact, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        confirmAlert.addAction(UIAlertAction(title: type, style: .Default, handler: { (action: UIAlertAction!) in
            if let actionURL:NSURL = url {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(actionURL)) {
                    application.openURL(actionURL)
                }
            }
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(confirmAlert, animated: true, completion: nil)
        
        
    }
    
    func markReactionWrong(sender: AnyObject) {
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "Is this reaction was wrong?", preferredStyle: UIAlertControllerStyle.Alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            MainService.si.posts[self.postId].reactions[sender.tag].mark(self.postId, mark: false) { (completed) -> () in
                
                self.reactionTable.reloadData()
                
            }
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        
        self.presentViewController(confirmAlert, animated: true, completion: nil)
        
        
    }
    
    func markReactionCorrect(sender: AnyObject) {
        
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "Is this reaction was true?", preferredStyle: UIAlertControllerStyle.Alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            MainService.si.posts[self.postId].reactions[sender.tag].mark(self.postId, mark: true) { (completed) -> () in
                
                self.reactionTable.reloadData()
                
            }
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        
        self.presentViewController(confirmAlert, animated: true, completion: nil)
        
    }
    
    private func isReactionsAvailabe() -> Bool {
        
        if MainService.si.posts[postId].reactions.isEmpty {
            
            MainService.si.posts[postId].getReactions() { () -> () in
                
                return true
                
            }

        }
        else {
            return false
        }
        
        return true
    }
    
    private func hideLoadingSpinner() {
        
        loadingSpinner.stopAnimating()
        loadingSpinner.hidden = true
    }
    
    private func showLoadingSpinner() {
        
        loadingSpinner.startAnimating()
        loadingSpinner.hidden = false
    }
    
    func refreshReactions(sender:AnyObject) {
        
        MainService.si.posts[postId].getReactions() { () -> () in
            self.reactionTable.reloadData()
            self.pullRefresh.endRefreshing()
            
        }

        
    }
    
    private func setupDelegatesAndTableFooter() {
        reactionTable.delegate = self
        reactionTable.dataSource = self
        reactionTable.tableFooterView = UIView()
    }
    
    private func addPullToRefresh() {
        pullRefresh = UIRefreshControl()
        pullRefresh.addTarget(self, action: #selector(ShowReactionsVC.refreshReactions(_:)), forControlEvents: UIControlEvents.ValueChanged)
        reactionTable.addSubview(pullRefresh)
    }
    

    

}
