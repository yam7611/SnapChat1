//
//  Story.swift
//  LoginTest
//
//  Created by yam7611 on 10/17/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class Story: NSObject {
    var time: NSNumber?
    var userId: String?
    var photoURL:String?
    
    
    init(dictionary:[String:AnyObject]){
        super.init()
        self.time =  dictionary["time"] as? NSNumber
        self.userId = dictionary["userId"] as? String
        self.photoURL = dictionary["photoURL"] as? String
        
    }
}
