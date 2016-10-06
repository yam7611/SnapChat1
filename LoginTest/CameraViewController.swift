//
//  CameraViewController.swift
//  LoginTest
//
//  Created by yam7611 on 8/5/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import MobileCoreServices
class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate {
    
    //MARK: constants and variables in this class
    var CameraLoaded = false
    var accountName:String?
    var password:String?
    let shotBtn = UIButton()
    var imageList = Array<String>()
    let picker = UIImagePickerController()
    let changeBtnView:UIView = UIView()
    var isCancelPhoto = false
    let closeImgV:UIImageView = UIImageView()
    let handWriteImgV:UIImageView = UIImageView()
    let textImgV:UIImageView = UIImageView()
    let stickerImgV:UIImageView = UIImageView()
    let saveMemoryV:UIImageView = UIImageView()
    let uploadStoryV:UIImageView = UIImageView()
    var backgroundOfText:UIView = UIView()
    var keyboardFrame = CGRectZero
    var lastPoint = CGPoint()
    var isButtonVisible:Bool = false
    var movingTextBar = false
    var textForEditing:UITextField = UITextField()
    var willEditText = false
    var tempoLabelForTypeText = UILabel()
    var isSourceCamera = true
    var sourceBUtton = UIButton()
    let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    let emojiBackground = UIVisualEffectView()
    
    let mode = ["StickerMode","TypeMode","HandWriteMode"]
    var currentMode = ""
    
    var emojiScreen = UITextView()
    var emojiString = ""
    
    let emojiGroup = [ 0x1F601...0x1F64F,0x1F680...0x1F6C0]
    var cameraView1: UIImageView?
    
    
    @IBOutlet weak var cameraView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseCamera()
        fetchImageFromDevice()
        self.textForEditing.delegate = self
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillshow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillhide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
        backgroundOfText.frame = CGRectMake(0,60,self.view.frame.width,50)
       
        self.tempoLabelForTypeText.frame = CGRectMake(0,0,self.view.frame.width,50)
        //print("the first element in CameraViewController is :\(imageList[0])")
        // Do any additional setup after loading the view.
        
        initiateComponent()
         print ("didCameraLoad:\(self.CameraLoaded.description)")
    }
    
    
    func keyboardWillshow(notification:NSNotification){
        keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        backgroundOfText.frame.origin.y = keyboardFrame.origin.y - backgroundOfText.frame.height
       
        //self.maskForText.frame.origin.y = backgroundOfText.frame.origin.y
        
    }
    func keyboardWillhide(notification:NSNotification){
        
        tempoLabelForTypeText.text = self.textForEditing.text
        tempoLabelForTypeText.textAlignment = .Center
        tempoLabelForTypeText.textColor = UIColor.whiteColor()
        textForEditing.removeFromSuperview()
        backgroundOfText.addSubview(tempoLabelForTypeText)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textForEditing.resignFirstResponder()
        return true
    }
    
//    override func viewWillAppear(animated: Bool) {
//        
//        print("go to viewWillAppear")
//        
//        if (self.cameraView.image == nil) && (self.picker.sourceType == .SavedPhotosAlbum ){
//            hideAllButton()
//            self.picker.sourceType = .Camera
//            initialiseCamera()
//            print("go to both nil")
//        }
//        
//        let btnForTakePhoto = UIButton(frame:CGRectMake(self.view.frame.width/3,self.view.frame.height/2,80,40))
//        btnForTakePhoto.setTitle("📷", forState: UIControlState.Normal)
//        btnForTakePhoto.titleLabel?.font = UIFont(name: "arial", size: 50)
//        btnForTakePhoto.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
//        
//        btnForTakePhoto.addTarget(self, action: #selector(fetchImgV(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(btnForTakePhoto)
//        
//            
//        
//        
//    }
    
    func fetchImgV(sender:UIButton){
        fetchImageFromDevice()
    }
    
    override func viewWillDisappear(animated: Bool) {
        showAllButton()
        
//        if self.CameraLoaded {
//            self.dismissViewControllerAnimated(true){
//                self.CameraLoaded = false
//            }
//            
//        }
        
    }
    
    
    
    func createTakePhotoBtn(){
        
        shotBtn.setTitle("take a photo", forState:UIControlState.Normal)
        shotBtn.frame = CGRectMake(self.view.frame.width/3,self.view.frame.height/2,140,30)
        shotBtn.backgroundColor = UIColor.blackColor()
        shotBtn.addTarget(self, action: #selector(self.takePhotoPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(shotBtn)
  
    }
    
    func takePhotoPressed(sender:UIButton){
        print ("photo pressed")
        initialiseCamera()
        fetchImageFromDevice()
        self.shotBtn.removeFromSuperview()
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func initialiseCamera() {
        cameraView1 = UIImageView()
        cameraView1?.frame = CGRectMake(0,0,self.view.frame.width,self.view.frame.height)
        self.view.addSubview(cameraView1!)
        picker.delegate = self
        picker.sourceType = .Camera
        self.isSourceCamera = true
        changeBtnView.frame = (CGRectMake(10, 300, 160, 80))
        changeBtnView.backgroundColor = UIColor.clearColor()
        
        let text:UILabel = UILabel(frame:CGRectMake(0,0,110,30))
        text.text = "photo  video"
        changeBtnView.addSubview(text)
        let changeModeSwitch:UISwitch = UISwitch(frame:CGRectMake(10,text.frame.height+5,40,25))
        
        changeModeSwitch.setOn(false, animated: true)
        changeModeSwitch.addTarget(self, action: #selector(CameraViewController.stateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        changeBtnView.addSubview(changeModeSwitch)
        picker.cameraOverlayView = changeBtnView
        
        
        sourceBUtton.frame = CGRectMake(changeModeSwitch.frame.origin.x + changeModeSwitch.frame.width + 10,changeModeSwitch.frame.origin.y,40,40)
        
        sourceBUtton.setTitle("⛰", forState: UIControlState.Normal)
        sourceBUtton.backgroundColor = UIColor.whiteColor()
        sourceBUtton.titleLabel?.font = UIFont.boldSystemFontOfSize(40)
        changeBtnView.addSubview(sourceBUtton)
        //picker.sourceType = .PhotoLibrary
        
        
        sourceBUtton.addTarget(self, action: #selector(switchPictureSource(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        
        //fetchImageFromDevice()
        //picker.mediaTypes = [kUTTypeMovie as String]
    }
    
    
    func switchPictureSource(sender:UIButton){
        self.isSourceCamera = (!self.isSourceCamera)
        
        if self.isSourceCamera {
           sourceBUtton.setTitle("📷", forState: UIControlState.Normal)
            picker.sourceType = .Camera
        } else {
            sourceBUtton.setTitle("⛰", forState: UIControlState.Normal)
            picker.sourceType = .SavedPhotosAlbum
        }
    }
    
    func fetchImageFromDevice(){
        
        //presentViewController(self.picker, animated: true, completion: nil)
        presentViewController(self.picker, animated: true) { 
           self.CameraLoaded = true
            print ("didCameraLoad:\(self.CameraLoaded.description)")
        }
        
    }
  
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.locationInView(self.view)

            if CGRectContainsPoint(closeImgV.frame, point){
                
                //if currently user us in sticker mode then execute this
                if self.currentMode == mode[0]{
                    self.emojiBackground.hidden = true
                } else {
                    cancelCurrentPhoto()
                    isCancelPhoto = true
                    self.picker.removeFromParentViewController()
                }
                
            } else if CGRectContainsPoint(handWriteImgV.frame,point){
                self.currentMode = mode[2]
                hideAllButton()
                goHandWriteMode()
                self.isButtonVisible = true
            } else if CGRectContainsPoint(self.textImgV.frame,point){
                self.currentMode = mode[1]
                hideAllButton()
                goToTextMode()
                self.isButtonVisible = true
            } else if CGRectContainsPoint(self.backgroundOfText.frame, point){
                self.movingTextBar = true
                self.willEditText = true
            } else if CGRectContainsPoint(self.stickerImgV.frame, point){
                self.currentMode = mode[0]
                goToStickerMode()
                

               
            }
            
            else {
                self.isButtonVisible = false
                hideAllButton()
                if willEditText {
                    textForEditing.resignFirstResponder()
                }
            }
            lastPoint = point
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self.view)
            if self.movingTextBar {

                self.backgroundOfText.frame.origin.y +=  point.y - lastPoint.y
                self.willEditText = false
            }
            lastPoint = point
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.locationInView(self.view)
            if !self.isButtonVisible{
                showAllButton()
            }
            
            if CGRectContainsPoint(self.backgroundOfText.frame, point){
                if willEditText {
                    self.textForEditing.text = tempoLabelForTypeText.text!
                    tempoLabelForTypeText.removeFromSuperview()
                    backgroundOfText.addSubview(textForEditing)
                    textForEditing.becomeFirstResponder()
                }
            }
            
            self.movingTextBar = false
            self.willEditText = false
            
        }
    }
    
    
    func stateChanged(switchState:UISwitch){
        if switchState.on{
           picker.mediaTypes = [kUTTypeMovie as String]
        } else {
            picker.mediaTypes = [kUTTypeImage as String]
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        cameraView1?.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismissViewControllerAnimated(true,completion:nil)
        createButtonsOnTopOfImageView()
        if self.cameraView1?.image != nil{
            isCancelPhoto = false
            print("did not cancel")
        } else {
            isCancelPhoto = true
            print("cancel")
        }
        
    }
    
    
    //initiate some view that will be used later on
    
    func initiateComponent(){
        
        
        
        //**** initialise componet for sticker mode
        self.emojiBackground.effect = darkBlur
        self.emojiBackground.frame = self.view.frame
        self.view.addSubview(emojiBackground)
        self.emojiBackground.hidden = true
        
        self.emojiScreen.frame = CGRectMake(0,40,self.view.frame.width,self.view.frame.height - 90)
        
        
        //iterating first part emoji adn append to string
        for i in emojiGroup {
            for j in i {
                emojiString += String(UnicodeScalar(j))
            }
        }
        print (emojiString)
        
        self.emojiScreen.backgroundColor = UIColor.clearColor()
        self.emojiScreen.text = "face \n \(emojiString) "
        
        self.emojiScreen.textColor = UIColor.whiteColor()
        self.emojiScreen.font = UIFont(name: "arial" , size: 30)
        self.emojiScreen.editable = false
        self.emojiScreen.selectable = false
        self.emojiScreen.hidden = true
        
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(selectEmoji(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        self.emojiScreen.addGestureRecognizer(tapGesture)
        
        self.emojiBackground.addSubview(self.emojiScreen)
        
        
        //
    }
    
    func selectEmoji(recognizer:UITapGestureRecognizer){
        if let textView = recognizer.view as? UITextView {
            if let layoutManager = textView.layoutManager as? NSLayoutManager {
                var location = recognizer.locationInView(textView)
                location.x -= textView.textContainerInset.left
                location.y -= textView.textContainerInset.top
                var charIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
                
                print(charIndex)
                
                
                
                if charIndex < textView.textStorage.length{
                    print("it is smaller")
                    var range =  NSRange(location:0, length:1)
 
                    //let y:Int32 = charIndex
                    
                    if let idval = textView.attributedText?.attribute("idnum", atIndex: charIndex, effectiveRange: &range) as? NSString {
                        print ("id value :\(idval)")
                        print ("cahrIndex :\(charIndex)")
                        print("range.location:\(range.location)")
                        print("range.length:\(range.length)")
                        let tappedPhrase = (textView.attributedText.string as? NSString)?.substringWithRange(range)
                        
                        print("tappedPhrase:\(tappedPhrase)")
                        
                        var mutableText = textView.attributedText.mutableCopy() as? NSMutableAttributedString
                        
                        mutableText?.addAttributes([NSForegroundColorAttributeName:UIColor.redColor()], range: range)
                        textView.attributedText = mutableText
            
                    }
                    if let desc = textView.attributedText?.attribute("desc", atIndex: charIndex, effectiveRange: &range) as? NSString{
                        print ("desc:\(desc)")
                    }
                    
                }
                else {print ("the one you choose is \(charIndex)")}
                
                
            }
        }
    }
    
    func createButtonsOnTopOfImageView(){
        
        let SCREEN_HEIGHT = self.view.frame.height
        let SCREEN_WIDTH = self.view.frame.width
        
        let centerPoint:CGPoint = CGPointMake(self.view.frame.width/2,self.view.frame.height/2)

        //MARK: draw a circle for define second for dismissing photo
        
        let radius:CGFloat = 30.0
        let startAngle:CGFloat = 0.0
        let endAngle:CGFloat = CGFloat(M_PI * 2)
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let layer = CAShapeLayer()
        layer.path = path.CGPath
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = UIColor.clearColor().CGColor
        
        //MARK: setting each button image
        let handWriteImg:UIImage = UIImage(named: "pencil.png")!
        let paperImg:UIImage = UIImage(named: "new-document-button.png")!
        let textImg:UIImage = UIImage(named: "text.png")!
        let closeImg:UIImage = UIImage(named:"cancel.png")!
        let saveToMemory:UIImage = UIImage(named:"download.png")!
        let uploadToStory:UIImage = UIImage(named:"new-document.png")!
        
        
        //MARK: attach them on imageView
        handWriteImgV.image = handWriteImg
        textImgV.image = textImg
        stickerImgV.image = paperImg
        closeImgV.image = closeImg
        saveMemoryV.image = saveToMemory
        uploadStoryV.image = uploadToStory
        
        
        //MARK: set the position of each button(imageView) on self.view
        stickerImgV.frame = CGRectMake(200,5,30,30)
        closeImgV.frame = CGRectMake(5,5,30,30)
        textImgV.frame = CGRectMake(stickerImgV.frame.origin.x+40, stickerImgV.frame.origin.y, 30, 30)
        handWriteImgV.frame = CGRectMake(textImgV.frame.origin.x+40,textImgV.frame.origin.y,30,30)
        
        saveMemoryV.frame = CGRectMake(40,SCREEN_HEIGHT - 40,30,30)
        uploadStoryV.frame = CGRectMake(saveMemoryV.frame.origin.x + 40,SCREEN_HEIGHT-40,30,30)
        
        //MARK: attach all buttons view on self.view
        self.tabBarController?.tabBar.hidden = true
        
        showAllButton()
    }
    
    func goHandWriteMode(){
        let drawV:DrawView = DrawView(frame:self.cameraView1!.frame)
        //drawV.frame = CGRectMake(0,0,400,960)
        drawV.backgroundColor = UIColor.clearColor()
        self.view.addSubview(drawV)
    }
    
    func goToTextMode(){
        backgroundOfText.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.cameraView1?.addSubview(backgroundOfText)
        textForEditing.frame = CGRectMake(0,0,backgroundOfText.frame.width,backgroundOfText.frame.height)
        
        backgroundOfText.addSubview(textForEditing)
        //cameraView.addSubview(maskForText)
        textForEditing.textAlignment = .Left
        textForEditing.becomeFirstResponder()
        textForEditing.textColor = UIColor.whiteColor()
        
        
        //self.maskForText.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.7)
        //backgroundOfText.addSubview(self.maskForText)
        self.view.addSubview(backgroundOfText)
        
        
    }
    
    func goToStickerMode(){
        self.emojiBackground.hidden = false
        self.emojiScreen.hidden = false
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textForEditing.text! == ""{
            backgroundOfText.removeFromSuperview()
        }
    }
    
    
    func showAllButton(){
        self.shotBtn.removeFromSuperview()
        self.view.addSubview(self.stickerImgV)
        self.view.addSubview(self.handWriteImgV)
        self.view.addSubview(self.textImgV)
        self.view.addSubview(self.closeImgV)
        self.view.addSubview(self.saveMemoryV)
        self.view.addSubview(self.uploadStoryV)
    }
    
    func cancelCurrentPhoto(){
        print("cancel drawing")
        hideAllButton()
        //self.drawV.removeFromSuperview()
        //cameraView.image = nil
        self.tabBarController?.tabBar.hidden = false
        fetchImageFromDevice()
            }
    
    func hideAllButton(){
        
        self.handWriteImgV.removeFromSuperview()
        self.stickerImgV.removeFromSuperview()
        self.textImgV.removeFromSuperview()
        self.closeImgV.removeFromSuperview()
        self.saveMemoryV.removeFromSuperview()
        self.uploadStoryV.removeFromSuperview()
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        if picker.sourceType == .SavedPhotosAlbum{
            self.dismissViewControllerAnimated(true, completion: nil)
            picker.sourceType = .Camera
            fetchImageFromDevice()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
            cameraView1?.removeFromSuperview()
        }
       
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
