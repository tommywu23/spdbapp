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
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(fileName)")
        
        var filemanager = NSFileManager.defaultManager()
        
        if filemanager.fileExistsAtPath(filePath){
            return true
        }
        return false
    }
    
    class func isStart(bool: Bool){
        if bool == true{
            downLoadAllFile()
            downLoadJSON()
        }
    }
    
    
    //-> (currentSeq: Int, totalCount: Int) -> (name: String, downSize: Int, allSize: Int)
    class func downLoadAllFile(){
        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            if(err != nil){
                NSLog("download allsourcefile error ==== %@", err!)
                return
            }
            
            let json = JSON(data!)
            var meetingid = json["id"].stringValue
            
            if let agendasInfo = json["agenda"].array
            {
                //获取所有的议程信息
                for var i = 0 ;i < agendasInfo.count ; i++ {
                    var agendas = agendasInfo[i]
                    //获取当前agenda对应的source文件
//                    var sources = agendas["source"].array!
                    
                    if let fileSourceInfo = agendas["source"].array{
                        for var j = 0 ; j < fileSourceInfo.count ; j++ {
                            
                        var fileid = fileSourceInfo[j].stringValue
                        var filename = String()

                        //根据source的id去寻找对应的name
                        if let sources = json["source"].array{
                            for var k = 0 ; k < sources.count ; k++ {
                                if fileid == sources[k]["id"].stringValue{
                                    filename = sources[k]["name"].stringValue
                                }
                            }
                        }
                        
                        //http://192.168.16.141:10086/gbtouch/meetings/73c000fa-2f5b-44ef-9dff-addba27d8e18/6d1f55b9-9773-4932-a3c1-8fcc88b8ead1.pdf
                        var filepath = "http://192.168.16.141:10086/gbtouch/meetings/\(meetingid)/\(fileid).pdf"
//                        println("source count  filepath==============\(filepath)")
                        var getPDFURL = NSURL(string: filepath)
                            
                        let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = {
                            (temporaryURL, response) in
                            if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.AllDomainsMask)[0] as? NSURL{
                                var filenameURL = directoryURL.URLByAppendingPathComponent("\(filename)")
                                return filenameURL
                            }
                            return temporaryURL
                        }
        
                        println("file name = \(filename)")
                        //判断../Documents是否存在当前filename为名的文件，如果存在，则返回；如不存在，则下载文件
                        var b = self.isSamePDFFile(filename)
                        if b == false{
    //                        Alamofire.download(.GET, getPDFURL!, destination)
                            
                            Alamofire.download(.GET, getPDFURL!, destination).progress {
                                (_, totalBytesRead, totalBytesExpectedToRead) in
                                dispatch_async(dispatch_get_main_queue()) {
//                                    println("正在下载\(filename)，文件下载进度为：\(Float(totalBytesRead))/\(Float(totalBytesExpectedToRead))")
                                    if totalBytesRead == totalBytesExpectedToRead {
                                        println("\(filename)   下载成功")
                                    }
                                }
                            }
                        }else if b == true{
                            println("\(filename)文件已存在")
                        }
                    }
                }
              }
            }
        }
    }

    
    class func isFileDownload(name: String) -> Bool{
        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(name)")
        var manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(filepath){
            return true
        }else{
            return false
        }
    }
    
    
    //下载json数据到本地并保存
    class func downLoadJSON(){
        
        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
            
            //println("\(jsonFilePath)")
            
            if(err != nil){
                println("下载当前json出错，error ===== \(err)")
                return
            }
            var jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)
            
            //如果当前json和服务器上的json数据不一样，则保存。保存成功提示：当前json保存成功，否则提示：当前json保存失败。
            var bool = self.isSameJSONData(jsondata!)
            if !bool{
                var b = jsondata?.writeToFile(jsonFilePath, atomically: true)
                if (b! == true) {
                    NSLog("当前json保存成功")
                }
                else{
                    NSLog("当前json保存失败")
                }
                
            }
            
            var manager = NSFileManager.defaultManager()
            if !manager.fileExistsAtPath(jsonFilePath){
                var b = manager.createFileAtPath(jsonFilePath, contents: nil, attributes: nil)
                if b{
                    println("创建json成功")
                }
            }
        }
    }
    
}
