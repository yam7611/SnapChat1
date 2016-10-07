//
//  CameraViewController.swift
//  LoginTest
//
//  Created by yam7611 on 8/5/16.
//  Copyright © 2016 yam7611. All rights reserved.
// 
//  sendPhoto ViewController

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
    let textBtn:UIButton = UIButton()
    let stickerBtn:UIButton = UIButton()
    let saveMemoryBtn:UIButton = UIButton()
    let uploadStoryBtn:UIButton = UIButton()
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
    var normalView = UIView()
    var sendPhotoBtn : UIButton = {
        let tempBtn  = UIButton()
        tempBtn.setImage(UIImage(named:"play-button"), forState: .Normal
        )
        tempBtn.frame.size = CGSizeMake(45,45)
        return tempBtn
    }()
    
    let mode = ["StickerMode","TypeMode","HandWriteMode"]
    var currentMode = ""
    
    var emojiScreen = UITextView()
    var emojiString = ""
    
    let emojiGroup = [ 0x1F601...0x1F64F,0x1F680...0x1F6C0]
    var cameraView1: UIImageView?
    
    var emojiDict = [String:Int]()
    var emojiMinus = [Int]()
    
    var emojis = [UILabel]()
    var drawV:DrawView?
    
    
    var currentPhoto = 0
    
    var sendPhotoViewController:SendPhotoListController?
    
    @IBOutlet weak var cameraView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.normalView)
        self.normalView.frame = self.view.frame
        self.normalView.backgroundColor = UIColor.clearColor()
        
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
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(backToMainViewOfEditMode), name: "leaveWritingMode", object: nil)
    }
    
    
    func backToMainViewOfEditMode(){
        print("leave writing mode")
        bringMainViewToFront(self.normalView)
        self.view.bringSubviewToFront(backgroundOfText)
        // self.view.becomeFirstResponder()
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
    
    func bringMainViewToFront(mainView:UIView){
        self.view.bringSubviewToFront(mainView)
        self.view.bringSubviewToFront(self.stickerBtn)
        self.view.bringSubviewToFront(self.handWriteImgV)
        self.view.bringSubviewToFront(self.textBtn)
        self.view.bringSubviewToFront(self.closeImgV)
        self.view.bringSubviewToFront(self.saveMemoryBtn)
        self.view.bringSubviewToFront(self.uploadStoryBtn)
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
                    //self.backgroundOfText.hidden = false
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
            
            } else if CGRectContainsPoint(self.backgroundOfText.frame, point){
                self.movingTextBar = true
                self.willEditText = true
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
        //print (emojiString)
        
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
        
        var i = 0
        for j in 7...293 {
            if j%2 != 0 {
                self.emojiDict["\(j)"] = j - i
                //append(j-emojiMinus[i])
                i = i+1
                //print("i=\(i),j=\(j)")
            }
        }
        
        //
    }
    
    func selectEmoji(recognizer:UITapGestureRecognizer){
        if let textView = recognizer.view as? UITextView {
            if let layoutManager = textView.layoutManager as? NSLayoutManager {
                var location = recognizer.locationInView(textView)
                location.x -= textView.textContainerInset.left
                location.y -= textView.textContainerInset.top
                let charIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
                
               // print(charIndex)
                if let indexRange = emojiDict["\(charIndex)"]{
                    let subRange = self.emojiScreen.text.startIndex.advancedBy(indexRange)..<self.emojiScreen.text.startIndex.advancedBy(indexRange + 1)
                    let subString = self.emojiScreen.text.substringWithRange(subRange)
                    
                    let attachedEmoji =  UILabel()
                    attachedEmoji.text = subString
                    attachedEmoji.frame = CGRectMake(50,50,40,40)
                    attachedEmoji.font = UIFont.systemFontOfSize(40)
                    attachedEmoji.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkIfEmojiMoved)))
                    self.emojis.append(attachedEmoji)
                    
                    self.emojiBackground.hidden = true
                    self.normalView.addSubview(attachedEmoji)
                }
         
           }
        }
    }
    
    
    func checkIfEmojiMoved(tapGesture:UITapGestureRecognizer){
        
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
        let closeImg:UIImage = UIImage(named:"cancel.png")!
        
        //MARK: attach them on imageView
        handWriteImgV.image = handWriteImg
        
        textBtn.setImage(UIImage(named:"text.png"), forState: .Normal)
        stickerBtn.setImage(UIImage(named:"new-document-button.png"), forState: .Normal)
        closeImgV.image = closeImg
        saveMemoryBtn.setImage(UIImage(named:"download.png"), forState: .Normal)
        uploadStoryBtn.setImage(UIImage(named:"new-document.png"), forState: .Normal)
        
        //set button function:
        textBtn.addTarget(self, action: #selector(goToTextMode), forControlEvents: .TouchUpInside)
        
        stickerBtn.addTarget(self, action: #selector(goToStickerMode), forControlEvents: .TouchUpInside)
        uploadStoryBtn.addTarget(self, action: #selector(handleUploadStory), forControlEvents: .TouchUpInside)
        
        saveMemoryBtn.addTarget(self, action: #selector(handleSaveMemory), forControlEvents: .TouchUpInside)
        
        self.sendPhotoBtn.addTarget(self, action: #selector(handleSnedPhoto), forControlEvents: .TouchUpInside)
        
        
        //MARK: set the position of each button(imageView) on self.view
        stickerBtn.frame = CGRectMake(200,5,30,30)
        closeImgV.frame = CGRectMake(5,5,30,30)
        textBtn.frame = CGRectMake(stickerBtn.frame.origin.x+40, stickerBtn.frame.origin.y, 30, 30)
        handWriteImgV.frame = CGRectMake(textBtn.frame.origin.x+40,textBtn.frame.origin.y,30,30)
        
        saveMemoryBtn.frame = CGRectMake(40,SCREEN_HEIGHT - 40,30,30)
        uploadStoryBtn.frame = CGRectMake(saveMemoryBtn.frame.origin.x + 40,SCREEN_HEIGHT-40,30,30)
        sendPhotoBtn.frame.origin = CGPointMake(self.view.frame.width - 50, self.view.frame.height - 50)
        
        //MARK: attach all buttons view on self.view
        self.tabBarController?.tabBar.hidden = true
        
        showAllButton()
    }
    
    func handleUploadStory(){
        print("handleUploadStory")
    }
    
    func handleSaveMemory(){
        print("handleSaveMemory")
    }
    
    func handleSnedPhoto(){
        print("handleSnedPhoto")
        hideAllButton()
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        currentPhoto = currentPhoto + 1
        let data = UIImagePNGRepresentation(screenshot)
        let filename = fetchDocumentPath().URLByAppendingPathComponent("\(currentPhoto).jpeg")
       
        //try? data?.writeToURL(filename, options: .DataWritingFileProtectionComplete)
        
        print("temporary not save to folder,but will be uncommented it later when translate photo")
        
        
        //UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
        
        //self.sendPhotoViewController
        self.sendPhotoViewController = SendPhotoListController()
        let naviVC = UINavigationController(rootViewController: self.sendPhotoViewController!)
        self.presentViewController(naviVC, animated: true, completion: nil)
        
        //loading photos from directory
        if let url = NSData(contentsOfURL: filename){
            //print(filename)
            let image = UIImage(data: url )
            let test = UIImageView(image:image)
            test.frame = self.view.frame
            self.view.addSubview(test)
            test.backgroundColor = UIColor.grayColor()
        }
        
        
        
    }
    
    func fetchDocumentPath() -> NSURL{
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentPath = paths[0]
        return documentPath
    }
    
    
    func goHandWriteMode(){
        drawV = DrawView(frame:self.cameraView1!.frame)
        //drawV.frame = CGRectMake(0,0,400,960)
        drawV?.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.drawV!)
    }
    
    func goToTextMode(){
        
        self.currentMode = mode[1]
        hideAllButton()
        self.isButtonVisible = true
        
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
        self.normalView.addSubview(backgroundOfText)
        
        
    }
    
    func goToStickerMode(){
        self.currentMode = mode[0]
        //self.backgroundOfText.hidden = true
        self.emojiBackground.hidden = false
        self.emojiScreen.hidden = false
        self.bringMainViewToFront(self.emojiBackground)
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textForEditing.text! == ""{
            backgroundOfText.removeFromSuperview()
        }
    }
    
    
    func showAllButton(){
        self.shotBtn.removeFromSuperview()
        self.view.addSubview(self.stickerBtn)
        self.view.addSubview(self.handWriteImgV)
        self.view.addSubview(self.textBtn)
        self.view.addSubview(self.closeImgV)
        self.view.addSubview(self.saveMemoryBtn)
        self.view.addSubview(self.uploadStoryBtn)
        self.view.addSubview(self.sendPhotoBtn)
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
        self.stickerBtn.removeFromSuperview()
        self.textBtn.removeFromSuperview()
        self.closeImgV.removeFromSuperview()
        self.saveMemoryBtn.removeFromSuperview()
        self.uploadStoryBtn.removeFromSuperview()
        self.sendPhotoBtn.removeFromSuperview()
        
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
