//
//  Models.swift
//  spdbapp
//
//  Created by tommy on 15/5/11.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Foundation

protocol GBModelBaseAciton {
    func Add()
    func Update()
    func Del()
    func Find()
}

enum GBConfType {
    case HANGBAN, DANGBAN, ALL
}

class GBBox {
    var macId : String = "11-22-33-44-55-66"
    var type : GBConfType
    
    init(){
        //Defualt type = HANGBAN
        type = GBConfType.HANGBAN
        macId = GBNetwork.getMacId()
    }
}

class GBConf {
    var name : String = ""
    var type : GBConfType = .HANGBAN
}

