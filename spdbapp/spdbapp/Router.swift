//
//  Router.swift
//  spdbapp
//
//  Created by tommy on 15/5/13.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Alamofire
import Foundation

class Router{
    
    static let baseURLString = "http://192.168.16.141:8080"
        
    class  func GetCurrentMeeting() -> (Alamofire.Method, String)  {
        return  (Alamofire.Method.GET , baseURLString + "/meeting/current")
    }
    
    
}

