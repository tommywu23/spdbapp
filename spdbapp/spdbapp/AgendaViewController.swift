//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class AgendaViewController: UIViewController {
   
    @IBOutlet weak var lbConfType: UILabel!
    @IBOutlet weak var tvAgenda: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbConfType.text = "党政联系会议"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
