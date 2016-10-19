//
//  storyViewController.swift
//  LoginTest
//
//  Created by yam7611 on 10/17/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Firebase

class storyViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    var usersMappingDict = [String:String]()
    var storyDataArray = [[Story]]()
    var userArray = [String]()
    var usersDict = [String:User]()
    var stories = [Story]()
    //var mappingTable = [String:String]()
    let cellId = "CellId"
    var friendMemoryTableView = UITableView()
    var publicMediaScrollView = UIScrollView()
    var middleView = UIView()
    var timer = NSTimer()
    var timerForUpdatingTable = NSTimer()
    var counting = 0
    var selectedSelection : Int?
    var background :UIView?
    var counterForShowingImage:UILabel? = {
        let tempLabel = UILabel()
        tempLabel.layer.cornerRadius = 15
        tempLabel.layer.masksToBounds = true
        tempLabel.textColor = UIColor.blackColor()
        tempLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
        tempLabel.textAlignment = .Center
        
        return tempLabel
    }()
    var leftTime = 5
    var lifeTime = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()) {
            self.fetchFriendList()
        }
        self.timerForUpdatingTable = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(fetchStoryList), userInfo: nil, repeats: false)
        //print("load storyView ")
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.friendMemoryTableView)
        self.view.addSubview(middleView)
        self.view.addSubview(self.publicMediaScrollView)
        setComponent()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
       
        
        
    }
    
    func fetchFriendList(){
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        
        if let uid = userId{
            FIRDatabase.database().reference().child("users").child("\(uid)").child("friends").observeEventType(.ChildAdded, withBlock: { (snapshot) in
               // print(snapshot)
               // print("go inside fetchFriendList")
                
                let username =  snapshot.key
                guard let relationship = snapshot.value?["status"]  else{
                    print("fail to unwrap friend")
                    return
                    
                }
               // print("\(relationship!),\(username!)")
                
                guard let rel = relationship as? String, usern = username as? String else {
                    print("fail to convert")
                    return
                }
                //print("rel:\(rel)")
                if rel == "mutual"{
                    //self.usersArray.append(usern)
                    FIRDatabase.database().reference().child("users").child("\(usern)").child("name").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                       
                        if let name = snapshot.value as? String{
                            self.usersMappingDict["\(usern)"] = name
                           // print(self.usersMappingArray.count)
                        }
                        
                        
                    })
                }

                }, withCancelBlock:{(true) in
                    
                    print("cancel to observe data")
                })
        }
//        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(fetchStoryList), userInfo: nil, repeats: false)

        //
//        if usersMappingArray.count != 0{
//            self.fetchStoryList()
//        }
       
        
    }
    
    func fetchStoryList(){
        //print("go fS")
       // print("fc = \(self.usersMappingArray.count)")
        
        for (userId,_) in self.usersMappingDict{
            print("userId:\(userId)")
            FIRDatabase.database().reference().child("stories").child("\(userId)").observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                //print(snapshot)
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let story = Story(dictionary:dictionary)
                    story.userId = userId
                    self.stories.append(story)
                    
                    //print("story's uId:\(story.userId)")
                    self.stories.sortInPlace({ (st1, st2) -> Bool in
                        return Int(st1.time!) > Int(st2.time!)
                    })
                }
                dispatch_async(dispatch_get_main_queue(), {
                    //self.friendMemoryTableView.reloadData()
                    self.friendMemoryTableView.reloadData()
                })
            })
            
        }
        
        
    }
    func continueupdateTable(){
        
        self.friendMemoryTableView.reloadData()
    }
    func setComponent(){
        
        self.friendMemoryTableView.clipsToBounds = true
        self.friendMemoryTableView.allowsMultipleSelection = false
       // self.publicMediaScrollView.showsVerticalScrollIndicator = false
        
        self.selectedSelection = -1
        self.navigationItem.title = "Stories"
        self.edgesForExtendedLayout = .None
        self.friendMemoryTableView.delegate = self
        self.friendMemoryTableView.dataSource = self
        self.publicMediaScrollView.frame = CGRectMake(0,60,self.view.frame.width,self.view.frame.height/3)
        self.middleView.frame.size = CGSizeMake(self.view.frame.width,40)
        self.publicMediaScrollView.contentSize = self.publicMediaScrollView.frame.size
        
        //print("publicViewHeight:\(self.publicMediaScrollView.frame.height)")
        //print("contentSize.height = \(self.publicMediaScrollView.contentSize.height)")
        
        let label = UILabel()
        label.frame.size = CGSizeMake(150,40)
        label.text = "recent update"
        label.textAlignment = .Center
        label.center.x = self.view.center.x
        self.middleView.addSubview(label)
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "friendList", style: .Plain , target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "add friend", style: .Plain, target: self, action: #selector(GoAddFriend))
        
        self.middleView.translatesAutoresizingMaskIntoConstraints = false
        self.middleView.topAnchor.constraintEqualToAnchor(self.publicMediaScrollView.bottomAnchor).active = true
        self.middleView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        self.middleView.heightAnchor.constraintEqualToConstant(40).active = true
        
        self.friendMemoryTableView.backgroundView = UIView()
        //self.friendMemoryTableView.backgroundColor = UIColor.blueColor()
        self.friendMemoryTableView.translatesAutoresizingMaskIntoConstraints = false
        self.publicMediaScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.publicMediaScrollView.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant: 0).active = true
        self.publicMediaScrollView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        self.publicMediaScrollView.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor, multiplier: 1/3).active = true
        
            self.friendMemoryTableView.topAnchor.constraintLessThanOrEqualToAnchor(self.middleView.bottomAnchor).active = true
        self.friendMemoryTableView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        self.friendMemoryTableView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        
        self.friendMemoryTableView.registerClass(StoryCell.self, forCellReuseIdentifier: cellId)
        
        let imgArray = ["1","2","3.png","4.png","5.png","6.png","7.png"]
        
        for i in 0..<imgArray.count{
            self.publicMediaScrollView.contentSize.height = 130
            let imgV = UIImageView()
            //imgV.frame.size = CGSizeMake(self.publicMediaScrollView.frame.width/2,self.publicMediaScrollView.frame.height)
            imgV.frame.origin  = CGPointMake(130 * CGFloat(i),0)
            imgV.frame.size = CGSizeMake(130,130)
            //print("photoHeight:\(imgV.frame.height)")
            //print(imgV.frame)
            
            imgV.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
            imgV.image = UIImage(named:imgArray[i])
            if i >= 2{
                publicMediaScrollView.contentSize.width = publicMediaScrollView.contentSize.width + imgV.frame.width
            }
            self.publicMediaScrollView.addSubview(imgV)
            //print("contentSize:\(publicMediaScrollView.contentSize.width)")
            //print("self.ViewSize:\(self.view.frame.width)")
        }
        self.publicMediaScrollView.contentSize.width = 130 * CGFloat(imgArray.count)
        
    }
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func GoAddFriend(){
        let adFVC = AddFriendViewController()
        let naviVC = UINavigationController(rootViewController: adFVC)
        self.presentViewController(naviVC, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = self.friendMemoryTableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as? StoryCell
        let story = stories[indexPath.row]
        cell?.story = story
        //print(cell?.timingLb.text)
        
       // print("you select:\(indexPath.row)")
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.friendMemoryTableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as? StoryCell
        
        
        if indexPath.row < stories.count{
            let story = stories[indexPath.row]
            cell?.story = story
            
//            if let imgeURL = stories[indexPath.row].photoURL{
//                 print("the image url:\(imgeURL)")
//            } else {
//                print("fail to load url")
//            }
            
            let username = usersMappingDict[story.userId!]
            cell?.nameLb.text = username
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
            tapGesture.delegate = self
            cell?.addGestureRecognizer(tapGesture)
            //cell?.timingLb.text = story.time!
            //cell?.imageV.loadImageUsingCacheWithUrlString(story.photoURL!)
           
        }
        return cell!
        
    }
    
    var smallPhotoRect :CGRect?
    
    func tapped(tapGesture:UITapGestureRecognizer){
        if let cellView = tapGesture.view as? StoryCell{
            //print(cellView.timingLb.text)
            
            self.navigationController?.navigationBarHidden = true
            
                
//                timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(closePhoto), userInfo: nil, repeats: false)
//                if let window = UIApplication.sharedApplication().keyWindow{
//                    
//                    let imgv = UIImageView(image: img)
//                    imgv.contentMode = .ScaleAspectFit
//                    imgv.backgroundColor = UIColor.blackColor()
//                    imgv.frame = window.frame
//                    self.view.addSubview(imgv)
//                }
                
            
            
            ////////////////
            let zoomInImageView = UIImageView()
            if let img = cellView.imageV.image{
                zoomInImageView.image = img
            }
            smallPhotoRect = cellView.superview?.convertRect(cellView.frame, toView: nil)
            zoomInImageView.frame = smallPhotoRect!
            
            if let keyWindow = UIApplication.sharedApplication().keyWindow{
                
                self.background = UIView(frame:keyWindow.frame)
                self.background?.backgroundColor = UIColor.blackColor()
                self.background?.alpha = 0
                keyWindow.addSubview(self.background!)
                keyWindow.addSubview(zoomInImageView)
                
                UIView.animateWithDuration(0.3, animations: {
//                    let frameHeight = keyWindow.frame.width * (imageView.frame.height/imageView.frame.width)
//                    zoomInImageView.frame = CGRectMake(0,0,keyWindow.frame.width,frameHeight)
                    zoomInImageView.frame = keyWindow.frame
                    zoomInImageView.contentMode = .ScaleAspectFit
                    self.background?.alpha = 1
                    //zoomInImageView.center = keyWindow.center
                    keyWindow.backgroundColor = UIColor.blackColor()
                    }, completion:{(true) in
                        self.counterForShowingImage?.text = "\(self.lifeTime)"
                        self.counterForShowingImage?.frame = CGRectMake(keyWindow.frame.width - 40,40,30,30)
                        if let cterShowImg = self.counterForShowingImage{
                            keyWindow.addSubview(cterShowImg)
                        }
                })
            }
            //MARK: set life time to 5 sec,could be changed later
            //self.leftTime = 5
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
            
            UIView.animateWithDuration(0.3, delay: Double(lifeTime), options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.background?.alpha = 0
                zoomInImageView.frame = self.smallPhotoRect!
                }, completion: { (true) in
                    self.background?.removeFromSuperview()
                    zoomInImageView.removeFromSuperview()
                    self.counterForShowingImage?.removeFromSuperview()
                    self.navigationController?.navigationBarHidden = false
            })
                
            
            
            
            /////////////////
            
        }
        
    }
    func updateTimer(){
        if self.leftTime >= 0 {
            self.leftTime = self.leftTime - 1
            self.counterForShowingImage?.text = "\(self.leftTime)"
        } else {
            
            leftTime = 5
            lifeTime = 5
            self.timer.invalidate()
            //removePhotoFromServer()
        }
    }
    
    
    func closePhoto(){
        
    }
    
}
