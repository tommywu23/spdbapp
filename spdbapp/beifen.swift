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
    
    func start(obj: NSObject, method: Selector) {
        stop()
        
        timer = NSTimer(timeInterval: 3, target: obj, selector: method , userInfo: nil, repeats: true)
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
    
    dynamic var current : GBMeeting = GBMeeting()
    
    dynamic var netConnect: Bool = false
    
    var count: Int = 0
    
    var files: GBMeeting?
    var local : GBBox?
    
    var reqBoxURL: String?
    
    override init(){
        super.init()
        
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        var dict = NSMutableDictionary(contentsOfFile: filePath)
        
        //配置url信息
        if dict?.count <= 0{
            ServerConfig.defaultsSettings()
        }else{
            dict = ServerConfig.getSettingsBundleInfo()
        }
        
        reqBoxURL = ServerConfig.getBoxService()
        
        //程序启动先创建Box，当box为空，则弹出对话框“当前id未注册”，否则程序轮询去getCurrent,获取当前会议。
        local = createBox()
        if ((local?.isEqual(nil)) != nil){
            UIAlertView(title: "当前id未注册", message: "请先注册id", delegate: self, cancelButtonTitle: "确定").show()
            return
        }
        
        //定时器每隔2s检测当前current是否发生变化
        var getCurrentPoller = Poller()
        getCurrentPoller.start(self, method: "getCurrent:")
        
        //定时器每隔一段时间去检测当前联网状态
        var timerHearbeat = Poller()
        timerHearbeat.start(self, method: "startHeartbeat:")
        
    }
    
    func startHeartbeat(timer: NSTimer){
        
        //var url = "http://192.168.16.142:8088/heartbeat?id=" + GBNetwork.getMacId()
        var url = ServerConfig.getHeartBeatService()
        Alamofire.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            
            if error != nil{
                return
            }
            
            if response?.statusCode == 200{
                self.netConnect = true
                //println("netConnect ok")
            }
        }
    }
    
    
    
    //register current ipad id to server，返回已经注册的id并保存
    func registerCurrentId(){
        let paras = ["id":GBNetwork.getMacId()]
        
        var id: NSString = ""
        Alamofire.request(.POST, reqBoxURL! ,parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request,response, data, error) -> Void in
            println("post data = \(data!)")
            
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
        
        var readData = NSData(contentsOfFile: idFilePath)
        var content = NSString(data: readData!, encoding: NSUTF8StringEncoding)!
        
        if(content == id){
            NSLog("当前ipad的id已保存")
            return
        }
        
        var b = id.writeToFile(idFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if b {
            NSLog("当前ipad的id保存成功")
        }
        else{
            NSLog("当前ipad的id保存失败，请重新保存id")
        }
    }
    
    
    //读取本地iddata.txt中的id，若不存在，则重新注册并返回id，否则直接返回iddata.txt中的id
    func IsLocalExistID() -> Bool {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
        
        //判断该文件是否存在，则创建该iddata. txt文件
        var manager = NSFileManager.defaultManager()
        if !manager.fileExistsAtPath(filePath){
            return false
        }
        return true
    }
    
    
    //根据id获取ipad所需信息
    func createBox() -> GBBox{
        
        var result = GBBox()
        var idstr = NSString()
        var b = IsLocalExistID()
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
        
        //如果iddata文件夹不存在，则创建iddata.txt文件
        if !b{
            var manager = NSFileManager.defaultManager()
            var bCreateFile = manager.createFileAtPath(filePath, contents: nil, attributes: nil)
            if bCreateFile{
                println("idData文件创建成功")
                idstr = GBNetwork.getMacId()
            }
        }
        NSLog("filePath = %@", filePath)
        var readData = NSData(contentsOfFile: filePath)
        idstr = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
        
        //如果不存在，则GBNetwork.getMacId()赋给id
        if (idstr.length <= 0){
            println("请重新注册id")
            idstr = GBNetwork.getMacId()
        }
        
        var urlString = "\(reqBoxURL!)?id=\(idstr)"
        NSLog("urlString = %@", urlString)
        
        Alamofire.request(.GET, urlString).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            if error != nil{
                println("当前id未注册，请先注册后使用，error = \(error!)")
                return
            }
            println("getdata = \(data!)")
            
            
            //若返回值为not find type or name则弹出“请重新注册”的对话框，并且将当前的idstr进行注册并保存
            if(response?.statusCode == 200){
                result.macId = (data?.objectForKey("id")) as! String
                result.type = (data?.objectForKey("type")) as? GBMeetingType
                result.name = (data?.objectForKey("name")) as! String
            }
            else {
                UIAlertView(title: "当前id未注册", message: "请先注册id", delegate: self, cancelButtonTitle: "确定").show()
                self.registerCurrentId()
            }
        }
        return result
    }
    
    
    //获取当前会议current
    func getCurrent(timer: NSTimer){
        //var router = Router.GetCurrentMeeting()
        var docPath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        
        var builder = Builder()
        
        Alamofire.request(.GET,ServerConfig.getMeetingService()).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            if error != nil {
                //网络出错时调用LocalCreateMeeting 方法，从本地获取会议资料创建会议
                println("会议信息将直接从本地读取，本地文件地址为\(docPath)")
                self.current = builder.LocalCreateMeeting()
                return
            }
            
            
            let json = JSON(data!)
            var id = json["_id"].stringValue
            
            if self.current.isEqual(nil)  {
                self.current = builder.CreateMeeting()
                
                DownLoadManager.isStart(true)
                
                //                DownLoadManager.downLoadAllFile()
                //                DownLoadManager.downLoadJSON()
            }
            
            if(self.current.id == id) {
                return
            }
            
            self.current = builder.CreateMeeting()
            DownLoadManager.isStart(true)
            
            //            DownLoadManager.downLoadAllFile()
            //            DownLoadManager.downLoadJSON()
        }
    }
    
    
    
    
    
}





//
//  beifen.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/8.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class beifen: NSObject {
   
}



//根据id获取ipad所需信息
func createBox() -> GBBox{
    
    var result = GBBox()
    var idstr = NSString()
    var b = IsIdFileExist()
    var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
    
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
    
    var urlString = "\(reqBoxURL!)?id=\(idstr)"
    NSLog("urlString = %@", urlString)
    
    
    getBoxResult { (boxResult) -> () in
        if let data: AnyObject = boxResult {
            println("result = \(boxResult)")
            result.macId = data.objectForKey("id") as! String
            result.type = data.objectForKey("type") as? GBMeetingType
            result.name = data.objectForKey("name") as! String
            
        }
        
    }
    
    //        Alamofire.request(.GET, urlString).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
    //            //当错误类型为Could not connect to the server.，则提示当前网络连接失败，并返回
    //            if error?.localizedDescription == "Could not connect to the server." {
    //                println("当前网络连接失败，请检查网络连接后重试...")
    //                return
    //            }
    //            if error != nil{
    //                println("当前id未注册，请先注册后使用，error = \(error!)")
    //                self.registerCurrentId()
    //                return
    //            }
    //            println("getdata = \(data!)")
    //
    //
    //            //NSOperationQueue.mainQueue().
    //
    //            //若返回值为not find type or name则弹出“请重新注册”的对话框，并且将当前的idstr进行注册并保存
    //            if(response?.statusCode == 200){
    //                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
    //                    result.macId = (data?.objectForKey("id")) as! String
    //                    result.type = (data?.objectForKey("type")) as? GBMeetingType
    //                    result.name = (data?.objectForKey("name")) as! String
    //                })
    //
    //            }
    //            else {
    //                //**
    //                //self.registerCurrentId()
    //                //**
    //            }
    //        }
    
    //        var request = NSURLRequest(URL: NSURL(string: urlString)!)
    //        var queue = NSOperationQueue()
    //
    //        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response: NSURLResponse!, data: NSData!, err: NSError!) -> Void in
    //            println("data = \(data)")
    //            var jsondata: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments, error: nil)!
    //            println("json=\(jsondata)")
    //
    //            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
    //                result.name = jsondata.objectForKey("name") as! String
    //                result.macId = jsondata.objectForKey("id") as! String
    //
    //                var enumStr = jsondata.objectForKey("type") as! String
    //                println("enumStr = \(enumStr)")
    //                result.type = self.EnumParser(enumStr)
    //            })
    //        }
    
    
    println("name = \(result.name)")
    println("id = \(result.macId)")
    println("type = \(result.type)")
    
    
    //        var request = NSURLRequest(URL: NSURL(string: urlString)!)
    //        var response: NSURLResponse?
    //        var err = NSErrorPointer()
    //        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: err) as NSData?
    //
    //        println("error = \(err)")
    //
    //        var error: NSError?
    //        var jsondata: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments, error: err)!
    //        println("json=\(jsondata)")
    //
    //        result.name = jsondata.objectForKey("name") as! String
    //        result.macId = jsondata.objectForKey("id") as! String
    //
    //        var enumStr = jsondata.objectForKey("type") as! String
    //        println("enumStr = \(enumStr)")
    //        result.type = EnumParser(enumStr)
    //
    //        println("name = \(result.name)")
    //        println("id = \(result.macId)")
    //        println("type = \(result.type)")
    
    return result
}


func getBoxResult(completionHandler: (boxResult: AnyObject?) -> ()){
    var session = NSURLSession.sharedSession()
    var str = "http://192.168.16.142:8088/box?id=AA62C878-D10E-4386-A582-0D6084ABD6B0"
    var urlStr = NSURL(string: str)!
    let task = session.dataTaskWithURL(urlStr, completionHandler: { (data, response, err) -> Void in
        //println("code = \(response.description)")
        if err != nil{
            println("err = \(err.description)")
        }
        println("data = \(data)")
        completionHandler(boxResult: data)
    })
    task.resume()
}

//将从服务器上读取的数据转换为GBMeetingType
func EnumParser(enumStr: String) -> GBMeetingType {
    if enumStr == "dongshihui"{
        return GBMeetingType.DONGSHI
    }else if enumStr == "hangban"{
        return GBMeetingType.HANGBAN
    }else if enumStr == "dangzheng"{
        return GBMeetingType.DANGBAN
    }else if enumStr == "dangweihui"{
        return GBMeetingType.DANGWEI
    }else {
        return GBMeetingType.ALL
    }
}
