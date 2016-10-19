//
//  AddFriendByCode.swift
//  LoginTest
//
//  Created by yam7611 on 10/18/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
class AddFriendByCode: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
   
    var qrcodeView:UIView?
    var captureSession: AVCaptureSession!
    
    var cameraDevices: AVCaptureDevice!
    
    var imageOutput: AVCaptureMetadataOutput!
    
    var captureVideoLayer: AVCaptureVideoPreviewLayer?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        print("loadAddingFreindByCode!")
        initComponenet()
        
    }
    
    
    func initComponenet(){
        
        self.navigationItem.title = "add friend by Code"
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "add friend", style: .Plain, target: self, action: #selector(backToFriend))
        
        captureSession = AVCaptureSession()
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.position == AVCaptureDevicePosition.Back {
                cameraDevices = device as! AVCaptureDevice
            }
        }
        
        let videoInput: AVCaptureInput!
        do {
            videoInput = try AVCaptureDeviceInput.init(device: cameraDevices)
        } catch {
            videoInput = nil
        }
        
        captureSession.addInput(videoInput)
        
        imageOutput = AVCaptureMetadataOutput()
        
        captureSession.addOutput(imageOutput)
        
        
        imageOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        imageOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        captureVideoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        captureVideoLayer!.frame = self.view.bounds
        captureVideoLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        captureSession.startRunning()
        self.view.layer.addSublayer(captureVideoLayer!)
        //self.view.addSubview(cameraView)
        
        qrcodeView = UIView()
        qrcodeView?.layer.borderColor = UIColor.greenColor().CGColor
        qrcodeView?.layer.borderWidth = 2
        self.view.addSubview(qrcodeView!)
        
        self.view.bringSubviewToFront(qrcodeView!)


    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects
        
        
        metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrcodeView?.frame = CGRectZero
            print("no obj")
            return
        } else {
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                let barcodeObject = captureVideoLayer!.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                qrcodeView?.frame = barcodeObject.bounds
                if metadataObj.stringValue != nil{
                    print (metadataObj.stringValue )
                    checkAndAddFriend(metadataObj.stringValue)
                }
            }
        }
    }
    
    func checkAndAddFriend(username:String){
        
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            
            if let usernameFromDB = snapshot.key as? String {
                if usernameFromDB == username {
                    
                    if let uid = FIRAuth.auth()?.currentUser?.uid{
                        FIRDatabase.database().reference().child("users").child("\(uid)").child("friends").child("\(username)").updateChildValues(["status":"request sent"])
                        
                        FIRDatabase.database().reference().child("users").child("\(username)").child("friends").child("\(uid)").updateChildValues(["status":"wait accepted"])
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                    }
                }
            }
            
            
            }, withCancelBlock: nil)
        
    }
    
    
    func backToFriend(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
