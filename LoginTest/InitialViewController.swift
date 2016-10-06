//
//  InitialViewController.swift
//  LoginTest
//
//  Created by yam7611 on 8/5/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var login: UIButton!
    
    @IBOutlet weak var signup: UIButton!
    @IBAction func login(sender: UIButton) {
       // print ("pressed the button Login")
    }
    @IBAction func signup(sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 255, green: 255, blue: 0, alpha: 1)
        //let loginBackground = UIView(frame:CGRectMake(0,400,self.view.frame.width,80))
        //loginBackground.backgroundColor = UIColor.init(red: 204, green: 0, blue: 102, alpha: 1)
        
        //signup.backgroundColor = UIColor.init(red: 204, green: 0, blue: 102, alpha: 1)
        //signup.frame.width = self.view.frame.width
        
        //self.view.addSubview(loginBackground)
       // self.view.bringSubviewToFront(signup)

        
       
        // Do any additional setup after loading the view.
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
