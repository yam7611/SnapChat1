//
//  DrawView.swift
//  LoginTest
//
//  Created by yam7611 on 9/8/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var lines: [Line] = []
    var lastPoint:CGPoint!
    var isMoving:Bool!
    let imageView:UIImageView=UIImageView()
    
    let handWriteImgBtn:UIButton = {
        let tempBtn = UIButton()
        tempBtn.layer.cornerRadius = 2
        tempBtn.layer.masksToBounds = true
        return tempBtn
    }()
    let rectangleImgV:UIImageView = UIImageView()
    let undoImgV:UIImageView = UIImageView()
    var tempLineRecorder:Int = 0
    var previousLineRecorder:Int = 0
    
    
    var pathRecording:[Int] = []
    
    override init(frame: CGRect){
        super.init(frame: frame)
        imageView.frame = CGRectMake(0,0,frame.width,frame.height)
        //imageView.backgroundColor = UIColor.brownColor()
        //self.backgroundColor = UIColor.blueColor()
        self.addSubview(imageView)
        createButtonsOnTopOfImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isMoving = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(imageView)
             //print("begin at x:\(lastPoint.x),y:\(lastPoint.y)")
            
            if CGRectContainsPoint(self.undoImgV.frame,lastPoint) {
                //lines.removeLast()

                print ("before deleting index 0 : \(lines.startIndex) , last index:\(lines.endIndex) , should delete from:\(lines.count - (pathRecording.last! - 1)) , to:\(lines.count) ")
                if pathRecording != []{
                lines.removeRange(Range<Int>(start:lines.count - pathRecording.last!  , end: lines.count ))
                print ("before remove,last line:\(pathRecording.last)")
                
                    pathRecording.removeLast()
                    self.setNeedsDisplay()
                }
                print ("after remove,last line:\(pathRecording.last)")
                print ("after deleting index 0 : \(lines.startIndex) , last index:\(lines.endIndex),the previousTempLine is:\(pathRecording.last)")
            } 
        }
    }
    

    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if let touch = touches.first{
            
           let newPoint = touch.locationInView(imageView)
            //print("moved to x:\(newPoint.x),y:\(newPoint.y)")
            
            if CGRectContainsPoint(imageView.frame, newPoint){
                lines.append(Line(start:lastPoint, end:newPoint))
                lastPoint = newPoint
                tempLineRecorder += 1
                //print("number in lines:\(lines.count), tempLine:\(tempLineRecorder)")
                self.setNeedsDisplay()
                NSNotificationCenter.defaultCenter().postNotificationName("isDrawingPost", object: nil, userInfo: ["isDrawing":true])
                self.handWriteImgBtn.hidden = true
                self.undoImgV.hidden =  true
                self.rectangleImgV.hidden = true
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //previousLineRecorder =
        
        if let touch = touches.first{
            let point = touch.locationInView(imageView)
            NSNotificationCenter.defaultCenter().postNotificationName("isDrawingPost", object: nil, userInfo: ["isDrawing":false])
            self.handWriteImgBtn.hidden = false
            self.undoImgV.hidden =  false
            self.rectangleImgV.hidden = false
            
            
            if CGRectContainsPoint(undoImgV.frame, point){
                if pathRecording == []{
                    self.undoImgV.hidden = true
                }
            } else {
                pathRecording.append(tempLineRecorder)
                tempLineRecorder = 0
                self.undoImgV.hidden = false
            } 
        }
        
        //previousLineRecorder = 0
    }
    
    func createButtonsOnTopOfImageView(){
        let SCREEN_HEIGHT = self.frame.height
        let SCREEN_WIDTH = self.frame.width
       // let centerPoint:CGPoint = CGPointMake(self.frame.width/2,self.frame.height/2)
        
        //MARK: draw a circle for define second for dismissing photo
        
        let radius:CGFloat = 30.0
        let startAngle:CGFloat = 0.0
        let endAngle:CGFloat = CGFloat(M_PI * 2)
        let path = UIBezierPath(arcCenter: CGPointMake(10, self.frame.origin.y-45), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let layer = CAShapeLayer()
        layer.path = path.CGPath
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(layer)
        //MARK: setting each button image
       // let handWriteImg:UIImage = UIImage(named: "pencil.png")!
        
        let rectangle:UIImage = UIImage(named:"rectangle.png")!
        let undo:UIImage = UIImage(named:"undo.png")!
        
        //MARK: attach them on imageView
        //handWriteImgV.image = handWriteImg
        handWriteImgBtn.setImage(UIImage(named:"pencil.png"), forState: .Normal)
        handWriteImgBtn.addTarget(self, action: #selector(handleLeaveWritingMode), forControlEvents: .TouchUpInside)
        
        rectangleImgV.image = rectangle
        undoImgV.image = undo
        undoImgV.backgroundColor = UIColor.redColor()
        
        //rectangleImgV.addSubview(handWriteImgV)
        
       
        //MARK: set the position of each button(imageView) on self.view
        
        handWriteImgBtn.frame = CGRectMake(SCREEN_WIDTH - 38,7,25,25)
        rectangleImgV.frame = CGRectMake(SCREEN_WIDTH - 40,5,30,30)
        handWriteImgBtn.backgroundColor = UIColor.redColor()
        undoImgV.frame = CGRectMake(rectangleImgV.frame.origin.x - 40,5,30,30)
        
        //MARK: attach all buttons view on self.view
        self.addSubview(self.handWriteImgBtn)
        self.addSubview(self.rectangleImgV)
        self.addSubview(self.undoImgV)
        self.undoImgV.hidden = true

        
    }
    
    func handleLeaveWritingMode(){
        self.hidden = false
        self.rectangleImgV.hidden = true
        self.handWriteImgBtn.hidden = true
        self.undoImgV.hidden = true
        NSNotificationCenter.defaultCenter().postNotificationName("leaveWritingMode", object: nil)

    }

    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        for line in lines{
            CGContextMoveToPoint(context, line.start.x, line.start .y)
            CGContextAddLineToPoint(context, line.end.x, line.end.y)
            
        }
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, 5)
        CGContextSetRGBStrokeColor(context, 1, 0, 0, 1)
        CGContextStrokePath(context)
    }
    
}
