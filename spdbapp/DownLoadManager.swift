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
                println("json数据信息已经存在")
                return true
            }
            return false
        }
        return false
    }
    //判断当前会议所有文件是否已经存在
    class func isSameFileData(filename: String) -> Bool {
        
        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        //var fileDir = localJSONPath.stringByAppendingPathComponent("\(meetingName)")
        var filePath = localJSONPath.stringByAppendingPathComponent("\(filename)")
        var filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(filePath){
                println("本地文件\(filePath)")
                return true
        }
        return false
    }
    //判读当前会议文件夹是否存在
//    class func isExistFileDir(meetingName:String) -> Bool{
//        var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(meetingName)")
//        println("会议文件夹\(meetingName)")
//        var manager = NSFileManager.defaultManager()
//        if !manager.fileExistsAtPath(jsonFilePath){
//            manager.createDirectoryAtPath(jsonFilePath, withIntermediateDirectories: true, attributes: nil, error: nil)
//        println("会议文件夹已创建")
//            return true
//        }
//        println("会议文件夹存在")
//        return false
//        }

      //下载所有文件
    class func downLoadAllFile(){
        
        Alamofire.request(router.0, router.1).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            if(err != nil){
                NSLog("%@", err!)
                //return
            }
            
            let json = JSON(data!)
            let jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)
            var meetingName = json["name"].stringValue
            if let filesInfo = json["files"].array
            {
                //获取所有的文件信息
                //println("fileInfo = \(filesInfo)")
                for var i = 0 ;i < filesInfo.count ; i++ {
                    var file = filesInfo[i]
                    var fileid = file["_id"].stringValue
                    var filename = file["name"].stringValue
        
                    var getPDFURL = NSURL(string: "http://192.168.16.141:8080/file/" + fileid + ".pdf")
        
                    let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = {
                        (temporaryURL, response) in
                        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.AllDomainsMask)[0] as? NSURL{
                            return directoryURL.URLByAppendingPathComponent("\(meetingName)/\(filename)")
                        }
                        return temporaryURL
                    }
                    //var dirExist = self.isExistFileDir(meetingName)
                    //判读本地file是否和服务器里的一样
                    var b = self.isSameFileData(filename)
                    if b{
                        println("会议文件已经存在")
                        return
                    }
                    println(b)
                    Alamofire.download(.GET, getPDFURL!, destination)
                }
            println("下载所有文件成功")
            }
        }
    }
    
    
    
    //下载json数据到本地并保存
    class func downLoadJSON(){
        
        Alamofire.request(router.0, router.1).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            //println("\(jsonFilePath)")
            
            if(err != nil){
                println("从服务器获取当前会议数据出错\(err)")
                return
            }
            var jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)
            var json = JSON(data!)
            var meetingName = json["name"].stringValue
            var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(meetingName)/jsondata.txt")
            var bool = self.isSameJSONData(jsondata!)
            if !bool{
                var b = jsondata?.writeToFile(jsonFilePath, atomically: true)
                if (b == true) {
                    NSLog("当前会议json保存成功")
                }
                else{
                    NSLog("请重新保存json")
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
