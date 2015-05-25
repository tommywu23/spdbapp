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

        timer = NSTimer(timeInterval: 2, target: obj, selector: method , userInfo: nil, repeats: true)
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
    var reqData: String = ""
    var files: GBMeeting?
    var local : GBBox?
    
    let baseURL : String = "http://192.168.21.36:8080"
    var reqBoxURL : String?

    
    override init(){
        super.init()
        reqBoxURL = self.baseURL + "/box"
        //定时器每隔2s检测当前current是否发生变化
        var getCurrentPoller = Poller()
        getCurrentPoller.start(self, method: "getCurrent:")

        
        local = createBox()
        
        DownLoadManager.downLoadJSON()
        
        //println("reqdata = \(reqData)")
        
    }
    
    
    //register current ipad id to server，返回已经注册的id并保存
    func registerCurrentId(){
        let paras = ["id":GBNetwork.getMacId()]
        
        var id: NSString = ""
        Alamofire.request(.POST, reqBoxURL! ,parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request,response, data, error) -> Void in
            println("data = \(data!)")
            
            if(error != nil){
                NSLog("%@", error!)
            }
            
            if(response?.statusCode != 200){
                println("res = \(response?.statusCode)")
                return
            }
            
            //如果注册成功，则保存当前的iPad的id至../Documents/idData.txt 目录文件中
            if(response?.statusCode == 200){
                id = (data?.objectForKey("id")) as! NSString
                self.idInfoSave(id)
            }
        }
    }
    
    
    //保存当前iPad的id
    func idInfoSave(id: NSString) {
        var idFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
        println("iffilepath = \(idFilePath)")
        var readData = NSData(contentsOfFile: idFilePath)
        var content = NSString(data: readData!, encoding: NSUTF8StringEncoding)!

        if(content == id){
            return
        }
        
        var b = id.writeToFile(idFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if b {
            NSLog("当前ipad的id保存成功")
        }
        else{
            NSLog("请重新注册id")
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
        //dynamic var respData = ""
        
        var result = GBBox()
        var idstr = NSString()
        var b = IsLocalExistID()
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")

        //如果iddata文件夹不存在，则创建iddata.txt文件
        if !b{
            var manager = NSFileManager.defaultManager()
            var bCreateFile = manager.createFileAtPath(filePath, contents: nil, attributes: nil)
            if bCreateFile{
                println("ok file create")
                idstr = GBNetwork.getMacId()
            }
        }
        
        var readData = NSData(contentsOfFile: filePath)
        idstr = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString

        //如果不存在，则GBNetwork.getMacId()赋给id
        if (idstr.length <= 0){
            println("chongxin zhuce")
            idstr = GBNetwork.getMacId()
        }
        
        var urlString = "\(reqBoxURL!)?id=\(idstr)"
        NSLog("idstr = %@", idstr)
        Alamofire.request(.GET, urlString).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            println("getdata = \(data!)")
            
            //若返回值为not find type or name则弹出“请重新注册”的对话框，并且将当前的idstr进行注册并保存
            if((data?.isEqual("not find type or name")) != nil){
                UIAlertView(title: "未注册id", message: "请先注册id", delegate: self, cancelButtonTitle: "重试").show()
                self.registerCurrentId()
                self.reqData = "not find type or name"
            }
            
            if(response?.statusCode == 200){
                result.macId = (data?.objectForKey("id")) as! String
                result.type = (data?.objectForKey("type")) as? GBMeetingType
                result.name = (data?.objectForKey("name")) as! String
            }
        }
        return result
    }
    
    //打印当前文件路径
    func printFilePath()-> String{
        var home = NSHomeDirectory()
        var docPath = home.stringByAppendingPathComponent("Documents")
        //NSLog("%@", docPath)
        return docPath
    }
    
    
    //获取当前会议current
    func getCurrent(timer: NSTimer){
        var router = Router.GetCurrentMeeting()
        
        Alamofire.request(router.0,router.1).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            
            var builder = Builder()
            if error != nil{
                
//                var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
//                var filemanager = NSFileManager.defaultManager()
//                
//                if filemanager.fileExistsAtPath(localJSONPath){
//                    let jsonLocal = filemanager.contentsAtPath(localJSONPath)
    
//                
//            }
                
                
            }
        
            let json = JSON(data!)
            // current meeting id
            var id = json["_id"].stringValue
            
            if self.current.isEqual(nil)  {
               self.current = builder.CreateMeeting(json)
                DownLoadManager.downLoadAllFile()
                DownLoadManager.downLoadJSON()
               NSLog("self.current.id = %@", self.current.id)
            }
            
             if(self.current.id == id) {
                return
            }
            self.current = builder.CreateMeeting(json)
            DownLoadManager.downLoadAllFile()
            //DownLoadManager.downLoadJSON()
        }
    }
 
}





