//
//  ViewController.swift
//  LoginTest
//
//  Created by yam7611 on 8/4/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func login(sender: UIButton) {
        postToServer();
    }
    
    func postToServer(){
        //print("request is sent!")
        sendRequestToServer()
    }
    func sendRequestToServer(){
        let url = NSURL(string: "http://10.9.202.5:8888/testForios.php")
        
        let request = NSMutableURLRequest(URL:url!)
        
        let postString = "username_insert=\(username.text!)&password_insert=\(password.text!)"
        
        request.HTTPMethod="POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil{
                print("error\(error)")
            }
            let responseString = NSString(data:data!,encoding:NSUTF8StringEncoding)
            print("responseString=\(responseString!)")
            
            if (responseString?.containsString("Successfully") != nil){
                    print ("welcome back")
            }
            
        }
        task.resume()
    }
    
    
    
}

