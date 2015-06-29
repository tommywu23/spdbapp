//
//  ToolbarViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/24.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class ToolbarViewController: UIViewController {

    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnServer: UIButton!
    @IBOutlet weak var btnReconn: UIButton!
    @IBOutlet weak var lblSHowState: UILabel!
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
