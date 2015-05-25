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
    
    
    //下载所有文件
    class func downLoadAllFile(){
        Alamofire.request(router.0, router.1).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            let json = JSON(data!)
            
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
                            return directoryURL.URLByAppendingPathComponent("\(filename)")
                        }
                        return temporaryURL
                    }
                    Alamofire.download(.GET, getPDFURL!, destination)
            }
            println("下载所有文件成功")
        }
      }
    }
    
    
    
    //下载json数据到本地并保存
    class func downLoadJSON(){
        
        Alamofire.request(router.0, router.1).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
            //println("\(jsonFilePath)")
            
            var manager = NSFileManager.defaultManager()
            if !manager.fileExistsAtPath(jsonFilePath){
                var b = manager.createFileAtPath(jsonFilePath, contents: nil, attributes: nil)
                if b{
                    println("file create ok")
                }
            }
            
            if(err != nil){
                NSLog("%@", err!)
                return
            }
    
            var jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)

            var b = jsondata?.writeToFile(jsonFilePath, atomically: true)
            if (b! == true) {
                NSLog("当前json保存成功")
            }
            else{
                NSLog("请重新 baocun json")
            }

        }
     }
    
}
