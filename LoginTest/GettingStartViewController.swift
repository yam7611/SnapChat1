//
//  GettingStartViewController.swift
//  LoginTest
//
//  Created by yam7611 on 8/5/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class GettingStartViewController: UIViewController {

    @IBOutlet weak var hello: UILabel!
    
    var userName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        hello.text = "Welcome,\(userName)"
        // Do any additional setup after loading the view.
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
