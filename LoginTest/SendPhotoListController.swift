//
//  SendPhotoListController.swift
//  LoginTest
//
//  Created by yam7611 on 10/7/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

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
    
    var receiver = [String:String]()
    let cellId = "Cell"
    var list = [String]()
    var users = [String:User]()
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
    }
    
    
    
    func setUpComponent(){
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(backToCameraView))
        
        listView.registerClass(SendPhotoCell.self,forCellReuseIdentifier: cellId)
        listView.allowsSelection = false
        self.view.backgroundColor = UIColor.redColor()
        self.listView.delegate = self
        self.listView.dataSource = self
        
        //self.listView.allowsMultipleSelection = true
        
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
     
        fetchFriendListFromServer()
    }
    func fetchFriendListFromServer(){
        list.append("Dav")
        list.append("David Huang")
        list.append("Tiffany")
        list.append("Jack")
    }
    
    func sendPhoto(){
        print("send out!")
    }
    
    func putUserToList(notification:NSNotification){
        if let userInfo = notification.userInfo{
            if let data = userInfo["index"] as? Int{
                self.receiver[list[data]] = "123"
                print(" recevier count:\(receiver.count)")
                if self.receiver.count > 0 {
                //show sned btn
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
                self.receiver.removeValueForKey(list[data])
                print(" recevier count:\(receiver.count)")
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
    
    
    func backToCameraView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //////////////// this part is start of UITableView deleate and data source method///////////////////////
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        
        var cell = listView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as? SendPhotoCell
        //cell.textLabel?.textColor = UIColor.init(red: 0, green: 153/255, blue: 1, alpha: 1)
        
        
            //cell? = SendPhotoCell(style: .Default, reuseIdentifier: cellId)
            cell?.currentIndex = indexPath.row
            listView.rowHeight = cell!.frame.height
            cell?.username = list[indexPath.row]
        
 
       //print(list[indexPath.row])
        
        print(listView.rowHeight)
        //rgb(0, 153, 255)
        
        
        return cell!
    }
    
   
    
    //////////////// this part is end of UITableView deleate and data source method///////////////////////
}
