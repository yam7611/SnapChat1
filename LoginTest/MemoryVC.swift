//
//  MemoryVC.swift
//  LoginTest
//
//  Created by yam7611 on 10/18/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class MemoryVC: UIViewController,UIScrollViewDelegate,UIGestureRecognizerDelegate {
    
    
    let scView = UIScrollView()
    var imageFilePathArray = [NSURL]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(scView)
        initComponenet()
    }
    func initComponenet(){
        self.edgesForExtendedLayout = .None
        self.scView.contentSize = self.view.frame.size
        
        imageFilePathArray = fetchDocumentPath()
        scView.frame = self.view.frame
        scView.backgroundColor = UIColor.blueColor()
        self.edgesForExtendedLayout = .None
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(backFunciton))
        self.navigationItem.title = "memories"
        
        
        let numberOfRow = imageFilePathArray.count/5+1
        var counterOfLoadingImg = 0
        for i in 0...numberOfRow{
            
            for j in 0...4 {
                if counterOfLoadingImg < imageFilePathArray.count {
                let imgView = UIImageView()
                self.scView.addSubview(imgView)
                imgView.backgroundColor = UIColor.redColor()
                imgView.frame.size = CGSizeMake(self.view.frame.width/5,self.view.frame.height/5)
                imgView.frame.origin = CGPointMake(imgView.frame.width * CGFloat(j),imgView.frame.height * CGFloat(i) + 50)
                if let fileURL = NSData(contentsOfURL: imageFilePathArray[counterOfLoadingImg]){
                    let img = UIImage(data:fileURL)
                    imgView.image = img
                    
                    UIGraphicsBeginImageContextWithOptions(imgView.frame.size, false, 1.0)
                    img?.drawInRect(imgView.bounds)
                    let afterCompressedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    
                   imgView.image = afterCompressedImage
                    imgView.userInteractionEnabled = true
                    imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedImg)))
                    
                }
                counterOfLoadingImg += 1
                }
            }
            
        }
        self.scView.contentSize.height = self.view.frame.size.height/5 * CGFloat(imageFilePathArray.count/5+1)
         print(imageFilePathArray[0])
        
    }
    
    func tappedImg(tapGesture: UITapGestureRecognizer){
        
        if let tappedView = tapGesture.view as? UIImageView{
            if let image = tappedView.image{
                print(image)
            }
        }
    }
    
    func fetchDocumentPath() -> [NSURL] {
        
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentPath = paths[0]
        
        var array = [NSURL]()
        
        let fileManager = NSFileManager.defaultManager()
        let contentsOfPath = try? fileManager.contentsOfDirectoryAtPath(documentPath.path!)
        
        if let  pathImgArray = contentsOfPath as [String]?{
            
            for filePath in pathImgArray{
                if filePath.hasSuffix("jpeg") || filePath.hasSuffix("png"){
                    array.append(documentPath.URLByAppendingPathComponent(filePath))
                }
            }
        }

        return array
    }
    
    func backFunciton(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
