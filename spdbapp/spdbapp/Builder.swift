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
    
    //Create Meeting online
    func CreateMeeting() -> GBMeeting {
        
        var current = GBMeeting()
        var url = NSURL(string: server.meetingServiceUrl)
        
        var data = NSData(contentsOfURL: url!)
        if(data != nil){
            var json: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
            
            current.id = json["id"] as! String
            current.name = json["name"] as! String
            println(current.name)
            
        }
        return current
    }


    //Create Meeting offline
    func LocalCreateMeeting() -> GBMeeting {
        
        var current = GBMeeting()
        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
        var filemanager = NSFileManager.defaultManager()
        
        if filemanager.fileExistsAtPath(localJSONPath){
            var jsonLocal = filemanager.contentsAtPath(localJSONPath)
            var json: AnyObject = NSJSONSerialization.JSONObjectWithData(jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
            
            current.id = json["id"] as! String
            current.name = json["name"] as! String
            println(current.name)
        }
        return current
    }

}

