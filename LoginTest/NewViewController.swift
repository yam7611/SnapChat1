//
//  NewViewController.swift
//  LoginTest
//
//  Created by yam7611 on 8/10/16.
//  Copyright © 2016 yam7611. All rights reserved.
//

import UIKit

class NewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {

    @IBOutlet weak var rightTableView: UITableView!
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var youBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var tabPanel: UIView!
    
    let scrollBar=UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let HEIGHT = self.view.frame.height - 200
        
        let WIDTH = self.view.frame.width
        
        
        self.view.addSubview(self.scrollView)
        self.scrollBar.backgroundColor = UIColor.blueColor()
        self.scrollBar.frame = CGRectMake(0,87,WIDTH/2 ,3)
        
        self.scrollView.delegate = self
        
        self.leftTableView.delegate = self
        self.leftTableView.dataSource = self
        self.leftTableView.tableFooterView=UIView()
        
        self.rightTableView.delegate = self
        self.rightTableView.dataSource = self
        self.rightTableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell")
//        cell.textLabel.text="row#\(indexPath.row)"
//        cell.detailTextLabel.text="subtitle#\(indexPath.row)"
//        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
}
