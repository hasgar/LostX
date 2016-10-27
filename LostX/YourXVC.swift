//
//  YourXVC.swift
//  LostX
//
//  Created by Hasgar on 13/10/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class YourXVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var noResult: UILabel!
    var pullRefresh: UIRefreshControl!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupDelegates()
        
        addPullToRefresh()
        
        checkUserPostData()
        
        yourXDataNotificationObserver()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        postTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowUserXDetail" {
            if let postDetail = segue.destinationViewController as? ShowUserXDetailVC {
                if let post = sender as? Int {
                    postDetail.postId = post
                }
            }
        }
        
        if segue.identifier == "ShowReactions" {
            if let showReaction = segue.destinationViewController as? ShowReactionsVC {
                if let post = sender as? Int {
                    showReaction.postId = post
                }
            }
        }
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainService.si.userPosts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = MainService.si.userPosts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("YourXCell") as? YourXCell  {
            cell.configureCell(post)
            cell.reactionText.tag = indexPath.row
            cell.reactionText.addTarget(self, action: #selector(YourXVC.performShowReactionSegue(_:)), forControlEvents: .TouchUpInside)
            cell.options.tag = indexPath.row
            cell.options.addTarget(self, action: #selector(YourXVC.showOptions(_:)), forControlEvents: .TouchUpInside)
            
            return cell
        }
        else {
            return YourXCell()
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("ShowUserXDetail", sender: indexPath.row)
        })
        
    }
    
    
    
    
    // MARK: Actions
    
    
    
    // MAKR: Methods
    
    func checkUserPostData() {
        
        if(MainService.si.userPosts.count > 0 ) {
            noResult.hidden = true
            postTableView.hidden = false
        }
        else {
            noResult.hidden = false
            postTableView.hidden = true
        }
    }
    
    private func addSpinnerToTableviewFooter() {
        
        let loadMoreSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadMoreSpinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 45.0)
        loadMoreSpinner.startAnimating()
        postTableView.tableFooterView = loadMoreSpinner
        
    }
    
    private func setupDelegates() {
        postTableView.delegate = self
        postTableView.dataSource = self
    }
    
    private func yourXDataNotificationObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(YourXVC.addPost(_:)), name: "addPost", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(YourXVC.reloadData(_:)), name: "reloadYourXData", object: nil)
    }
    
    func performShowReactionSegue(sender: AnyObject) {
        
        performSegueWithIdentifier("ShowReactions", sender: sender.tag)
        
    }
    
    func showOptions(sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let deletePost = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            
            let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
            let cell = self.postTableView?.cellForRowAtIndexPath(indexPath)as! YourXCell
            cell.optionSpinner.hidden = false
            cell.options.hidden = true
            MainService.si.userPosts[sender.tag].remove() { () -> () in
                MainService.si.posts = MainService.si.posts.filter{$0.postKey != MainService.si.userPosts[sender.tag].postKey}
                
                MainService.si.userPosts.removeAtIndex(sender.tag)
                
                let indexPathForCell = NSIndexPath(forRow: sender.tag, inSection: 0)
                self.postTableView.beginUpdates()
                self.postTableView.deleteRowsAtIndexPaths([indexPathForCell], withRowAnimation: .None)
                self.postTableView.endUpdates()
                NSNotificationCenter.defaultCenter().postNotificationName("reloadFeedData", object: nil)
            }
            
            
        }
        alertController.addAction(deletePost)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
    }
    
    func addPost(notification: NSNotification) {
        
        let indexPathForCell = NSIndexPath(forRow: 0, inSection: 0)
        postTableView.beginUpdates()
        postTableView.insertRowsAtIndexPaths([indexPathForCell], withRowAnimation: .None)
        postTableView.endUpdates()
        
    }
    
    func reloadData(notification: NSNotification) {
        
        postTableView.reloadData()
        
    }
    
    func refreshPosts(sender:AnyObject) {
        MainService.si.getPosts() { () -> () in
            self.postTableView.reloadData()
            self.pullRefresh.endRefreshing()
            
        }
    }
    
    private func addPullToRefresh() {
        pullRefresh = UIRefreshControl()
        pullRefresh.addTarget(self, action: #selector(YourXVC.refreshPosts(_:)), forControlEvents: UIControlEvents.ValueChanged)
        postTableView.addSubview(pullRefresh)
    }
  

}
