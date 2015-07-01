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
        
        self.IsCreateFileOK()
        
        var url = getInitialIP()
        
        boxServiceUrl = "http://" + url + ":9999/box"
        meetingServiceUrl = "http://" + url + ":9999/meeting"
        fileServiceUrl = "http://" + url + ":9999/file/"
        heartBeatServiceUrl = "http://" + url + ":9999/heartbeat"
    }
    
    func getInitialIP() -> String {
        var dict = NSMutableDictionary(contentsOfFile: filePath)
//        println("dict ------- \(dict!)")
        var dicDefault = NSMutableDictionary(capacity: 1)
        dicDefault.setObject("192.168.21.90", forKey: "txtBoxURL")
        dicDefault.writeToFile(filePath, atomically: true)
        return dicDefault.objectForKey("txtBoxURL") as! String
    }
    
    func showDetail(){
        var dict = NSMutableDictionary(contentsOfFile: self.filePath)!
        for (key,value) in dict{
            println("key = \(key)===while===value = \(value)")
        }
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
        //NSLog("settings存储URL配置文本文件已存在")
        return true
    }
    
    
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
