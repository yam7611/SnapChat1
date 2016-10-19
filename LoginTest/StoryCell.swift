//
//  StoryCell.swift
//  LoginTest
//
//  Created by yam7611 on 10/17/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit



class StoryCell: UITableViewCell {
    let cellId = "cellId"
    
    
    var story:Story?{
        didSet{
            //self.imageV.image = nil
            //self.timingLb.text = ""
            //self.nameLb.text = ""
            
            
            if let imgURL = story?.photoURL{
                self.imageV.loadImageUsingCacheWithUrlString(imgURL)
            }
            if let seconds = story?.time?.doubleValue {
                let timestamp = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "YYYY/MM/dd/hh:mm a"
                self.timingLb.text = dateFormatter.stringFromDate(timestamp)
            }
        }
    }
    
    let nameLb : UILabel = {
        let tempLabel = UILabel()
        tempLabel.text = ""
        tempLabel.frame.size = CGSizeMake(120,40)
        //tempLabel.backgroundColor = UIColor.redColor()
        
        return tempLabel
        
    }()
    
    let spiner = UIActivityIndicatorView()
    var timerForCheckingSpinner = NSTimer()
    let timingLb:UILabel = {
    
        let tempLabel = UILabel()
        //tempLabel.backgroundColor = UIColor.purpleColor()
        tempLabel.frame.size = CGSizeMake(150,40)
        return tempLabel
    }()
    
    
    let imageV : UIImageView = {
        let imgV = UIImageView()
        imgV.layer.cornerRadius = 20
        imgV.layer.masksToBounds = true
        imgV.frame.size = CGSizeMake(40,40)
        imgV.backgroundColor = UIColor.grayColor()
        return imgV
        
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:.Default,reuseIdentifier:cellId)
        
        self.addSubview(imageV)
        self.addSubview(nameLb)
        self.addSubview(timingLb)
        self.addSubview(spiner)
        setupComponent()
    }
    
    func setupComponent(){
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 10).active = true
        imageV.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        imageV.heightAnchor.constraintEqualToConstant(40).active = true
        imageV.widthAnchor.constraintEqualToConstant(40).active = true
        
        nameLb.translatesAutoresizingMaskIntoConstraints = false
        
        nameLb.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        nameLb.heightAnchor.constraintEqualToConstant(40).active = true
        nameLb.widthAnchor.constraintEqualToConstant(120).active = true
        nameLb.leftAnchor.constraintEqualToAnchor(imageV.rightAnchor, constant: 10).active = true
        
        timingLb.translatesAutoresizingMaskIntoConstraints = false
        timingLb.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -10).active = true
        timingLb.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        timingLb.widthAnchor.constraintEqualToConstant(170).active = true
        timingLb.heightAnchor.constraintEqualToConstant(40).active = true
        
        spiner.translatesAutoresizingMaskIntoConstraints = false
        spiner.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        spiner.centerXAnchor.constraintEqualToAnchor(imageV.centerXAnchor).active = true
        spiner.widthAnchor.constraintEqualToConstant(25).active = true
        spiner.heightAnchor.constraintEqualToConstant(25).active = true
        
        dispatch_async(dispatch_get_main_queue()) {
            self.spiner.startAnimating()
            self.timerForCheckingSpinner = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(self.checkLoading), userInfo: nil, repeats: true)
        }
        
        
    }
    func checkLoading(){
        if self.imageV.image != nil {
            self.timerForCheckingSpinner.invalidate()
            self.spiner.stopAnimating()
            
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
