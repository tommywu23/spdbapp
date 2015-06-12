//
//  ToolBarView.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/11.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Foundation

class ToolBarView: UIView {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnReconn: UIButton!
    @IBOutlet weak var lblConnect: UILabel!

//    
//    class func instanceFromNib() -> UIView {
//    
//        return UINib(nibName: "ToolBarView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
//    }
//    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func commonInit() {
        var nibView = NSBundle.mainBundle().loadNibNamed("ToolBarView", owner: self, options: nil)[0] as! UIView
        nibView.frame = self.bounds;
        self.addSubview(nibView)
    }
}
