//
//  CustomCell.swift
//  LoginTest
//
//  Created by yam7611 on 10/4/16.
//  Copyright © 2016 yam7611. All rights reserved.
//


//  ver 2.11wwww

import UIKit
import Firebase

class MessageCell: UITableViewCell {

    var currentIndex:Int?
    let subtitleLabel = UILabel()
    let detailLabel : UILabel = {
        let tempLabel = UILabel()
        
        return tempLabel
    
    }()
    let timestampLabel: UILabel={
        let tempLabel = UILabel()
        tempLabel.textColor = UIColor.lightGrayColor()
        tempLabel.font = UIFont.systemFontOfSize(12)
        return tempLabel
    }()
    var myAccount = ""
    let messagePhoto :UIImageView = {
        let tempImageView = UIImageView()
        tempImageView.layer.cornerRadius = 10
        tempImageView.layer.masksToBounds = true
        tempImageView.contentMode = .ScaleAspectFill
        return tempImageView
        
    }()
    
    
    let spiner :UIActivityIndicatorView = {
        let tempSpiner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White )
        return tempSpiner
    }()
    var timer : NSTimer?
    
    
    var message: Message?{
        didSet{
            
            if message?.fromId == myAccount{
                self.subtitleLabel.text = "Me:"
                self.subtitleLabel.textColor = UIColor.redColor()
            } else {
                let uid = message?.fromId
                let ref = FIRDatabase.database().reference().child("users").child(uid!)
                ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    let dictionary =  snapshot.value as! [String:AnyObject]
                    self.subtitleLabel.text = dictionary["name"] as? String
                    }, withCancelBlock: nil)
                self.subtitleLabel.textColor = UIColor.blueColor()
                
            }
            self.frame.size.height = 60
            self.setUpComponent()
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle,reuseIdentifier:reuseIdentifier)
        //currentIndex = 0
        
        //make sure subview doesn't displays over cell
        self.clipsToBounds = true
        self.addSubview(subtitleLabel)
        
        self.addSubview(timestampLabel)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(checkLoadingPhoto), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func checkLoadingPhoto(){
        if self.messagePhoto.image != nil{
            self.spiner.removeFromSuperview()
            self.spiner.stopAnimating()
            timer?.invalidate()
        }
    }
    
    func setUpComponent(){
        
        setCellFrameSizeAccordingToMessageType()
        
        // loading message timestamp to timeLabel
        if let seconds = message?.timestamp?.doubleValue {
            let timestamp = NSDate(timeIntervalSince1970: seconds)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY/MM/dd/hh:mm a"
            self.timestampLabel.text = dateFormatter.stringFromDate(timestamp)
        }
    }
    
    func setCellFrameSizeAccordingToMessageType(){
        if let imageURLmessage = message?.imageURL{
            // set frame height for displaying image
            self.addSubview(messagePhoto)
            if let imageWidth = message?.imageWidth{
                if imageWidth.doubleValue > 150{
                    let newHeight = 150 * (message?.imageHeight)!.doubleValue / imageWidth.doubleValue
                    self.messagePhoto.frame = CGRectMake(0,0,150,CGFloat(newHeight))
                    
                    //print("cell Height:\(newHeight)")
                } else {
                    
                    self.messagePhoto.frame = CGRectMake(0,0,CGFloat(imageWidth),CGFloat((message?.imageHeight)!))
                }
                self.messagePhoto.frame.origin.x = 5
                self.messagePhoto.frame.origin.y = self.subtitleLabel.frame.height + 10
                self.frame.size.height += messagePhoto.frame.height - 10
                
                if messagePhoto.image == nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        //print("go spin!")
                        print(self.message?.imageHeight)
                        self.messagePhoto.backgroundColor = UIColor.grayColor()
                        self.messagePhoto.addSubview(self.spiner)
                        self.spiner.frame.size = CGSize(width: 30,height: 30)
                        self.spiner.center = CGPointMake(self.messagePhoto.frame.width/2,self.messagePhoto.frame.height/2)
                        
                        self.spiner.startAnimating()
                        
                    })
                }
                self.messagePhoto.userInteractionEnabled = true
            }
            
            self.messagePhoto.loadImageUsingCacheWithUrlString(imageURLmessage)
            
            self.detailLabel.frame = CGRectMake(0,0,0,0)
            
        } else {
            // set frame height for displaying text
            
            //self.messagePhoto.image = nil
            self.addSubview(detailLabel)
            detailLabel.frame = CGRectMake(5,30,350,20)
            self.messagePhoto.frame  = CGRectMake(0,0,0,0)
            self.frame.size.height = 60
            self.detailLabel.text = message?.text
        }

    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        subtitleLabel.frame = CGRectMake(5,5,200,20)
        
        timestampLabel.frame = CGRectMake(self.frame.width - 150, 5,175,40)
    }
    
}