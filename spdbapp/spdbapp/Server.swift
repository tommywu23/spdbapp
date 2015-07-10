//
//  Server.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/8.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Foundation

class Server: NSObject {
    var boxServiceUrl = String()
    var meetingServiceUrl = String()
    var fileServiceUrl = String()
    var heartBeatServiceUrl = String()
    var loginServiceUrl = String()
   
    let filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
    
    override init(){
        super.init()
        
//        self.IsCreateFileOK()
        
        var url = getInitialIP()
        
//        boxServiceUrl = "http://192.168.16.142:18080/v1/box"
//        meetingServiceUrl = "http://192.168.16.142:18080/v1/current"
//        heartBeatServiceUrl = "http://192.168.16.142:18080/v1/heartbeat"
        
        boxServiceUrl = "http://" + url + ":18080/v1/box"
        meetingServiceUrl = "http://" + url + ":18080/v1/current"
        heartBeatServiceUrl = "http://" + url + ":18080/v1/heartbeat"
        loginServiceUrl = "http://192.168.16.141:10000/user/login"
    }
    
    func getInitialIP() -> String {
        var defaults = NSUserDefaults.standardUserDefaults()
        println("defaults = \(defaults)")
        var value = defaults.stringForKey("txtBoxURL")
        println("url = \(value)")
        if (value?.isEmpty == nil) {
            defaults.setObject("192.168.16.142", forKey: "txtBoxURL")
            defaults.synchronize()
            return defaults.objectForKey("txtBoxURL") as! String
        }
        
        defaults.synchronize()
        return value!
    }
    
    
    //创建SettingsConfig.txt存储配置界面的设定信息
//    func IsCreateFileOK() -> Bool {
//        
//        var manager = NSFileManager.defaultManager()
//        
//        if !manager.fileExistsAtPath(self.filePath){
//            var b = manager.createFileAtPath(self.filePath, contents: nil, attributes: nil)
//            if b {
//                NSLog("settings存储URL配置文本文件创建成功")
//                return true
//            }
//            NSLog("settings存储URL配置文本文件创建失败")
//            return false
//        }
//        //NSLog("settings存储URL配置文本文件已存在")
//        return true
//    }
    
    
    func clearHistoryInfo(type: String){
        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        var manager = NSFileManager.defaultManager()
        if let filelist = manager.contentsOfDirectoryAtPath(filepath, error: nil){
            
            println("file = \(filelist)")
            
            var count = filelist.count
            for (var i = 0 ; i < count ; i++ ){
                if filelist[i].pathExtension == type{
                    var docpath = filepath.stringByAppendingPathComponent("\(filelist[i])")
                    var b = manager.removeItemAtPath(docpath, error: nil)
                    if b{
                        println("\(filelist[i])文件删除成功")
                    }
                }
            }
        }
    }
    
}
