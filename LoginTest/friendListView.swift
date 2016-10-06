//
//  friendListView.swift
//  LoginTest
//
//  Created by yam7611 on 9/29/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Firebase

class friendListView: UITableViewController {
    
    let cellIdentifier = "CellId"
    var users = [User]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.whiteColor()

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        FIRDatabase.database().referenceFromURL("https://messagetest-4e61c.firebaseio.com/")
        checkIfUserIsLoggin()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"photo-camera (1)"),style:.Plain,target: self,action:#selector(handleCamera))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout", style: .Plain, target: self, action: #selector(handleLogout))
   
        fetchUser()
        
        //print(users.count)
    }
    
    func handleLogout(){
        
        print("you have log out,please sign out in FIREbase")
    }
    
    func handleCamera(){
        let CameraVC = CameraViewController()
        let navigationVC = UINavigationController(rootViewController: CameraVC)
        navigationVC.navigationBarHidden = true
        self.presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggin(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print ("user is not logging ")
        } else {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
          
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                //print(snapshot)
                
                if let dict = snapshot.value as? [String:AnyObject]{
                    self.navigationItem.title = dict["name"] as? String
                }
                
                }, withCancelBlock: nil)
                   }
    }
    
    
    
    
    func fetchUser(){
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            //print(snapshot)
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                
                let user = User()
                user.setValuesForKeysWithDictionary(dictionary)
                user.uid = snapshot.key
//                user.name = String(dictionary["name"])
//                user.email = String(dictionary["username"])
                self.users.append(user)
                //print(self.users.count)
                 //print(user.name,user.username)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
           
            }, withCancelBlock: nil)
        self.tableView.reloadData()
    }
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        
//        return users.count
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        
       //   cell.detailTextLabel?.text = users[indexPath.row].email
        cell.backgroundColor = UIColor.whiteColor()
        cell.detailTextLabel?.text = user.username
        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let messageVC = MessageViewController()
        
        var user = User()
        user = users[indexPath.row]
        
        
        messageVC.user = user
        
        let navigationVC = UINavigationController(rootViewController: messageVC)
        self.presentViewController(navigationVC, animated: true,completion: nil)
    }
    
    
    
}
