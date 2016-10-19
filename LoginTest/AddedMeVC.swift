//
//  AddedMeVC.swift
//  LoginTest
//
//  Created by yam7611 on 10/18/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Firebase

class AddedMeVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var resultList = [String]()
    var userIdArray = [String]()
    let CellId = "cellId"
    let addMeTableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.addMeTableView)
        initComponent()
    }
    
    func initComponent(){
        self.edgesForExtendedLayout = .None
        addMeTableView.delegate = self
        addMeTableView.dataSource = self
        self.navigationItem.title =  "added Me"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "user page", style: .Plain, target: self, action: #selector(backToUserPage))
        
        
        self.addMeTableView.translatesAutoresizingMaskIntoConstraints = false
        self.addMeTableView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        self.addMeTableView.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
        self.addMeTableView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        self.addMeTableView.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor).active = true
        
        fetchListFromServer()
    }
    func fetchListFromServer(){
        
        if let uid = FIRAuth.auth()?.currentUser?.uid{
        
        
        FIRDatabase.database().reference().child("users").child("\(uid)").child("friends").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            
            if let dicionary = snapshot.value as? [String:AnyObject]{
            
                
                
                if let status = dicionary["status"] as? String{
                    print(status)
                    if status == "wait accepted"{
                        
                        if let fromId = snapshot.key as? String{
                           
                            FIRDatabase.database().reference().child("users").child("\(fromId)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                
                                if let innerDictioanry = snapshot.value as? [String:AnyObject]{
                                    if let username = innerDictioanry["username"] as? String{
                                        self.resultList.append(username)
                                        self.userIdArray.append(fromId)
                                        self.addMeTableView.reloadData()
                                    }
                                    
                                }
                            })
                            
                            
                            
                        }
                    }
                    
                }
            }
            
            }, withCancelBlock: nil)
        }

    }
    
    
    func backToUserPage(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: CellId)
        
        
        cell.textLabel?.text = resultList[indexPath.row]
        print(userIdArray[indexPath.row])
        print(resultList[indexPath.row])
     
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let toId = userIdArray[indexPath.row]
        
        if let uid = FIRAuth.auth()?.currentUser?.uid{
            FIRDatabase.database().reference().child("users").child("\(uid)").child("friends").child("\(toId)").updateChildValues(["status":"mutual"])
            
            FIRDatabase.database().reference().child("users").child("\(toId)").child("friends").child("\(uid)").updateChildValues(["status":"mutual"])
        }
        
        userIdArray.removeAtIndex(indexPath.row)
        resultList.removeAtIndex(indexPath.row)
        
        self.addMeTableView.reloadData()
        
    }
}
