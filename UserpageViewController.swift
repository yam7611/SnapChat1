//
//  UserpageViewController.swift
//  LoginTest
//
//  Created by yam7611 on 10/18/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Firebase
class UserpageViewController: UIViewController {

    
    let uid = FIRAuth.auth()?.currentUser?.uid
    var codeImg :CIImage?
    let snapcodeImgv:UIImageView? = {
    
        let tempimgv = UIImageView()
        tempimgv.backgroundColor = UIColor.redColor()
        tempimgv.image = UIImage()
        tempimgv.frame.size = CGSizeMake(160,160)
        tempimgv.frame.origin = CGPointMake(90,90)
        return tempimgv
    }()
    
    let myFriendBtn:UIButton = {
        
        let tempBtn = UIButton()
        tempBtn.setTitle("my friend", forState: .Normal)
        tempBtn.backgroundColor = UIColor.redColor()
        tempBtn.frame.size = CGSizeMake(150,40)
        return tempBtn
    }()
    
    let addFriendBtn:UIButton = {
        
        let tempBtn = UIButton()
        tempBtn.setTitle("add friend", forState: .Normal)
        tempBtn.backgroundColor = UIColor.redColor()
        tempBtn.frame.size = CGSizeMake(150,40)
        
        return tempBtn
    }()
    
    let addMeBtn:UIButton = {
        
        let tempBtn = UIButton()
        tempBtn.setTitle("added me", forState: .Normal)
        tempBtn.backgroundColor = UIColor.redColor()
        tempBtn.frame.size = CGSizeMake(150,40)
        return tempBtn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.snapcodeImgv!)
        self.view.addSubview(self.addMeBtn)
        self.view.addSubview(self.myFriendBtn)
        self.view.addSubview(self.addFriendBtn)
        initComponent()
        
    }
    func initComponent(){
        
        self.edgesForExtendedLayout = .None
        if let code = uid{
            let encodedCode = code.dataUsingEncoding( NSUTF8StringEncoding, allowLossyConversion: false)
            let filter = CIFilter(name:"CIQRCodeGenerator")
            filter?.setValue(encodedCode, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            codeImg  = filter?.outputImage
            snapcodeImgv?.image? = UIImage(CIImage:codeImg!)
        }
        
        snapcodeImgv?.translatesAutoresizingMaskIntoConstraints = false
        snapcodeImgv?.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        snapcodeImgv?.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant: 60).active = true
        snapcodeImgv?.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 1/4).active = true

        snapcodeImgv?.heightAnchor.constraintEqualToAnchor(snapcodeImgv?.widthAnchor).active = true
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "add Friend", style: .Plain, target: self, action: #selector(backToAddFriend))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "friend list", style: .Plain, target: self, action: #selector(goFriendPage))
        self.navigationItem.title = "User page"
        
        addMeBtn.translatesAutoresizingMaskIntoConstraints = false
        addMeBtn.topAnchor.constraintEqualToAnchor(snapcodeImgv!.bottomAnchor,constant: 50).active = true
        addMeBtn.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        
        addFriendBtn.translatesAutoresizingMaskIntoConstraints = false
        addFriendBtn.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        addFriendBtn.topAnchor.constraintEqualToAnchor(addMeBtn.bottomAnchor,constant: 50).active = true
        
        myFriendBtn.translatesAutoresizingMaskIntoConstraints = false
        myFriendBtn.topAnchor.constraintEqualToAnchor(addFriendBtn.bottomAnchor,constant: 50).active = true
        myFriendBtn.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        
        
        
        
        myFriendBtn.addTarget(self, action: #selector(goFriendPage), forControlEvents: .TouchUpInside)
        
        addFriendBtn.addTarget(self, action: #selector(backToAddFriend), forControlEvents: .TouchUpInside)
        addMeBtn.addTarget(self, action: #selector(tapAddedFriendBtn), forControlEvents: .TouchUpInside)
        
        
        
    }
    
    
    func backToAddFriend(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goFriendPage(){
        let friendLtVC = friendListView()
        let naviVC = UINavigationController(rootViewController: friendLtVC)
        self.presentViewController(naviVC, animated: true, completion: nil)
    }
    
    func tapAddedFriendBtn(){
        let addMeVC = AddedMeVC()
        let naviVC = UINavigationController(rootViewController: addMeVC)
        self.presentViewController(naviVC, animated: true, completion: nil)
        
        print("tapAddedFriendBtn")
    }
    
    
}
