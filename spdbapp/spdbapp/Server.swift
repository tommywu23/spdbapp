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
   
    let filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
    
    override init(){
        super.init()
        
        //self.IsCreateFileOK()
        
        var url = getIPStr()
        boxServiceUrl = "http://" + url + ":8088/box"
        meetingServiceUrl = "http://192.168.16.141:8080/meeting/current"
        fileServiceUrl = "http://192.168.16.141:8080/file/"
        heartBeatServiceUrl = "http://" + url + ":8088/heartbeat?id="
        
    }
    

    
    
    func getIPStr() -> String {
        
        var dict = NSMutableDictionary(contentsOfFile: NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt"))!
        
        if dict.count <= 0 {
            var value: AnyObject = "192.168.16.142"
            var key: NSCopying = "txtBoxURL"
            dict.setObject(value, forKey: key)
            var b = dict.writeToFile(NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt"), atomically: true) as Bool
        }
        
        //println("dict2 = \(dict.count)")
        
        var result = dict.objectForKey("txtBoxURL") as! String
        //println("dict2.urlValueresult = \(result)")
        return result
    }
    
    func showDetail(){
        var dict = NSMutableDictionary(contentsOfFile: self.filePath)!
        for (key,value) in dict{
            println("key = \(key)===while===value = \(value)")
        }
    }
    
    func defaultsIPStr() -> String{
        var dict = NSMutableDictionary()
        var result = "192.168.16.142"
        dict.setObject(result, forKey: "txtBoxURL")
        dict.writeToFile(self.filePath, atomically: true)
        return result
    }
    
    //创建SettingsConfig.txt存储配置界面的设定信息
    func IsCreateFileOK() -> Bool {
        
        var manager = NSFileManager.defaultManager()
        
        if !manager.fileExistsAtPath(self.filePath){
            var b = manager.createFileAtPath(self.filePath, contents: nil, attributes: nil)
            if b {
                NSLog("settings存储URL配置文本文件创建成功")
                return true
            }
            NSLog("settings存储URL配置文本文件创建失败")
            return false
        }
        NSLog("settings存储URL配置文本文件已存在")
        return true
    }
    
}
