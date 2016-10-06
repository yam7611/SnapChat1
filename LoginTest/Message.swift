//
//  Message.swift
//  LoginTest
//
//  Created by yam7611 on 10/3/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {

    var fromId :String?
    var text:String?
    var timestamp:NSNumber?
    var toId:String?
    var imageURL:String?
    
    var imageHeight:NSNumber?
    var imageWidth:NSNumber?
    var imageLifeTime:NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId :fromId
    }
    
    
    init(dictionary:[String:AnyObject]){
        super.init()
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.toId = dictionary["toId"] as? String
        self.imageURL = dictionary["imageURL"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.imageLifeTime = dictionary["imageLifeTime"] as? NSNumber
        
        
    }
    
}
