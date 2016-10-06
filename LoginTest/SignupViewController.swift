//
//  SignupViewController.swift
//  LoginTest
//
//  Created by yam7611 on 8/5/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    
    var connection = false
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var successfullySignUp = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //let ref = FIRDatabase.database().referenceFromURL("https://messagetest-4e61c.firebaseio.com/")
        //ref.updateChildValues(["someValues":123123])
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func backToFirstViewController(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func login(sender: UIButton) {
        
        guard let userName = username.text,passWord = password.text,nickname = name.text else {
            print("it is not valied account ")
            return
        }
        
       // postToServer();
        
        if connection && successfullySignUp {
            self.performSegueWithIdentifier(Storyboard.segueIdentifier, sender: sender)
        }
        
        let ref = FIRDatabase.database().referenceFromURL("https://messagetest-4e61c.firebaseio.com/")
        
        FIRAuth.auth()?.createUserWithEmail(userName, password: passWord, completion: { (user:FIRUser?, error) in
            if error != nil{
                print(error)
                return
                
            }
            // successfully authenticated user
            
            
            let values = ["username":userName,"name":nickname]
            
            
            guard let uid = user?.uid else{
                print("uid is unvalid")
                return
            }
            
            
            let userReference = ref.child("users").child(uid)
            
            userReference.updateChildValues(values) { (err, ref) in
                if err != nil{
                    print(err)
                    return
                }
            }

        })
        
        
        
        print("btn clicked!")
    }
    
    
    
    func postToServer(){
        //print("request is sent!")
        sendRequestToServer()
    }
    func sendRequestToServer(){
        let url = NSURL(string: "http://localhost:8888/testForios.php")
        
        let request = NSMutableURLRequest(URL:url!)
        
        print ("request\(request)")
        
        let postString = "username_insert=\(username.text!)&password_insert=\(password.text!)"
        
        request.HTTPMethod="POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil{
                self.connection = false
                print("error\(error)")
            } else {
                self.connection = true
                let responseString = NSString(data:data!,encoding:NSUTF8StringEncoding)
                print("responseString=\(responseString!)")
                
                
                
                if (responseString?.containsString("Successfully") != nil){
                    self.successfullySignUp = true
                    print ("successfully go to set up sign up as true ")
                    
                } else {
                    print ("the id is invalid")
                }
               
                
            }
        }
        task.resume()
        
    }
    
    private struct Storyboard {
        static let segueIdentifier = "ShowStartingApp"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue is loaded! ")
        if segue.identifier == Storyboard.segueIdentifier{
           
            print ("go to the prepare for segue")
            if let dvc = segue.destinationViewController as? GettingStartViewController{
                dvc.userName = username.text!
                print("dvc.userName = \(dvc.userName)")
            }
            
        }
    }
    
    
    
}
