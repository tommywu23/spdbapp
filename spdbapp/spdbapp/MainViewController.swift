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


class MainViewController: UIViewController,UIAlertViewDelegate {
    @IBOutlet weak var btnConf: UIButton!
    @IBOutlet weak var lbConfName: UILabel!
    @IBOutlet weak var btnReconnect: UIButton!
    @IBOutlet weak var lblShowState: UILabel!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var lblShowUserName: UILabel!
    
    var current = GBMeeting()
 
    var local = GBBox()
    
    var settingsBundle = SettingsBundleConfig()
    
    
    var timer = Poller()
    
    var flag = false

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
        
        
        btnRegister.layer.cornerRadius = 8
        btnRegister.addTarget(self, action: "toRegis", forControlEvents: UIControlEvents.TouchUpInside)
        
        timer.start(self, method: "checkstatus:",timerInter: 5.0)
        
        btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        btnReconnect.layer.cornerRadius = 8
        if appManager.netConnect == true {
            ShowToolbarState.netConnectSuccess(self.lblShowState,btn: self.btnReconnect)
        }
        
        var options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old
        appManager.addObserver(self, forKeyPath: "current", options: options, context: nil)
        appManager.addObserver(self, forKeyPath: "local", options: options, context: nil)
        
        createFile()

        var loginPoller = Poller()
        loginPoller.start(self, method: "getValue", timerInter: 2.0)
        
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Create a new variable to store the instance of DocViewController
        if segue.identifier ==  "ToAgendaVC" {
            //ToAgendaVC
            var obj = segue.destinationViewController as! AgendaViewController
            obj.meetingName = self.lbConfName.text!
            
        }
    }
    
    
    func getName() -> Bool{
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var readData = NSData(contentsOfFile: filePath)
        var name = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
        
        if (name.length > 0){
            self.lblShowUserName.text = "当前用户:\(name)"
            return true
        }
        return false
    }
    
    func getValue(){
        if getName() == true {
            self.btnRegister.hidden = true
            self.btnConf.enabled = true
            btnConf.backgroundColor = UIColor(red: 123/255, green: 0/255, blue: 31/255, alpha: 1.0)
        }
    }
    
    
    func createFile()
    {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
        
        var b = NSFileManager.defaultManager().fileExistsAtPath(filePath) ? true :false
        if b == false{
            var isCreateFile: Bool = NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
            if isCreateFile == true{
                println("uasername文件创建成功")
            }
        }
    }
    
    func toRegis(){
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC: RegisViewController = storyboard.instantiateViewControllerWithIdentifier("view") as! RegisViewController
        loginVC.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        
        self.presentViewController(loginVC, animated: false, completion: nil)
    }

    
    //页面下方的“重连”按钮出发的事件
    func getReconn(){
        ShowToolbarState.netConnectLinking(self.lblShowState, btn: self.btnReconnect)
        appManager.starttimer()
    }
    
    //定时器，每隔5s刷新页面下方的toolbar控件显示
    func checkstatus(timer: NSTimer){
        if appManager.netConnect {
            ShowToolbarState.netConnectSuccess(self.lblShowState,btn: self.btnReconnect)
        }
        else{
            ShowToolbarState.netConnectFail(self.lblShowState,btn: self.btnReconnect)
        }
        self.lblShowState.reloadInputViews()
        self.btnReconnect.reloadInputViews()
    }
    
//    override func viewDidAppear(animated: Bool) {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsSettingsChanged", name: NSUserDefaultsDidChangeNotification, object: nil)
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
//    
//    
//    func defaultsSettingsChanged() {
//        let standardDefaults = NSUserDefaults.standardUserDefaults()
//        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
//        var settingsDict: NSMutableDictionary = NSMutableDictionary()
//        
//        // 监听txtFileURL是否发生改变  默认情况下是192.168.16.142
//        var value = standardDefaults.stringForKey("txtBoxURL")
//        if value == nil{
//            value = "192.168.16.142"
//        }
//   
//        settingsDict.setObject(value!, forKey: "txtBoxURL")
//        
//        var b = settingsDict.writeToFile(filepath, atomically: true)
//        println("url new value ============ \(value)")
//        
//        var isClearHistoryInfo = standardDefaults.boolForKey("clear_historyInfo")
//        if isClearHistoryInfo == true{
//            server.clearHistoryInfo("pdf")
//        }
//        
//        var isClearConfigInfo = standardDefaults.boolForKey("clear_configInfo")
//        if isClearConfigInfo == true{
//            server.clearHistoryInfo("txt")
//        }
//    }
    
    
  
    //监听会议名是否发生改变
    private var myContext = 1
    //显示当前会议名
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
       
        if keyPath == "current"{
            if !object.current.name.isEmpty{
                self.lbConfName.text = object.current.name
            }
        }
        
        if keyPath == "local"{
            if object.local.name.isEmpty{
                UIAlertView(title: "当前id未注册", message: "请先注册id", delegate: self, cancelButtonTitle: "确定").show()
            }
        }

    }
  
    deinit{
        appManager.removeObserver(self, forKeyPath: "current", context: &myContext)
        appManager.removeObserver(self, forKeyPath: "local",context: &myContext)
 
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

