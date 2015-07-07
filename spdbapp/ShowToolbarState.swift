//
//  ShowToolbarState.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/15.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Foundation

class ShowToolbarState: NSObject {
    class func netConnectFail(label: UILabel, btn: UIButton){
        label.textColor = UIColor.redColor()
        label.text = "网络连接失败"
        
        btn.hidden = false
        btn.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 249/255, alpha: 1)
        btn.enabled = true
    }
    
    
    class func netConnectSuccess(label: UILabel, btn: UIButton){
        label.textColor = UIColor(red: 37/255, green: 189/255, blue: 54/255, alpha: 1.0)
        label.text = "网络已连接"
        btn.hidden = true
    }
    
    
    class func netConnectLinking(label: UILabel, btn: UIButton){
        btn.enabled = false
        btn.backgroundColor = UIColor.grayColor()
        label.text = "网络正在连接..."
        label.textColor = UIColor.blueColor()
    }
}