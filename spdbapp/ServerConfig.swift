//
//  ServerConfig.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/5.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class ServerConfig: NSObject {
    
    
    class func defaultsSettings() -> NSMutableDictionary{
         var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
         var settingsDict: NSMutableDictionary = NSMutableDictionary()
        
         settingsDict.setObject("192.168.16.142", forKey: "txtBoxURL")
        
         settingsDict.writeToFile(filePath, atomically: true)
         //println(settingsDict)
         return settingsDict
    }
    
    //创建SettingsConfig.txt存储配置界面的设定信息
    class func IsCreateFileOK() -> Bool {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        var manager = NSFileManager.defaultManager()
        
        if !manager.fileExistsAtPath(filePath){
            var b = manager.createFileAtPath(filePath, contents: nil, attributes: nil)
            if b {
                NSLog("settings 文本文件创建成功")
                return true
            }
            NSLog("settings 文本文件创建失败")
            return false
        }
        NSLog("settings 文本文件已存在")
        return true
    }

    
    class func getBoxService() -> String{
        var dict = getSettingsBundleInfo()
        var boxService = dict.objectForKey("txtBoxURL") as! String
        return "http://" + boxService + ":8088/box"
    }
    
    
    class func getMeetingService() -> String{
//        var dict = getSettingsBundleInfo()
//        var meetingService = dict.objectForKey("txtMeetingURL") as! String
//        return "http://" + meetingService + ":8080/meeting/current"
        
         return "http://192.168.16.141:8080/meeting/current"
    }

    class func getFileService() -> String{
//        var dict = getSettingsBundleInfo()
//        var meetingService = dict.objectForKey("txtMeetingURL") as! String
//        return "http://" + meetingService + ":8080/file/"
        return "http://192.168.16.141:8080/file/"
    }

    //var url = "http://192.168.16.142:8088/heartbeat?id=" + GBNetwork.getMacId()
    class func getHeartBeatService() -> String{
//        var dict = getSettingsBundleInfo()
//        var meetingService = dict.objectForKey("txtBoxURL") as! String
//        return "http://" + meetingService + ":8088/heartbeat?id=" + GBNetwork.getMacId()
        return "http://192.168.16.142:8088/heartbeat?id=" + GBNetwork.getMacId()
    }
    
    class func getSettingsBundleInfo() -> NSMutableDictionary {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        
        var dict = NSMutableDictionary(contentsOfFile: filePath)!
        for (key, value) in dict {
            println("key = \(key)  ==========  value = \(value)")
        }
        return dict
    }
    
    
  

    
}
