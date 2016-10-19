//
//  SendPhotoCell.swift
//  LoginTest
//
//  Created by yam7611 on 10/7/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class SendPhotoCell: UITableViewCell {
    
    
    var currentIndex:Int?{
        didSet{
            if currentIndex! == 0{
                self.frame.size.height = 60
                self.addSubview(titleLabel)
                self.titleLabel.text = "My story"
                //clickBtn.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor, constant: 10).active = true
                //self.titleLabel.hidden = false
            }
            else if currentIndex == 1 {
                self.frame.size.height = 60
                self.addSubview(titleLabel)
                self.titleLabel.text = "My Friend"
                //clickBtn.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor, constant: 10).active = true
                //self.titleLabel.hidden = false
            }else {
                self.frame.size.height = 40
                //self.titleLabel.hidden = true
                if self.subviews.contains(self.titleLabel){
                    self.titleLabel.removeFromSuperview()
                }
                usernameLabel.topAnchor.constraintEqualToAnchor(self.topAnchor,constant: 15).active = true
                usernameLabel.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 10).active = true
                
            }
            
//            if currentIndex <= list.count{
//                self.usernameLabel.text = list[indexPath.row]
//            }
            
        }
    }
    var username:String?{
        didSet{
            self.usernameLabel.text = username!
        }
    }
    
    
    var isChoosen:Bool? {
        didSet{
            if isChoosen! {
                clickBtn.setImage(UIImage(named:"selectedImage.png"), forState: .Normal)
                if let index = self.currentIndex {
                    NSNotificationCenter.defaultCenter().postNotificationName("selectUser", object: nil, userInfo: ["index":index])
                }
            } else {
                if let index = self.currentIndex {
                    NSNotificationCenter.defaultCenter().postNotificationName("deselectUser", object: nil, userInfo: ["index":index])
                }
                clickBtn.setImage(UIImage(named:"unselectedImage.png"), forState: .Normal)
            }
        }
        
    }
    
    let titleLabel :UILabel = {
        
        let tempLabel = UILabel()
        tempLabel.textColor = UIColor.init(red: 0, green: 153/255, blue: 1, alpha: 1)
        tempLabel.font = UIFont.systemFontOfSize(20)
        return tempLabel
    }()
    
    let usernameLabel :UILabel = {
        let tempLabel = UILabel()
        tempLabel.font = UIFont.systemFontOfSize(15)
        
        return tempLabel
    }()
    
    let clickBtn :UIButton = {
        let tempBtn = UIButton()
        
        
        return tempBtn
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
       
        
        
        self.addSubview(usernameLabel)
        self.addSubview(clickBtn)
        setUpComponent()
    }
    
    func setUpComponent(){
        self.currentIndex = 0
        isChoosen = false
        self.clipsToBounds = true
        self.frame.size.height = 50
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 5).active = true
        titleLabel.bottomAnchor.constraintEqualToAnchor(usernameLabel.topAnchor,constant: -5).active = true
        titleLabel.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 10).active = true
        titleLabel.widthAnchor.constraintEqualToConstant(150).active = true
        titleLabel.heightAnchor.constraintEqualToConstant(25).active = true
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel.leftAnchor.constraintEqualToAnchor(titleLabel.leftAnchor).active = true
        usernameLabel.widthAnchor.constraintEqualToConstant(200).active = true
        usernameLabel.heightAnchor.constraintEqualToConstant(20).active = true
        //usernameLabel.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor,constant: -5).active = true
        
        clickBtn.translatesAutoresizingMaskIntoConstraints = false
        clickBtn.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        clickBtn.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -10).active = true
        clickBtn.widthAnchor.constraintEqualToConstant(40).active = true
        clickBtn.heightAnchor.constraintEqualToConstant(40).active = true
        
        //titleLabel.backgroundColor = UIColor.cyanColor()
        //usernameLabel.backgroundColor = UIColor.brownColor()
        //clickBtn.backgroundColor = UIColor.cyanColor()
        
        clickBtn.addTarget(self, action: #selector(pressedBtn), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func pressedBtn(){
        
        isChoosen = !isChoosen!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        self.titleLabel.frame.size = CGSizeMake(100,40)
//        self.usernameLabel.frame.size = CGSizeMake(150,40)
//    }
}
