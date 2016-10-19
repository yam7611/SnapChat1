//
//  SendPhotoListController.swift
//  LoginTest
//
//  Created by yam7611 on 10/7/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Firebase

class SendPhotoListController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var initialSendBGFrame:CGRect?{
        var tempRect : CGRect?
        tempRect = self.view.frame
        tempRect!.size.height = 0
        tempRect!.origin.y = self.view.frame.height
        return tempRect
    }
    
    var popSendBGFrame:CGRect?{
        var tempRect : CGRect?
        tempRect = self.view.frame
        tempRect!.size.height = 50
        tempRect!.origin.y = self.view.frame.height - 50
        return tempRect
    }
    
    let sendPhotoBtn :UIButton = {
       
        let tempBtn = UIButton()
        tempBtn.setImage(UIImage(named:"play-sign"), forState: .Normal)
        tempBtn.frame.size = CGSizeMake(40,40)
        
        return tempBtn
    }()
    
    var usersArray = [User]()
    var currentUserInfo :User?
    var receiver = [String:User]()
    let cellId = "Cell"
    var list = [String]()
    var users = [String:User]()
    var lifeTime = 0
    var image:UIImage?
    
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
//        didSet{
//
//            let canvas = UIImageView()
//            
//            canvas.frame = CGRectMake(0,40,100,100)
//            canvas.backgroundColor = UIColor.redColor()
//            canvas.image = self.image
//            
//            self.view.addSubview(canvas)

//        }
    
    let listView:UITableView = {
        let tempTableView = UITableView()
        return tempTableView
    
    }()
    
    let sendBtnBackground :UIView = {
       
        let tempView = UIView()
        tempView.backgroundColor = UIColor.init(red: 0, green: 153/255, blue: 1, alpha: 1)
        
        return tempView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        
        setUpComponent()
        fetchFreindList()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleReceivedPhoto(_:)), name: "sendingPhotoFunction", object: nil)
    }
    
    
    func handleReceivedPhoto(notification:NSNotification){
        print("go recevied photo")
//        if let userInfo = notification.userInfo{
//            if let data = userInfo["Photo"] as? UIImage{
//                let image = data
//                let canvas = UIImageView()
//                canvas.frame = CGRectMake(0,40,200,200)
//                canvas.backgroundColor = UIColor.redColor()
//                canvas.image = image
//                self.view.addSubview(canvas)
//                
//            }
//            
//        }
        
    }
    
    func setPhoto(image:UIImage){
        self.image = image
        
    }
    
    func setLife(life:Int){
        self.lifeTime = life
    }
    func fetchFreindList(){
        
        if let thisUser = currentUser{
        
        // fetch current user's info on server
        FIRDatabase.database().reference().child("users").child(thisUser).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let  dictionary = snapshot.value as? [String:AnyObject]{
                self.currentUserInfo = User(dictionary: dictionary,uid:thisUser)
            }
        })
        //  fetch friend number on server
        var usersOndatabase = 0
        FIRDatabase.database().reference().child("users").child(thisUser).child("friends").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            usersOndatabase = Int(snapshot.childrenCount)
        })
            
        // fetch friends data onserver
        var currentLoadingUser = 0
        FIRDatabase.database().reference().child("users").child(thisUser).child("friends").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            currentLoadingUser += 1
            if let dictionary = snapshot.value as? [String:AnyObject]{
            
                    if let status = dictionary["status"] as? String {
                        if status == "mutual" {
                            if let toId = snapshot.key as? String{
                                FIRDatabase.database().reference().child("users").child(toId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                    if let userDict = snapshot.value as? [String:AnyObject]{
                                        let user = User(dictionary: userDict,uid:toId)
                                            self.users["\(user.name)"] = user
                                        self.usersArray = Array(self.users.values)
                                        self.usersArray.sortInPlace({ (user1, user2) -> Bool in
                                            return user1.name > user2.name
                                        })
                                        
                                        if currentLoadingUser == usersOndatabase{
                                            if let currUsInfo = self.currentUserInfo{
                                                 self.usersArray.insert(currUsInfo, atIndex: 0)
                                            }
                                        }
                                        
                                        dispatch_async(dispatch_get_main_queue(), {
                                            
                                            self.listView.reloadData()
                                        })
                                    }
                                })
                                
                            }
                        }
                    }
                }
           
            }, withCancelBlock: nil)
            
        }
        
    }
    
    
    func setUpComponent(){
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(backToCameraView))
        
        listView.registerClass(SendPhotoCell.self,forCellReuseIdentifier: cellId)
        listView.allowsSelection = false
        self.view.backgroundColor = UIColor.redColor()
        self.listView.delegate = self
        self.listView.dataSource = self
  
        self.listView.translatesAutoresizingMaskIntoConstraints = false
        self.listView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.listView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        self.listView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        self.listView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        
        self.listView.backgroundView = UIView()
        self.listView.backgroundColor = UIColor.whiteColor()
        
        self.sendBtnBackground.frame = initialSendBGFrame!
        
        sendPhotoBtn.frame.origin = CGPointMake(self.view.frame.width - 45,5)
        sendPhotoBtn.addTarget(self, action: #selector(sendPhoto), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(putUserToList(_:)), name: "selectUser", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pullUserToList(_:)), name: "deselectUser", object: nil)
     
        
    }
    
    
    func sendPhoto(){
        uploadToFirebaseStorageUsingImage(self.image!)
        print("send out!")
    }
    
    func putUserToList(notification:NSNotification){
        if let userInfo = notification.userInfo{
            if let data = userInfo["index"] as? Int{
                //print("data:\(data),user:\(usersArray[data].uid)")
                self.receiver["\(usersArray[data].name)"] = usersArray[data]
                if self.receiver.count > 0 {
                //show send btn
                    self.view.addSubview(self.sendBtnBackground)
                    self.sendBtnBackground.addSubview(self.sendPhotoBtn)
                    UIView.animateWithDuration(0.3, animations: {
                        self.sendBtnBackground.frame = self.popSendBGFrame!
                        }, completion: nil)
                }
            }
        }
       
    }
    func pullUserToList(notification:NSNotification){
        if let userInfo = notification.userInfo{
            if let data = userInfo["index"] as? Int{
                self.receiver.removeValueForKey("\(usersArray[data].name)")
//                print(" recevier count:\(receiver.count)")
                if self.receiver.count == 0{
                    UIView.animateWithDuration(0.3, animations: {
                        self.sendBtnBackground.frame = self.initialSendBGFrame!
                        }, completion: {(true) in
                            self.sendBtnBackground.removeFromSuperview()
                            self.sendPhotoBtn.removeFromSuperview()
                    })
                }
            }
        }
    }
    func uploadToFirebaseStorageUsingImage(selectedImage:UIImage){
        let imageName = NSUUID().UUIDString
        
        let ref = FIRStorage.storage().reference().child("message-photos").child(imageName)
        
        if let uploadPhoto = UIImageJPEGRepresentation(selectedImage, 0.3){
            ref.putData(uploadPhoto, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print("fail to upload photo")
                    return
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString{
                    for user in self.receiver{
                        
                        
                        self.handleUploadingPhoto(imageURL,image: selectedImage,user:user.1)
                        
                        
                        //print("0 value is:\(user.1.uid!)")
                        
                    }
                    
                }
                
            })
        }
        //self.dismissViewControllerAnimated(true, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        
    }

    private func handleUploadingPhoto(imageURL:String,image:UIImage,user:User){
        let receviedUser = user
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = receviedUser.uid!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp:NSNumber = Int(NSDate().timeIntervalSince1970)
        let value = ["imageURL": imageURL,"fromId" : fromId,"toId":toId,"timestamp" : timestamp,"imageHeight":image.size.height,"imageWidth":image.size.width,"imageLifeTime":self.lifeTime]
        
        childRef.updateChildValues(value) { (error, snapshot) in
            if error != nil{
                print(error)
                return
            }
            let userMessageRef = FIRDatabase.database().reference().child("user-message").child(fromId).child(toId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId:1])
            
            let recipientRef = FIRDatabase.database().reference().child("user-message").child(toId).child(fromId)
            
            recipientRef.updateChildValues([messageId:1])
            
        }
        let storyName = NSUUID().UUIDString
        FIRDatabase.database().reference().child("stories").child("\(storyName)")
        
        FIRDatabase.database().reference().child("stories").child("\(self.currentUser!)").child("\(storyName)").updateChildValues(["photoURL":imageURL,"time":timestamp])
        
    }
    
    
    
    func backToCameraView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //////////////// this part is start of UITableView deleate and data source method///////////////////////
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        
        let cell = listView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as? SendPhotoCell
        cell?.currentIndex = indexPath.row
        listView.rowHeight = cell!.frame.height
        if indexPath.row < usersArray.count{
            cell?.username = self.usersArray[indexPath.row].name
            
        }

        return cell!
    }
    
    //////////////// this part is end of UITableView deleate and data source method///////////////////////
}
