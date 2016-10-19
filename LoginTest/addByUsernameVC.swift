//
//  addByUsernameVC.swift
//  LoginTest
//
//  Created by yam7611 on 10/18/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Firebase
class addByUsernameVC: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    var sendReqId = ""
    var resultArray = [String]()
    let searchBar: UITextField = {
    
        let tempLabel = UITextField()
        tempLabel.placeholder = "Please type username here"
        
        
        return tempLabel
    }()
    
    let resultTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.addSubview(searchBar)
        self.view.addSubview(resultTableView)
        initComponent()
    }
    
    func initComponent(){
        
        self.edgesForExtendedLayout = .None
        self.resultTableView.delegate = self
        self.searchBar.delegate = self
        self.resultTableView.dataSource = self
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "add friend", style: .Plain, target: self, action: #selector(backToAddFriend))
        self.navigationItem.title = "add by email address"
        
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.searchBar.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.searchBar.heightAnchor.constraintEqualToConstant(50)
        self.searchBar.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        
        self.resultTableView.translatesAutoresizingMaskIntoConstraints = false
        self.resultTableView.topAnchor.constraintEqualToAnchor(self.searchBar.bottomAnchor).active = true
        self.resultTableView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        self.resultTableView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        
        
        searchBar.addTarget(self, action: #selector(searchOnDatabase(_:)), forControlEvents: .EditingChanged)
        
    }
    
    func searchOnDatabase(textField:UITextField){
       // print(textField.text)
        //print("changed!!")
        
        if let text = textField.text{
            if text != ""{
                searchOnServer(text)
            } else {
                resultArray.removeAll()
            }
            
        }
        
    }
    
    func searchOnServer(uId:String){
      
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            //print(snapshot)
            if let dictionay = snapshot.value as? [String:AnyObject]{
                if let username = dictionay["username"] as? String{
                    //print(username)
                    if username == uId{
                        self.resultArray.append(username)
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.resultTableView.reloadData()
                            print("reloadData")
                        })
                        
                        print(self.resultArray[0])
                    }
                }
                
                }
            }, withCancelBlock: nil)
        
    }
    func backToAddFriend(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cellId")
        if resultArray.count != 0{
             cell.textLabel?.text = resultArray[indexPath.row]
        }
       
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //let relationshipId = NSUUID().UUIDString
 
        if let username = cell?.textLabel?.text{
            FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                if let user = snapshot.value as? [String:AnyObject] {
                    if let usernameFromDB = user["username"] as? String {
                        if usernameFromDB == username {
                           
                            if let uid = FIRAuth.auth()?.currentUser?.uid{
                                FIRDatabase.database().reference().child("users").child("\(uid)").child("friends").child("\(snapshot.key)").updateChildValues(["status":"request sent"])
                                
                                FIRDatabase.database().reference().child("users").child("\(snapshot.key)").child("friends").child("\(uid)").updateChildValues(["status":"wait accepted"])
                                
                            }
                        }
                    }
                }
                
                }, withCancelBlock: nil)
            
            
           
            print(username)
        }
        
        
    }
    
    
}
