//
//  NewMemoryVC.swift
//  LoginTest
//
//  Created by yam7611 on 10/19/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Photos

class NewMemoryVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate{
    
    let photoCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(100,100)
        let tempCollectionView = UICollectionView(frame: CGRectZero,collectionViewLayout: layout)
        return tempCollectionView
    }()
    
    var suffixArray = [String]()
    lazy var optionsBtn : UISegmentedControl = {
        let tempSC = UISegmentedControl(items:["memory","camera row","Private"])
        tempSC.selectedSegmentIndex = 0
        tempSC.translatesAutoresizingMaskIntoConstraints = false
        tempSC.addTarget(self, action: #selector(changeSource), forControlEvents: .ValueChanged)
        return tempSC
    }()
    
    var selectedIndex = 0
    
    let fullScreenImgV = UIImageView()
    
    lazy var lockBtn :UIButton = {
        let tempBtn = UIButton()
        tempBtn.setTitle("Lock", forState: .Normal)
        tempBtn.addTarget(self, action: #selector(lock), forControlEvents: .TouchUpInside)
        
        tempBtn.translatesAutoresizingMaskIntoConstraints = false
        tempBtn.layer.cornerRadius = 5
        tempBtn.layer.masksToBounds = true
        tempBtn.backgroundColor = UIColor.init(red: 204/255, green: 0, blue: 0, alpha: 0.7)
        return tempBtn
    }()
    
    lazy var socialShareBtn :UIButton = {
        let tempBtn = UIButton()
        tempBtn.setTitle("social share", forState: .Normal)
        tempBtn.addTarget(self, action: #selector(share), forControlEvents: .TouchUpInside)
        
        tempBtn.translatesAutoresizingMaskIntoConstraints = false
        tempBtn.layer.cornerRadius = 5
        tempBtn.layer.masksToBounds = true
        tempBtn.backgroundColor = UIColor.init(red: 51/255, green: 153/255, blue: 1, alpha: 0.7)
        return tempBtn
    }()
    
    lazy var closeBtn :UIButton = {
        let tempBtn = UIButton()
        tempBtn.layer.cornerRadius = 15
        tempBtn.layer.masksToBounds = true
        tempBtn.setImage(UIImage(named:"cancel.png"), forState: .Normal)
        tempBtn.addTarget(self, action: #selector(close), forControlEvents: .TouchUpInside)
        
        tempBtn.translatesAutoresizingMaskIntoConstraints = false
        tempBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        return tempBtn
    }()
    
    lazy var deleteBtn :UIButton = {
        let tempBtn = UIButton()
        tempBtn.layer.cornerRadius = 5
        tempBtn.layer.masksToBounds = true
        tempBtn.setTitle("delete", forState: .Normal)
        tempBtn.addTarget(self, action: #selector(delete), forControlEvents: .TouchUpInside)
        
        tempBtn.translatesAutoresizingMaskIntoConstraints = false
        tempBtn.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.8)
        return tempBtn
    }()

    
    var URLArrayFromMemory = [NSURL]()
    var URLArrayFromPrivateFolder = [NSURL]()
    
    var sourceImgArray = [UIImage]()
    let PassFilePath = NSHomeDirectory() + "/Documents/privateAlbumKey.txt"
    let docuemtDirectory = NSHomeDirectory() + "/Documents"
    var imgArrayFromPrivate = [UIImage]()
    let optionBtnView = UIView()
    var imageArray = [UIImage]()
    var imgArrayFromMemories = [UIImage]()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(photoCollectionView)
        self.view.addSubview(optionBtnView)
        self.view.addSubview(optionsBtn)
        initComponent()
        //loadFromMemory()
    }
    
    let askPasswordView = UIView()
    let askInputbox = UITextField()
    let askAgainInputbox = UITextField()
    let sendBtn = UIButton()
    
    func initComponent(){
        
        checkPrivateDirectory()
        
        photoCollectionView.delegate   = self
        photoCollectionView.dataSource = self
        
        photoCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "new memory"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .Plain, target: self, action: #selector(backToCamera))
        self.edgesForExtendedLayout = .None
        
        photoCollectionView.backgroundView = UIView()
        
        optionBtnView.translatesAutoresizingMaskIntoConstraints = false
        optionBtnView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        optionBtnView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        optionBtnView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        optionBtnView.heightAnchor.constraintEqualToConstant(50).active = true
        
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.topAnchor.constraintEqualToAnchor(optionBtnView.bottomAnchor).active = true
        photoCollectionView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        photoCollectionView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        photoCollectionView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
       
        optionsBtn.topAnchor.constraintEqualToAnchor(self.view.topAnchor,constant: 10).active = true
        optionsBtn.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        optionsBtn.heightAnchor.constraintEqualToConstant(30).active = true
        optionsBtn.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor,multiplier:0.8).active = true

        changeSource()
    }
    
    func changeSource(){
        removePrivateView()
        let title = optionsBtn.titleForSegmentAtIndex(optionsBtn.selectedSegmentIndex)
        if title == "camera row" {
            
            if imageArray.count == 0{
                
                loadPhoto()
                dispatch_async(dispatch_get_main_queue(), {
                    self.sourceImgArray = self.imageArray
                    self.photoCollectionView.reloadData()
                })
            } else {
                
                self.sourceImgArray = self.imageArray
                self.photoCollectionView.reloadData()
            
            }
           
        } else if title == "memory" {
            
            if imgArrayFromMemories.count == 0{
                loadFromMemory()
                dispatch_async(dispatch_get_main_queue(), {
                    self.sourceImgArray = self.imgArrayFromMemories
                    self.photoCollectionView.reloadData()
                })
                
            } else {
                sourceImgArray = imgArrayFromMemories
                photoCollectionView.reloadData()
            }
        } else {
            
            if !checkIfHasPass(false){
                // will ask to set pass
                
              
                self.view.addSubview(askPasswordView)
                askPasswordView.addSubview(askInputbox)
                askPasswordView.addSubview(askAgainInputbox)
                askPasswordView.addSubview(sendBtn)
                
                askPasswordView.frame = CGRectMake(0,50,self.view.frame.width,self.view.frame.height)
                askPasswordView.backgroundColor = UIColor.redColor()
                
                askInputbox.frame = CGRectMake(10,10,180,40)
                askInputbox.backgroundColor = UIColor.whiteColor()
                askInputbox.placeholder = "type password"
                
                askAgainInputbox.frame = CGRectMake(10,55,180,40)
                askAgainInputbox.backgroundColor = UIColor.whiteColor()
                askAgainInputbox.placeholder = "type password"
                
                sendBtn.frame = CGRectMake(200,55,180,40)
                sendBtn.setTitle("send", forState: .Normal)
                sendBtn.addTarget(self, action: #selector(tapSetPassword), forControlEvents: .TouchUpInside)
                
            } else {
                //ask for password
                
                self.view.addSubview(askPasswordView)
                askPasswordView.addSubview(askInputbox)
                askPasswordView.addSubview(sendBtn)
                
                askPasswordView.frame = CGRectMake(0,50,self.view.frame.width,self.view.frame.height)
                askPasswordView.backgroundColor = UIColor.redColor()
                
                askInputbox.frame = CGRectMake(10,10,180,40)
                askInputbox.backgroundColor = UIColor.whiteColor()
                askInputbox.placeholder = "type password"
                askInputbox.text = ""
                
                sendBtn.frame = CGRectMake(200,55,180,40)
                sendBtn.setTitle("send", forState: .Normal)
                sendBtn.addTarget(self, action: #selector(tapSendPassword), forControlEvents: .TouchUpInside)
                
            }
        }
        
    }
    
    
    func tapSetPassword(){
        if askInputbox.text == askAgainInputbox.text{
            let password = askInputbox.text
             let suc = try? password?.writeToFile(PassFilePath, atomically: true, encoding: NSUTF8StringEncoding)
            
            if (suc != nil) {
                print("suc to write pass")
            } else {
                print("fail to write pass")
            }
        }
    }
    
    func removePrivateView(){
        askPasswordView.removeFromSuperview()
        askInputbox.removeFromSuperview()
        sendBtn.removeFromSuperview()
    
    }
    
    func tapSendPassword(){
        
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
         let documentPath = paths[0].URLByAppendingPathComponent("privateAlbumKey.txt")
        
        let readHandler = try? NSFileHandle(forReadingFromURL: documentPath)
        
        let data = readHandler?.readDataToEndOfFile()
        
        let readString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        if let password = readString{
            if password == askInputbox.text!{
                removePrivateView()
                
                loadPhotoFromPrivateFolder()
            }
        }
        
    }
    
    func loadPhotoFromPrivateFolder(){
        imgArrayFromPrivate.removeAll()
        URLArrayFromPrivateFolder.removeAll()
        // check if private thumb folder exist
        let fileMng = NSFileManager.defaultManager()
        let filePath = NSHomeDirectory() + "/Documents/private/thumbs"
        let exsit = fileMng.fileExistsAtPath(filePath)
        
        if !exsit{
            _ = try? fileMng.createDirectoryAtPath(filePath, withIntermediateDirectories: true, attributes: nil)
            
        }
        
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentPath = paths[0].URLByAppendingPathComponent("private/thumbs")
        
        let fileManager = NSFileManager.defaultManager()
        let contentsOfPath = try? fileManager.contentsOfDirectoryAtPath(documentPath.path!)
        
        
        
        if let  pathImgArray = contentsOfPath as [String]?{
            
            for filePath in pathImgArray{
                URLArrayFromPrivateFolder.append(documentPath.URLByAppendingPathComponent(filePath))
                
            }
        }
        
        
        if URLArrayFromPrivateFolder.count > 0 {
            for i in 0..<URLArrayFromPrivateFolder.count{
                let letImgData = NSData(contentsOfURL: URLArrayFromPrivateFolder[i])
                let img = UIImage(data: letImgData!)
                
                imgArrayFromPrivate.append(img!)
            }
        } else {
            print("no pic in private thumbs")
        }
        sourceImgArray = imgArrayFromPrivate
        photoCollectionView.reloadData()
        
    }
    
    func loadFromMemory(){
        
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentPath = paths[0].URLByAppendingPathComponent("thumbs")
        
        
        
        let fileManager = NSFileManager.defaultManager()
        let contentsOfPath = try? fileManager.contentsOfDirectoryAtPath(documentPath.path!)
        
        if let  pathImgArray = contentsOfPath as [String]?{
            
            for filePath in pathImgArray{
                URLArrayFromMemory.append(documentPath.URLByAppendingPathComponent(filePath))
                suffixArray.append(filePath)
            }
        }
        
        
        if URLArrayFromMemory.count > 0 {
        for i in 0..<URLArrayFromMemory.count{
            let letImgData = NSData(contentsOfURL: URLArrayFromMemory[i])
            let img = UIImage(data: letImgData!)
            
                imgArrayFromMemories.append(img!)
            }
        }
        
    }
    
    func checkIfHasPass(ifCreate:Bool) -> Bool{
        let fileMng = NSFileManager.defaultManager()
        
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentPath = paths[0].URLByAppendingPathComponent("privateAlbumKey.txt")
        
        //let tempPath =  paths[0].URLByAppendingPathComponent("privateAlbumKey.txt")
        
        
        let exsit = fileMng.fileExistsAtPath(documentPath.path!)
        
        
        
        if !exsit && ifCreate{
            print("going to create file path\(documentPath)")
            let data = NSData(base64EncodedString: "aGVsbG8gd29ybGQ=", options: .IgnoreUnknownCharacters )
            _ = try? fileMng.createFileAtPath(documentPath.path!, contents: data, attributes: nil)
            return true
        } else if !exsit {
            return false
        }
//        _ = try? fileMng.removeItemAtURL(documentPath)
//        _ = try? fileMng.removeItemAtURL(tempPath)
//        
        print("found file path\(documentPath)")

        return true
    }
    
    
    func checkPrivateDirectory(){
        let fileMng = NSFileManager.defaultManager()
        let filePath = NSHomeDirectory() + "/Documents/private/"
        let exsit = fileMng.fileExistsAtPath(filePath)
        
        if !exsit{
            _ = try? fileMng.createDirectoryAtPath(filePath, withIntermediateDirectories: true, attributes: nil)
            
        }
        
    }

    func loadPhoto(){
        let imageManager = PHImageManager.defaultManager()
        
        let reqeustOption = PHImageRequestOptions()
        reqeustOption.synchronous = true
        reqeustOption.deliveryMode = .FastFormat
        let fetchOption:PHFetchOptions = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let resultPhotos = PHAsset.fetchAssetsWithMediaType( .Image , options:fetchOption)
        
        if resultPhotos.count > 0 {
            for i in 0..<resultPhotos.count {
                imageManager.requestImageForAsset(resultPhotos.objectAtIndex(i) as! PHAsset, targetSize: CGSizeMake(200,200), contentMode: .AspectFill, options: reqeustOption, resultHandler: { (image, error) in
                    
                    self.imageArray.append(image!)
                    
                })
            }
        }
        sourceImgArray = imageArray
        photoCollectionView.reloadData()
    }
    func backToCamera(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getFullScreenImage(index:Int){
        
        if optionsBtn.selectedSegmentIndex == 0{
            fullScreenImgV.image = imgArrayFromMemories[index]
        } else if optionsBtn.selectedSegmentIndex == 1 {
            fullScreenImgV.image = imageArray[index]
        } else {
            fullScreenImgV.image = imgArrayFromPrivate[index]
        }
        
        self.navigationController?.navigationBarHidden = true
        
        self.view.addSubview(fullScreenImgV)
        fullScreenImgV.translatesAutoresizingMaskIntoConstraints = false
        fullScreenImgV.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        fullScreenImgV.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor).active = true
        fullScreenImgV.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        fullScreenImgV.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
        
        self.view.addSubview(lockBtn)
        lockBtn.widthAnchor.constraintEqualToConstant(90).active = true
        lockBtn.heightAnchor.constraintEqualToConstant(40).active = true
        lockBtn.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor, constant: -5).active = true
        lockBtn.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor, constant: -10).active = true
        
        self.view.addSubview(socialShareBtn)
        socialShareBtn.widthAnchor.constraintEqualToConstant(110).active = true
        socialShareBtn.heightAnchor.constraintEqualToConstant(40).active = true
        socialShareBtn.rightAnchor.constraintEqualToAnchor(lockBtn.leftAnchor, constant: -5).active = true
        socialShareBtn.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor, constant: -10).active = true
        
        self.view.addSubview(closeBtn)
        closeBtn.widthAnchor.constraintEqualToConstant(30).active = true
        closeBtn.heightAnchor.constraintEqualToConstant(30).active = true
        closeBtn.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor, constant:10).active = true
        closeBtn.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant: 10).active = true
        
        self.view.addSubview(deleteBtn)
        deleteBtn.widthAnchor.constraintEqualToConstant(70).active = true
        deleteBtn.heightAnchor.constraintEqualToConstant(40).active = true
        deleteBtn.rightAnchor.constraintEqualToAnchor(socialShareBtn.leftAnchor, constant:-5).active = true
        deleteBtn.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor, constant: -10).active = true
  
    }
    
    func lock(){
        print("lock it(move 2 files to another folder)")
        
        let fileManager = NSFileManager.defaultManager()
        //let homeDirectory = NSHomeDirectory()
        
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentPath = paths[0].URLByAppendingPathComponent("private")
        

//        
//        let currentOriginalFilePath = URLArrayFromMemory[selectedIndex]
//        
//        print("cutBIP:\(currentOriginalFilePath)")
//       
//        print("dnBIP:\(documentPath)")
//        
//        try? fileManager.moveItemAtURL(currentOriginalFilePath, toURL: documentPath)
//       
        
        let currentThumbFilePath = URLArrayFromMemory[selectedIndex]
        
        let documentPathThumb = paths[0].URLByAppendingPathComponent("private/thumbs/\(suffixArray[selectedIndex])")
  
        try? fileManager.moveItemAtURL(currentThumbFilePath, toURL: documentPathThumb)
        
        imgArrayFromMemories.removeAtIndex(selectedIndex)
        URLArrayFromMemory.removeAtIndex(selectedIndex)
        suffixArray.removeAtIndex(selectedIndex)
   
        photoCollectionView.reloadData()
    }
    
    func share(){
        print("share")
    }
    
    func close(){
        fullScreenImgV.removeFromSuperview()
        closeBtn.removeFromSuperview()
        socialShareBtn.removeFromSuperview()
        lockBtn.removeFromSuperview()
        deleteBtn.removeFromSuperview()
        self.navigationController?.navigationBarHidden = false
        print("close")
    }
    
    func delete(){
        
        let fileManager = NSFileManager.defaultManager()
        close()
        
        try? fileManager.removeItemAtURL(URLArrayFromMemory[selectedIndex])
        
        
        URLArrayFromMemory.removeAtIndex(selectedIndex)
        imgArrayFromMemories.removeAtIndex(selectedIndex)
        
        
        photoCollectionView.reloadData()
        print("delete")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceImgArray.count
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath)
        cell.contentView.backgroundColor = UIColor.greenColor()
        let imgv = UIImageView()
        
        cell.contentView.addSubview(imgv)
        
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.widthAnchor.constraintEqualToAnchor(cell.contentView.widthAnchor).active = true
        imgv.heightAnchor.constraintEqualToAnchor(cell.contentView.heightAnchor).active = true
        imgv.centerXAnchor.constraintEqualToAnchor(cell.contentView.centerXAnchor).active = true
        imgv.centerYAnchor.constraintEqualToAnchor(cell.contentView.centerYAnchor).active = true
        imgv.image = sourceImgArray[indexPath.row]
        
        //imgv.userInteractionEnabled = true
        
        //imgv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedImg)))
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        selectedIndex = indexPath.row
        //print(indexPath.row)
        getFullScreenImage(selectedIndex)
        
    }
    
//    func tappedImg(tapGestrue:UITapGestureRecognizer){
//        if let tapImageView = tapGestrue.view as? UIImageView{
//            if let cellView = tapImageView.superview as? UICollectionViewCell{
//                
//                
//                print(tapCellView)
//            }
//            
//        }
//        
//        
//    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 1
        
        return CGSizeMake(width,width * 1.7)
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
}
