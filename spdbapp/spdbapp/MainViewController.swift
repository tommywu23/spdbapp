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
        
        //create box
        local = appManager.createBox()
        
        settingsBundle.registerDefaultsFromSettingsBundle()
        
        
        
        
        
        
        
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
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsSettingsChanged", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    func defaultsSettingsChanged(){
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        
        // 监听txtFileURL是否发生改变  默认情况下是http://192.168.16.142:8088
        if standardDefaults.stringForKey("txtBoxURL") != "http://192.168.16.142:8088"{
            var baseBoxURL = standardDefaults.stringForKey("txtBoxURL")
            println("txtBoxURL = \(baseBoxURL)")
        }
        
        
        // 监听txtMeetingURL是否发生改变，默认情况下是http://192.168.16.141:8080
        if standardDefaults.stringForKey("txtMeetingURL") != "http://192.168.16.141:8080"{
            var baseMeetingURL = standardDefaults.stringForKey("txtMeetingURL")
            println("txtMeetingURL = \(baseMeetingURL)")
        }

        
    }

     
    
    //监听会议名是否发生改变
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

