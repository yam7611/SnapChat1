//
//  AddFriendViewController.swift
//  LoginTest
//
//  Created by yam7611 on 10/18/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    let methodTableView = UITableView()
    let cellId = "cellId"
    let optionForAddingFriend = ["By username","search nearby","snapcode"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(methodTableView)
        initComponent()
    }
    func initComponent(){
        self.methodTableView.delegate =  self
        self.methodTableView.dataSource = self
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "stories", style: .Plain, target: self, action: #selector(backToStories))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "User page", style: .Plain, target: self, action: #selector(goUserPage))
        
        self.navigationItem.title = "add friend"
        
        self.methodTableView.translatesAutoresizingMaskIntoConstraints = false
        self.methodTableView.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
         self.methodTableView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        self.methodTableView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        self.methodTableView.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor).active = true
        
        
        
    }
    func backToStories(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func goUserPage(){
        let userPageVC = UserpageViewController()
        let naviVC = UINavigationController(rootViewController: userPageVC)
        self.presentViewController(naviVC, animated: true, completion: nil)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
        
        cell.textLabel?.text = optionForAddingFriend[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0{
          launchAddByUsernameVC()
        } else if indexPath.row == 1{
            
        } else {
            launchAddByCodeVC()
        }
    }
    
    func launchAddByUsernameVC(){
        let addByIdVC = addByUsernameVC()
        let naviVC = UINavigationController(rootViewController: addByIdVC)
        self.presentViewController(naviVC, animated: true, completion: nil)
        
    }
    
    func launchAddByCodeVC(){
        let addByCodeVC = AddFriendByCode()
        let naviVC = UINavigationController(rootViewController: addByCodeVC)
        self.presentViewController(naviVC, animated: true, completion: nil)
        
    }

    
    
}
