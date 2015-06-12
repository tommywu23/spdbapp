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
    @IBOutlet weak var btnReconnect: UIButton!
    @IBOutlet weak var lblShowState: UILabel!
   
    var current = GBMeeting()
 
    var local = GBBox()
    
    var settingsBundle = SettingsBundleConfig()
    var heartbearCount = 0
    
    var server = Server()
   var timer = Poller()
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
       timer.start(self, method: "checkstatus:",timerInter: 5.0)
        
        btnReconnect.layer.cornerRadius = 8
        if appManager.netConnect == true {
            netConnectSuccess()
        }else{
            btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        var options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old
        appManager.addObserver(self, forKeyPath: "current", options: options, context: nil)
        appManager.addObserver(self, forKeyPath: "netConnect", options: options, context: nil)
        appManager.addObserver(self, forKeyPath: "local", options: options, context: nil)
    }
    
 
    
    func getReconn(){
        self.netConnectLinking()
        appManager.starttimer()
    }
    
    
    func checkstatus(timer: NSTimer){
        //println("1===============\(appManager.netConnect)=====================1")
        if appManager.netConnect {
            self.netConnectSuccess()
        }
        else{
            self.netConnectFail()
        }

    }
    
    
    func startHeartbeat(timer: NSTimer){
//        appManager.startHeartbeat(timer)
//        var url = server.heartBeatServiceUrl + GBNetwork.getMacId()
//        Alamofire.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
//            
//            if error != nil{
//                //println("connect error = \(error?.description)")
//                //return
//            }
//
//            if response?.statusCode == 200{
//                appManager.netConnect = true
//                self.count = 0
//                self.netConnectSuccess()
//            }
//            else{
//                self.count++
//                println("netConnect fail1,count = \(self.count)")
//                if self.count == 3{
//                    UIAlertView(title: "网络连接失败", message: "请重试", delegate: self, cancelButtonTitle: "确定").show()
//                    timer.invalidate()
//                    appManager.netConnect = false
//                    println("netConnect daoshijian1 ,count = \(self.count)")
//                    self.count = 0
//                    self.netConnectFail()
//                }
//            }
//        }
    }

    func netConnectFail(){
        self.lblShowState.textColor = UIColor.redColor()
        self.lblShowState.text = "网络连接失败"
        
        self.btnReconnect.hidden = false
        self.btnReconnect.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 249/255, alpha: 1)
        self.btnReconnect.enabled = true
    }
    
    func netConnectSuccess(){
        self.lblShowState.textColor = UIColor.greenColor()
        self.lblShowState.text = "网络已连接"
        self.btnReconnect.hidden = true

    }
    
    func netConnectLinking(){
        btnReconnect.enabled = false
        btnReconnect.backgroundColor = UIColor.grayColor()
        lblShowState.text = "网络正在连接..."
        lblShowState.textColor = UIColor.blueColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsSettingsChanged", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func defaultsSettingsChanged() -> NSMutableDictionary {
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
        println("url new value ============ \(valueBasic)")
        var b = settingsDict.writeToFile(filepath, atomically: true)
        
        return settingsDict
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
            if object.netConnect == true {
                self.netConnectSuccess()
            }
            else{
                self.netConnectFail()
            }
        }
    }
    deinit{
        appManager.removeObserver(self, forKeyPath: "current", context: &myContext)
        appManager.removeObserver(self, forKeyPath: "netConnect", context: &myContext)
        appManager.removeObserver(self, forKeyPath: "local",context: &myContext)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

