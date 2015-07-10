//
//  AppManager.swift
//  spdbapp
//
//  Created by tommy on 15/5/11.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class Poller {
    var timer: NSTimer?
    
    func start(obj: NSObject, method: Selector,timerInter: Double) {
        stop()
        
        timer = NSTimer(timeInterval: timerInter, target: obj, selector: method , userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func stop() {
        if (isRun()){
            timer?.invalidate()
        }
    }
    
    func isRun() -> Bool{
        return (timer != nil && timer?.valid != nil)
    }
}


class AppManager : NSObject, UIAlertViewDelegate {
    dynamic var current = GBMeeting()
    dynamic var netConnect: Bool = false
    dynamic var local = GBBox()
  
    var reqBoxURL: String?
    var count = 0
    var timerHearbeat = Poller()
    
    override init(){
        super.init()
        reqBoxURL = server.boxServiceUrl
        
        //程序启动先创建Box
        local = createBox()
        
        //定时器每隔2s检测当前current是否发生变化
        var getCurrentPoller = Poller()
        getCurrentPoller.start(self, method: "getCurrent:", timerInter: 3.0)
        
        self.netConnect = false
        starttimer()
    }
    
    func starttimer(){
        //定时器每隔一段时间去检测当前联网状态
        timerHearbeat.start(self, method: "startHeartbeat:",timerInter: 3.0)
    }
    
    func startHeartbeat(timer: NSTimer){
        var url = server.heartBeatServiceUrl + "/" + GBNetwork.getMacId()
        Alamofire.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            
            if response?.statusCode == 200{
                self.netConnect = true
                self.count = 0
                println("netConnect ok,count = \(self.count)")
            }
            else{
                self.netConnect = false
                self.count++
                println("netConnect fail,count = \(self.count)")
                if self.count == 3{
                    self.count = 0
                    timer.invalidate()
                }
            }
        }
    }
    
    
    //register current ipad id to server，返回已经注册的id并保存
    func registerCurrentId(){
        let paras = ["id":"\(GBNetwork.getMacId())"]
        
        var id: NSString = ""

        Alamofire.request(.POST, reqBoxURL!, parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
//            println("response.code = \(response)")
//            println("data ==================== \(data)")
            
            if(error != nil){
                NSLog("注册当前id失败，error ＝ %@", error!.description)
                return
            }
            
            //如果注册成功，则保存当前的iPad的id至../Documents/idData.txt 目录文件中
            if(response?.statusCode == 200){
                id = (data?.objectForKey("id")) as! NSString
                self.idInfoSave(id)
            }
        }
        
    }
    
    
    //保存当前iPad的id,只在注册成功的情况下才保存id，否则不保存
    func idInfoSave(id: NSString) {
        var idFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
        println("该id保存地址 = \(idFilePath)")
        
//        var readData = NSData(contentsOfFile: idFilePath)
//        var content = NSString(data: readData!, encoding: NSUTF8StringEncoding)!
//        
//        if(content == id){
//            NSLog("当前ipad的id已保存")
//            return
//        }
        
        var b = id.writeToFile(idFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if b {
            NSLog("当前ipad的id保存成功")
        }
        else{
            NSLog("当前ipad的id保存失败，请重新保存id")
        }
    }
    
    
    //读取本地iddata.txt文本文件记否存在，存在则返回true，否则返回false。
    func IsIdFileExist() -> Bool {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
   
        //判断该文件是否存在，则创建该iddata. txt文件
        var manager = NSFileManager.defaultManager()
        if !manager.fileExistsAtPath(filePath){
            return false
        }
        println("idData文件已存在")
        return true
    }
    
    
    //根据id获取ipad所需信息
    func createBox() -> GBBox{
        
        var result = GBBox()
        var idstr = NSString()
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
        
        var b = IsIdFileExist()
        
        //如果iddata文件夹不存在，则创建iddata.txt文件
        if !b{
            var manager = NSFileManager.defaultManager()
            var bCreateFile = manager.createFileAtPath(filePath, contents: nil, attributes: nil)
            if bCreateFile{
                println("idData文件创建成功")
                //idstr = GBNetwork.getMacId()
            }
        }
        
        NSLog("filePath = %@", filePath)
        var readData = NSData(contentsOfFile: filePath)
        idstr = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
        
        //如果不存在，则GBNetwork.getMacId()赋给id
        if (idstr.length <= 0){
            println("请重新注册id")
            self.registerCurrentId()
            idstr = GBNetwork.getMacId()
        }
        
        var urlString = "\(reqBoxURL!)/\(idstr)"
        NSLog("urlString = %@", urlString)
        var str = server.boxServiceUrl + "/" + GBNetwork.getMacId()
        
        Alamofire.request(.GET, str).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
            println("data = \(data)")
            println("response = \(response)")
            if error != nil{
                println("err = \(error)")
                println("获取用户信息失败，请检查网络设置后重试。。。")
                return
            }
            
            if response?.statusCode == 400{
                var resData: String = data?.objectForKey("error") as! String
                
                if (resData == "not find ID"){
                    self.registerCurrentId()
                    return
                }
                else if(resData == "type or name is nil"){
                    self.registerCurrentId()
                    UIAlertView(title: "当前id未注册", message: "请先注册id", delegate: self, cancelButtonTitle: "确定").show()
                    println("请至服务台注册当前id...")
                    return
                }
            }
            
            result.macId = data?.objectForKey("id") as! String
            result.type = data?.objectForKey("type") as? GBMeetingType
            result.name = data?.objectForKey("name") as! String
        }
        return result
    }
    
    
    //获取当前会议current
    func getCurrent(timer: NSTimer){
        var docPath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        
        var builder = Builder()
               
        Alamofire.request(.GET,server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
        
            println("getCurrent err = \(error)")
            
            if error != nil {
                self.current = builder.LocalCreateMeeting()
                return
            }
            
            let json = JSON(data!)
            var id = json["id"].stringValue
            
            if self.current.isEqual(nil)  {
                self.current = builder.CreateMeeting()
                DownLoadManager.isStart(true)
            }
            
            if(self.current.id == id) {
                return
            }
            
            self.current = builder.CreateMeeting()   
            DownLoadManager.isStart(true)
        }
    }
    
    
    
    
    
}





