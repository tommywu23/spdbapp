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
    
    
    
    override init(){
        super.init()
        var url = getIPStr()
        boxServiceUrl = "http://" + url + ":8088/box"
        meetingServiceUrl = "http://192.168.16.141:8080/meeting/current"
        fileServiceUrl = "http://192.168.16.141:8080/file/"
        heartBeatServiceUrl = "http://" + url + ":8088/heartbeat?id="
    }
    
    
    func getIPStr() -> String {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        var result = String(contentsOfFile: filePath)!
        return result
    }
    
    
    func defaultsIPStr() -> String{
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        var result = "192.168.16.142"
        result.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        return result
    }
    
    //创建SettingsConfig.txt存储配置界面的设定信息
    func IsCreateFileOK() -> Bool {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        var manager = NSFileManager.defaultManager()
        
        if !manager.fileExistsAtPath(filePath){
            var b = manager.createFileAtPath(filePath, contents: nil, attributes: nil)
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
