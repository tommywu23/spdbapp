//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class MainViewController: UIViewController {
    @IBOutlet weak var btnConf: UIButton!
    @IBOutlet weak var lbConfName: UILabel!
    @IBOutlet weak var lbConnect: UILabel!
    @IBOutlet weak var btnReCon: UIButton!

    
    var current = GBMeeting()
    
    
    var local = GBBox()
    
    var settingsBundle = SettingsBundleConfig()
    var heartbearCount = 0
    
    var server = Server()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var netConnect = appManager.netConnect
        
        settingsBundle.registerDefaultsFromSettingsBundle()
       
        var boxURL = server.boxServiceUrl
        println("boxURL===================\(boxURL)")

        //ServerConfig.getSettingsBundleInfo()

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
        
        btnReCon.layer.cornerRadius = 8
        btnReCon.backgroundColor = UIColor.grayColor()
        lbConnect.backgroundColor = UIColor.clearColor()
        
        var options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old
        appManager.addObserver(self, forKeyPath: "current", options: options, context: nil)
        appManager.addObserver(self, forKeyPath: "netConnect", options: options, context: nil)
        appManager.addObserver(self, forKeyPath: "local", options: options, context: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsSettingsChanged", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func defaultsSettingsChanged() {
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        
        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        var settingsDict: NSMutableDictionary = NSMutableDictionary()
        
        // 监听txtFileURL是否发生改变  默认情况下是192.168.16.142
        var valuebundle = standardDefaults.stringForKey("txtBoxURL")
        var valueBasic = "192.168.16.142"
        if valuebundle !=  valueBasic{
            valueBasic = valuebundle!
        }
        settingsDict.setObject(valueBasic, forKey: "txtBoxURL")
        
        settingsDict.writeToFile(filepath, atomically: true)
    }

    
    func startHeartbeat(){
        
        var url = server.heartBeatServiceUrl + GBNetwork.getMacId()
        Alamofire.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            
            if error != nil{
                println("connect error = \(error?.description)")
            }
            if response?.statusCode == 200{
                println("netConnect ok")
                appManager.netConnect = true
                self.lbConnect.backgroundColor = UIColor(red: 123/255, green: 0/255, blue: 31/255, alpha: 1.0)
                self.lbConnect.text = "网络连接成功"
            }
            
//            if response?.statusCode != 200{
//                if self.heartbearCount < count{
//                    self.heartbearCount = self.heartbearCount + 1
//                }
//                println("count = \(self.heartbearCount)")
//            }
//            if self.heartbearCount == count{
//                self.appManager.netConnect = false
//                self.heartbearCount = 0
//            }
        }
    }
    
    @IBAction func btnReConnection(sender: UIButton) {
        self.btnReCon.backgroundColor = UIColor(red: 123/255, green: 0/255, blue: 31/255, alpha: 1.0)
        self.lbConnect.backgroundColor = UIColor(red: 29/255, green: 134/255, blue: 25/255, alpha: 1.0)
        self.lbConnect.text = "网络正在连接..."
        var count = 3
        for var i = 0 ; i < count ; i++ {
            startHeartbeat()
            println("count = \(i+1)")
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
        
        if keyPath == "local"{
            if object.local.name.isEmpty{
                UIAlertView(title: "当前id未注册", message: "请先注册id", delegate: self, cancelButtonTitle: "确定").show()
            }
        }
        
        
        if keyPath == "netConnect"{
            //println("object = \(object.netConnect)")
            if object.netConnect == true {
                self.lbConnect.text = " 网络已连接"
                self.lbConnect.backgroundColor = UIColor(red: 123/255, green: 0/255, blue: 31/255, alpha: 1.0)
                btnReCon.hidden = true
            }
        }
    }
    
    deinit{
        appManager.removeObserver(self, forKeyPath: "current", context: &myContext)
        appManager.removeObserver(self, forKeyPath: "netConnect", context: &myContext)
        appManager.removeObserver(self, forKeyPath: "local",context: &myContext)
    }

    
    
    
    func showDetail() -> NSMutableDictionary {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        var dict = NSMutableDictionary(contentsOfFile: filePath)!
//        dict.removeObjectForKey("txtMeetingURL")
        
        println("showdetail settingsInfo = \(dict)")
       
        return dict
    }
    
  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

