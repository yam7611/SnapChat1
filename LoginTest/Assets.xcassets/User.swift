//
//  User.swift
//  LoginTest
//
//  Created by yam7611 on 9/30/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit


class User:NSObject{
    
    var name : String?
    var username: String?
    var uid : String?
    var interests:[String:NSNumber]?
    var subscriptions:[String:[String:NSNumber]?]?
    var friends:[String:AnyObject]?
    var friendDict = [String:String]()
    
    init(dictionary:[String:AnyObject],uid:String){
        
        super.init()
        self.uid = uid
        self.name = dictionary["name"] as? String
        self.username = dictionary["username"] as? String
        self.interests = dictionary["interest"] as? [String:NSNumber]
        self.subscriptions = dictionary["subscription"] as? [String:[String:NSNumber]?]
        self.friends = dictionary["friends"] as? [String:AnyObject]
        
        if let friendsValue = friends{
            for friend in friendsValue{

                let friendId = friend.0
                let friendData = friend.1
                if let relation = friendData["status"] as? String{
                    friendDict["\(friendId)"] = relation
                }
                
            }
        }
        
        for friend in friendDict{
            print("\(self.name)'s friendList: \(friend.0),\(friend.1)")
        }
    }
    
 
}
