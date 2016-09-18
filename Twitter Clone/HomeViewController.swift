//
//  HomeViewController.swift
//  Twitter Clone
//
//  Created by Varun Nath on 24/08/16.
//  Copyright © 2016 UnsureProgrammer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {

    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser = AnyObject?()
    var loggedInUserData = AnyObject?()
    
    
    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    @IBOutlet weak var homeTableView: UITableView!
    
    var defaultImageViewHeightConstraint:CGFloat = 77.0
    
    var tweets = [AnyObject?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        
        //get the logged in users details
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observeSingleEventOfType(.Value) { (snapshot:FIRDataSnapshot) in
            
            //store the logged in users details into the variable 
            self.loggedInUserData = snapshot
            print(self.loggedInUserData)
            
            //get all the tweets that are made by the user
            
            self.databaseRef.child("tweets/\(self.loggedInUser!.uid)").observeEventType(.ChildAdded, withBlock: { (snapshot:FIRDataSnapshot) in
              
                
                self.tweets.append(snapshot)
                
                
                self.homeTableView.insertRowsAtIndexPaths([NSIndexPath(forRow:0,inSection:0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                self.aivLoading.stopAnimating()
                
            }){(error) in
           
                print(error.localizedDescription)
            }
            
        }
        
        
        self.homeTableView.rowHeight = UITableViewAutomaticDimension
        self.homeTableView.estimatedRowHeight = 140
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell: HomeViewTableViewCell = tableView.dequeueReusableCellWithIdentifier("HomeViewTableViewCell", forIndexPath: indexPath) as! HomeViewTableViewCell
        
        
        let tweet = tweets[(self.tweets.count-1) - indexPath.row]!.value["text"] as! String
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapMediaInTweet(_:)))
        
        cell.tweetImage.addGestureRecognizer(imageTap)
        
        if(tweets[(self.tweets.count-1) - indexPath.row]!.value["picture"] !== nil)
        {
            cell.tweetImage.hidden = false
            cell.imageViewHeightConstraint.constant = defaultImageViewHeightConstraint
            
            let picture = tweets[(self.tweets.count-1) - indexPath.row]!.value["picture"] as! String
            
            let url = NSURL(string:picture)
            cell.tweetImage.layer.cornerRadius = 10
            cell.tweetImage.layer.borderWidth = 3
            cell.tweetImage.layer.borderColor = UIColor.whiteColor().CGColor
            
            cell.tweetImage!.sd_setImageWithURL(url, placeholderImage: UIImage(named:"twitter")!)
            
        }
        else
        {
            cell.tweetImage.hidden = true
            cell.imageViewHeightConstraint.constant = 0
        }
        
        cell.configure(nil,name:self.loggedInUserData!.value["name"] as! String,handle:self.loggedInUserData!.value["handle"] as! String,tweet:tweet)
        
        
        return cell
    }
    
    func didTapMediaInTweet(sender:UITapGestureRecognizer)
    {
        
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        newImageView.frame = self.view.frame
        
        newImageView.backgroundColor = UIColor.blackColor()
        newImageView.contentMode = .ScaleAspectFit
        newImageView.userInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target:self,action:#selector(self.dismissFullScreenImage))
        
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)

    }
    
    func dismissFullScreenImage(sender:UITapGestureRecognizer)
    {
        sender.view?.removeFromSuperview()
    }

}
