//
//  Builder.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/5/14.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class Builder: NSObject {
    
    
    //Create Meeting
    func CreateMeeting(json: JSON) -> GBMeeting {
        
        var router = Router.GetCurrentMeeting()
        var current = GBMeeting()
        var url = NSURL(string: "http://192.168.16.141:8080/meeting/current")
        
        
        var data = NSData(contentsOfURL: url!)
        if(data != nil){
        var json: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
        
        var fileLists = json.objectForKey("files") as! NSMutableArray
        
        current.id = json["_id"] as! String
        current.name = json["name"] as! String

        }
        return current
        
    }
    //离线状态下Create Meeting
    func LocalCreateMeeting() -> GBMeeting {
        var current = GBMeeting()
        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
        var filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(localJSONPath){
            var jsonLocal = filemanager.contentsAtPath(localJSONPath)
            var json: AnyObject = NSJSONSerialization.JSONObjectWithData(jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
            var fileLists = json.objectForKey("files") as! NSMutableArray
            current.id = json["_id"] as! String
            current.name = json["name"] as! String
            println(current.name)
        }
        return current
    }
    
}




//var name : String = ""
//var type : GBMeetingType = .ALL
//var startTime: NSDate = NSDate()
//var status: Bool?
//var files:[GBDoc] = []
//
//var id: String = ""

//            filelist = json["files"].array!
//            for var i = 0 ; i < filelist.count ; i++ {
//                var fileInfo = filelist[i]
//                current.id = fileInfo["_id"].stringValue
//                current.name = fileInfo["name"].stringValue
//             NSLog("current.id ============= %@",current.id)
//            }