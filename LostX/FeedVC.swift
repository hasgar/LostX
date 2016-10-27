//
//  FeedVC.swift
//  LostX
//
//  Created by Hasgar on 28/09/16.
//  Copyright © 2016 KerningLess. All rights reserved.
//

import UIKit

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var noResult: UILabel!
    let loadMoreSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var pullRefresh: UIRefreshControl!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        
        addPullToRefresh()
        
        if feedDataAvailable() {
        
            addSpinnerToTableViewFooter()
            
        }
        
        feedDataNotificationObserver()
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent , animated: animated)
        postTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if let postDetail = segue.destinationViewController as? ShowDetailVC {
                if let post = sender as? Int {
                    postDetail.postId = post
                }
            }
        }
        
        if segue.identifier == "AddReaction" {
            if let postDetail = segue.destinationViewController as? AddReactionVC {
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
        return MainService.si.posts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as? FeedCell  {
            cell.configureCell(MainService.si.posts[indexPath.row])
            cell.reactionText.tag = indexPath.row
            cell.reactionText.addTarget(self, action: #selector(FeedVC.performAddReactionSegue(_:)), forControlEvents: .TouchUpInside)
            
            return cell
        }
        else {
            return FeedCell()
        }
       
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row + 1) == MainService.si.posts.count {
            MainService.si.loadMorePosts() { () -> () in
                
                self.postTableView.reloadData()
                
            }
        }
        
        if (indexPath.row + 1) == MainService.si.totalPosts {
            removeSpinnerFromTableViewFooter()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("ShowDetail", sender: indexPath.row)
        })
        

    }
    

    
    // MARK: Actions
    
    @IBAction func iLostButtonPressed(sender: AnyObject) {
        
        tabBarController?.selectedIndex = 1
        
    }
    
    @IBAction func iFoundButtonPressed(sender: AnyObject) {
        
        tabBarController?.selectedIndex = 2
        
    }
    
    // MARK: Methods
    
    func performAddReactionSegue(sender: AnyObject) {
        if MainService.si.posts[sender.tag].uid != MainService.si.currentUser.uid {
            performSegueWithIdentifier("AddReaction", sender: sender.tag)
        }
        else {
            performSegueWithIdentifier("ShowReactions", sender: sender.tag)
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
    
    
    func feedDataAvailable() -> Bool{
        
        if(MainService.si.posts.count > 0 ) {
            noResult.hidden = true
            
            return true
        }
        else {
            noResult.hidden = false
            postTableView.hidden = true
            return false
        }
    }
    
    func addSpinnerToTableViewFooter() {
    
        
        loadMoreSpinner.hidesWhenStopped = true
        loadMoreSpinner.startAnimating()
        loadMoreSpinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 45.0)
        postTableView.tableFooterView = loadMoreSpinner
    
    }
    
    func removeSpinnerFromTableViewFooter() {
        loadMoreSpinner.stopAnimating()
        postTableView.tableFooterView = nil
    }
    
    
    func feedDataNotificationObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.addPost(_:)), name: "addPost", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.reloadData(_:)), name: "reloadFeedData", object: nil)
        
    }
    
    func refreshPosts(sender:AnyObject) {
        MainService.si.getPosts() { () -> () in
            self.postTableView.reloadData()
            self.pullRefresh.endRefreshing()
            
        }
    }
    
    private func setupDelegates() {
        postTableView.delegate = self
        postTableView.dataSource = self
    }
    
    private func addPullToRefresh(){
        pullRefresh = UIRefreshControl()
        pullRefresh.addTarget(self, action: #selector(FeedVC.refreshPosts(_:)), forControlEvents: UIControlEvents.ValueChanged)
        postTableView.addSubview(pullRefresh)
    }
    

}
