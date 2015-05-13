//
//  AppManager.swift
//  spdbapp
//
//  Created by tommy on 15/5/11.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Foundation
import Alamofire



class AppManager : NSObject {
    var current : GBConf?
    var local : GBBox?
    dynamic var connect: Bool = true

    override init(){
        super.init()
        local = GBBox()
        Alamofire.request(Router.RegBox(["id":local!.macId])).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            
            if(error != nil){
                self.connect = false
            }

            if(response?.statusCode != 200){
                println("res = \(response?.statusCode)")
            }
        }
    }

}