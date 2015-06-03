//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController {
    @IBOutlet weak var btnConf: UIButton!
    @IBOutlet weak var lbConfName: UILabel!

    var current = GBMeeting()
    
    var appManager = AppManager()
    
    var local = GBBox()
    var poller = Poller()
    var settingsBundle = SettingsBundleConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        local = appManager.createBox()
        
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 20
        style.alignment = NSTextAlignment.Center
        var attr = [NSParagraphStyleAttributeName : style]
        
        
        var name = "暂无会议"
        lbConfName.attributedText = NSAttributedString(string: name, attributes : attr)
        
        //初始化时候btnconf背景颜色为灰色，点击无效
        btnConf.layer.cornerRadius = 8
        btnConf.backgroundColor = UIColor.grayColor()
        btnConf.enabled = false
       
        appManager.addObserver(self, forKeyPath: "current", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old, context: nil)
    }
    
    
     
    
    private var myContext = 1
    //显示当前会议名
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "current"{
            if !object.current.name.isEmpty{
                self.lbConfName.text = object.current.name
                self.btnConf.enabled = true
                btnConf.backgroundColor = UIColor(red: 123/255, green: 0/255, blue: 31/255, alpha: 1.0)
            }
        }
    }
    
    
    deinit{
        appManager.removeObserver(self, forKeyPath: "current", context: &myContext)
    }

    
    
    @IBAction func btnClearMeetingInfo(sender: UIButton) {
        DeleteManager.deleteInfo("jsondata.txt")
    }

    
    @IBAction func btnClearAgendaInfo(sender: UIButton) {
        DeleteManager.deleteAllInfo()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

