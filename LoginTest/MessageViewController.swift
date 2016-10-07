//
//  MessageViewController.swift
//  LoginTest
//
//  Created by yam7611 on 9/19/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

//fixed message chat cell issue 

import UIKit
import Firebase

class MessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    let containerView = UIView()
    
    var keyboardHeight:CGFloat?
    let cellId = "CellId"
    let myAccount = FIRAuth.auth()!.currentUser!.uid
    var leftTime = 0
    var timer = NSTimer()
    var counterForShowingImage :UILabel? = {
        let tempLabel = UILabel()
        tempLabel.layer.cornerRadius = 15
        tempLabel.layer.masksToBounds = true
        tempLabel.textColor = UIColor.blackColor()
        tempLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
        tempLabel.textAlignment = .Center
        
        return tempLabel
    }()
    var user : User? {
        didSet{
            navigationItem.title = user?.name
        }
    }
    

    
    let messageTableVIew = UITableView()
    
//    let listOfMessageDict = ["yam7611@yahoo.com.tw","yam7611@yahoo.com.tw","yam7611@yahoo.com.tw","Tim"]
//    let listOfMessage = ["Hello","Nice to meet you","my name is David","my name is Tim,nice to meet you,too."]
    
    let inputbox:UITextField = {
    
        let tempTF = UITextField()
        tempTF.placeholder = " type message here.."
        tempTF.backgroundColor = UIColor.whiteColor()
        tempTF.frame.origin.x = 0
        tempTF.frame.size.height = 50
        return tempTF
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        //let bgv = UIView()
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(handleBack))
        self.view.backgroundColor = UIColor.whiteColor()
        messageTableVIew.dataSource = self
        messageTableVIew.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        messageTableVIew.frame = CGRectMake(0,0,self.view.frame.width,self.view.frame.height - 60)
        messageTableVIew.separatorStyle = .None
        self.view.addSubview(messageTableVIew)
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "freind", style: .Plain, target: self, action: #selector(handleBackToFriendList))
        
        
//        messageTableVIew.translatesAutoresizingMaskIntoConstraints = false
//        messageTableVIew.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
//        
//        messageTableVIew.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
//        messageTableVIew.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor, multiplier: 0.9).active = true
        
       // messageTableVIew.heightAnchor.constraintEqualToConstant(150).active = true
        
        
        
        
        
        setupInputContainer()
      
        observeUserMessage()
       // messageTableVIew.topAnchor.constraintEqualToAnchor(self..bottomAnchor)
//        messageTableVIew.bottomAnchor.constraintEqualToAnchor(self.containerView.topAnchor, constant: -5).active = true
//        
        self.messageTableVIew.allowsSelection = false
        
        self.messageTableVIew.registerClass(MessageCell.self, forCellReuseIdentifier: cellId)
        
        self.messageTableVIew.estimatedRowHeight = 50
        self.messageTableVIew.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.inputbox.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(adjustNewView(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    
    func adjustNewView(notificaiton:NSNotification){
        if let userInfo = notificaiton.userInfo{
            if let frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
                keyboardHeight = frame.height
                
                if let keyboardHeight = self.keyboardHeight{
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.containerView.frame.origin.y -= keyboardHeight
                        }, completion: nil)
                }
   
            }
        }
    }
    
    var smallPhotoRect :CGRect?
    var background:UIView?
    
    func loadFullScreenPhoto(tapGesture:UITapGestureRecognizer){
        
        if let imageView = tapGesture.view as? UIImageView{
            let zoomInImageView = UIImageView()
            let superView = imageView.superview
            var lifeTime = 0
            if let cell = superView as? MessageCell{
                if let index = cell.currentIndex{
                    print("index:\(index)")
                    if let lt = messages[index].imageLifeTime{
                        lifeTime = Int(lt)
                    }
                }
            }
            
            
            //if the photo's display time is limited
            
           if lifeTime != 0 {
            
                zoomInImageView.image = imageView.image
                smallPhotoRect = imageView.superview?.convertRect(imageView.frame, toView: nil)
                zoomInImageView.frame = smallPhotoRect!
            
                if let keyWindow = UIApplication.sharedApplication().keyWindow{
                    
                    self.background = UIView(frame:keyWindow.frame)
                    self.background?.backgroundColor = UIColor.blackColor()
                    self.background?.alpha = 0
                    keyWindow.addSubview(self.background!)
                    keyWindow.addSubview(zoomInImageView)
                    
                    UIView.animateWithDuration(0.3, animations: {
                        let frameHeight = keyWindow.frame.width * (imageView.frame.height/imageView.frame.width)
                        zoomInImageView.frame = CGRectMake(0,0,keyWindow.frame.width,frameHeight)
                        self.background?.alpha = 1
                        zoomInImageView.center = keyWindow.center
                        keyWindow.backgroundColor = UIColor.blackColor()
                        }, completion:{(true) in
                            self.counterForShowingImage?.text = "\(lifeTime)"
                            self.counterForShowingImage?.frame = CGRectMake(keyWindow.frame.width - 40,40,30,30)
                            keyWindow.addSubview(self.counterForShowingImage!)
                    })
                }
            
                self.leftTime = lifeTime
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
                
                UIView.animateWithDuration(0.3, delay: Double(lifeTime), options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.background?.alpha = 0
                    zoomInImageView.frame = self.smallPhotoRect!
                    }, completion: { (true) in
                        self.background?.removeFromSuperview()
                        zoomInImageView.removeFromSuperview()
                        self.counterForShowingImage?.removeFromSuperview()
                })
 
                } else {
            
                zoomInImageView.image = imageView.image
                print("you pick the photo named:\(zoomInImageView.image.debugDescription)")
                
                zoomInImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackToChatView)))
                zoomInImageView.userInteractionEnabled = true
                smallPhotoRect = imageView.superview?.convertRect(imageView.frame, toView: nil)
                print(smallPhotoRect)
                zoomInImageView.frame = smallPhotoRect!
                if let keyWindow = UIApplication.sharedApplication().keyWindow{
                    
                    self.background = UIView(frame:keyWindow.frame)
                    self.background?.backgroundColor = UIColor.blackColor()
                    self.background?.alpha = 0
                    keyWindow.addSubview(self.background!)
                    keyWindow.addSubview(zoomInImageView)
                    
                    UIView.animateWithDuration(0.3, animations: {
                        let frameHeight = keyWindow.frame.width * (imageView.frame.height/imageView.frame.width)
                        zoomInImageView.frame = CGRectMake(0,0,keyWindow.frame.width,frameHeight)
                        self.background?.alpha = 1
                        zoomInImageView.center = keyWindow.center
                        keyWindow.backgroundColor = UIColor.blackColor()
                        }, completion: nil)
                }
            
            }

        }
        
    }
    

    func updateTimer(){
        if self.leftTime >= 0 {
            self.leftTime = self.leftTime - 1
            self.counterForShowingImage?.text = "\(self.leftTime)"
        } else {
            self.timer.invalidate()
        }
    }
    
    func handleBackToChatView(tapGesture:UITapGestureRecognizer){
        
        if let imagView = tapGesture.view{
            UIView.animateWithDuration(0.3, animations: {
                if let smallRect = self.smallPhotoRect{
                    imagView.frame = smallRect
                }
                self.background?.alpha = 0
                
                
            }, completion:{ (true) in
                imagView.removeFromSuperview()
                self.background?.removeFromSuperview()
            })
        }
            
    }
    
    func setupInputContainer(){
        
        
        containerView.backgroundColor = UIColor.redColor()
       // containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.frame = self.view.frame
        containerView.frame.origin.y = self.view.frame.height - 50
        containerView.backgroundColor = UIColor.whiteColor()
        
        inputbox.frame.origin.x = 60
        inputbox.frame.origin.y = 1
        
        inputbox.frame.size.width = self.view.frame.width - 60
        
        
        self.containerView.addSubview(inputbox)
        
        let sendButton = UIButton()
        sendButton.frame = CGRectMake(inputbox.frame.width + 10, 1,40,50)
        sendButton.setTitle("send", forState: UIControlState.Normal)
        
        sendButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        
        sendButton.addTarget(self, action: #selector(handleSendMessage), forControlEvents: UIControlEvents.TouchUpInside)
        sendButton.backgroundColor = UIColor.whiteColor()
        self.containerView.addSubview(sendButton)
        
        let uploadPhoto = UIImageView(image:UIImage(named: "picture"))
        
        uploadPhoto.frame = CGRectMake(0,1,50,50)
        uploadPhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        uploadPhoto.userInteractionEnabled = true
        
        self.containerView.addSubview(uploadPhoto)
        
        let seperator = UIView()
        
        seperator.backgroundColor = UIColor.lightGrayColor()
        seperator.frame.size.height = 1
        seperator.frame.size.width = self.view.frame.width
        seperator.frame.origin.y = 0
        seperator.frame.origin.x = 0
        
        self.containerView.addSubview(seperator)
        
    }
    
    
    func handleTap(){
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.allowsEditing = true
        
        self.presentViewController(imagePickerController, animated: true,completion: nil)
    }
    
    func handleBackToFriendList(){
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func handleSendMessage(){

        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.uid!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp:NSNumber = Int(NSDate().timeIntervalSince1970)
        let value = ["text": inputbox.text!,"fromId" : fromId,"toId":toId,"timestamp" : timestamp]
        
        inputbox.text  = ""
        
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
    }
    
    
    private func handleUploadingPhoto(imageURL:String,image:UIImage){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.uid!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp:NSNumber = Int(NSDate().timeIntervalSince1970)
        let value = ["imageURL": imageURL,"fromId" : fromId,"toId":toId,"timestamp" : timestamp,"imageHeight":image.size.height,"imageWidth":image.size.width,"imageLifeTime":5]
        
        inputbox.text  = ""
        
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

    }
    
    
    func observeUserMessage(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid,toId = user?.uid else{
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-message").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in

            let userId = snapshot.key
            
            FIRDatabase.database().reference().child("user-message").child(uid).child(userId).observeEventType(.ChildAdded, withBlock: { (snapshot) in
     
                let messageId  = snapshot.key
                let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
    
                messageRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                    guard let dictionary = snapshot.value as? [String:AnyObject]else {
    
                        return
                    }
    
                    let message = Message(dictionary:dictionary) 
                    
                    if message.chatPartnerId() == self.user?.uid{
                         self.messages.append(message)
                    }
                   
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        self.messageTableVIew.reloadData()
                        
                        })
                    
                }, withCancelBlock: nil)
            
            
          }, withCancelBlock: nil)
        return
        }, withCancelBlock: nil)
        
    }
    
    var messages = [Message]()

    
    @IBAction func goToAboutSnapchater(sender: UIBarButtonItem) {
        
        let aboutVC = AboutSanpChatter()
        presentViewController(aboutVC, animated: true, completion: nil)
    }
    @IBAction func goToTakingPhoto(sender: UIBarButtonItem) {
        tabBarController?.selectedIndex = 0
       
    }
    
    func handleBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        var selectedImageFromAlburm:UIImage?
        
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromAlburm = editImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromAlburm = originalImage
        }
        if let selectedImage = selectedImageFromAlburm {
            uploadToFirebaseStorageUsingImage(selectedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
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
                    self.handleUploadingPhoto(imageURL,image: selectedImage)
                }
                
            })
        }
        
    }

    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell = self.messageTableVIew.dequeueReusableCellWithIdentifier(cellId,forIndexPath: indexPath) as? MessageCell
    
    
    //var imgv:UIImageView?
    
    if cell == nil{
       cell = MessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        
        
    } else {
//         print("inner loop")
//        while(cell?.subviews.last != nil){
//            cell?.subviews.last?.removeFromSuperview()
//            print("logloglog")
//        }
    }
    
        //cell?.messagePhoto.image = nil
        //cell?.messagePhoto.frame = CGRectMake(0,0,0,0)
        cell?.myAccount = self.myAccount
    
    
        let index = indexPath.row
        cell?.message = messages[index]
        cell?.currentIndex = index
        cell?.textLabel?.font = UIFont(name: "Helvetica", size: 12)
    
        tableView.rowHeight = cell!.frame.height
        if ((cell?.message?.imageURL) != nil){
          cell?.messagePhoto.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(loadFullScreenPhoto)))
        }
    
        return cell!
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print("finish display:\(indexPath.row)")
        if self.messages.count>0{
            if indexPath.row == self.messages.count - 1 {
                let indexPath = NSIndexPath(forItem: self.messages.count - 1,inSection:0)
                self.messageTableVIew.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
 
}

