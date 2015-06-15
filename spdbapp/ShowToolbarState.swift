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
//        self.lblShowState.textColor = UIColor.redColor()
//        self.lblShowState.text = "网络连接失败"
//        
//        self.btnReconnect.hidden = false
//        self.btnReconnect.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 249/255, alpha: 1)
//        self.btnReconnect.enabled = true
        
        label.textColor = UIColor.redColor()
        label.text = "网络连接失败"
        
        btn.hidden = false
        btn.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 249/255, alpha: 1)
        btn.enabled = true
    }
}
