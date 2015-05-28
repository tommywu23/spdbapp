//
//  DownLoadFiles.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/5/19.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class DownLoadManager: NSObject {
    
    static var router = Router.GetCurrentMeeting()
    
    
    //判断当前文件夹是否存在jsondata数据，如果不存在，则继续进入下面的步骤
    //如果存在该数据，则判断当前json与本地jsonlocal是否一致，如果一致，则打印 json数据信息已经存在，return
    class func isSameJSONData(jsondata: NSData) -> Bool {
        
        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
        var filemanager = NSFileManager.defaultManager()
        
        if filemanager.fileExistsAtPath(localJSONPath){
            let jsonLocal = filemanager.contentsAtPath(localJSONPath)
            
            if jsonLocal == jsondata {
                //println("json数据信息已经存在")
                return true
            }
            return false
        }
        return false
    }
    
    
    class func isSamePDFFile(fileName: String) -> Bool {
        
        
        var docPath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        var filePath = docPath.stringByAppendingPathComponent("\(fileName)")
        //println("path = \(filePath)")
        
        var filemanager = NSFileManager.defaultManager()
        
        if filemanager.fileExistsAtPath(filePath){
            return true
        }
        return false
    }
    
    
    
    //下载所有文件
    class func downLoadAllFile(){
        
        Alamofire.request(router.0, router.1).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            if(err != nil){
                NSLog("%@", err!)
                //return
            }
            
            let json = JSON(data!)
            let jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)
            
            let meetingName = json["name"].stringValue
            
            if let filesInfo = json["files"].array
            {
                //获取所有的文件信息
                for var i = 0 ;i < filesInfo.count ; i++ {
                    var file = filesInfo[i]
                    var fileid = file["_id"].stringValue
                    var filename = file["name"].stringValue
                    var filepath = "http://192.168.16.141:8080/file/" + fileid + ".pdf"
                    
                    //println("filename = \(filename)")
                    var getPDFURL = NSURL(string: filepath)
                    
                    
                    let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = {
                        (temporaryURL, response) in
                        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.AllDomainsMask)[0] as? NSURL{
                            var filenameURL = directoryURL.URLByAppendingPathComponent("\(filename)")
                            
                            return filenameURL
                        }
                        return temporaryURL
                    }
                    
                    //判断../Documents是否存在当前filename为名的文件，如果存在，则返回；如不存在，则下载文件
                    var b = self.isSamePDFFile(filename)
                    
                    if b == false{
                        Alamofire.download(.GET, getPDFURL!, destination)
                        println("下载\(filename)成功")
                    }
                }
            }
        }
    }
    
    
    
    //下载json数据到本地并保存
    class func downLoadJSON(){
        
        Alamofire.request(router.0, router.1).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
            //println("\(jsonFilePath)")
            
            if(err != nil){
                println("从服务器获取当前会议数据出错\(err)")
                //NSLog("%@", err!)
                return
            }
            var jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)
            
            var bool = self.isSameJSONData(jsondata!)
            if !bool{
                var b = jsondata?.writeToFile(jsonFilePath, atomically: true)
                if (b! == true) {
                    NSLog("当前json保存成功")
                }
                else{
                    NSLog("请重新 baocun json")
                }
                
            }
            
            var manager = NSFileManager.defaultManager()
            if !manager.fileExistsAtPath(jsonFilePath){
                var b = manager.createFileAtPath(jsonFilePath, contents: nil, attributes: nil)
                if b{
                    println("file create ok")
                }
            }
        }
    }
    
}
