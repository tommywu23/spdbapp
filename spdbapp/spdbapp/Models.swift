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

//meeting type
enum GBMeetingType {
    case HANGBAN, DANGBAN, DANGWEI, DONGSHI, dangzheng, ALL
}

class GBBase: NSObject {
    var basename = ""
}


class GBBox: GBBase {
    var macId : String = "11-22-33-44-55-66"
    var type : GBMeetingType?
    //add new name
    var name: String = ""
    
    override init(){
        super.init()
        
        //Defualt type = HANGBAN
        type = GBMeetingType.ALL
        macId = GBNetwork.getMacId()
        
        //add new name
        name = ""
    }
}


class GBMeeting: GBBase {
    var name: String = ""
    var type : GBMeetingType = .ALL
    var startTime: NSDate = NSDate()
    var status: Bool?
    var files:[GBDoc] = []
    
    var id: String = ""
    
}


class GBDoc: GBBase {
    var id: String = ""
    var index: Int = 0
    var count: Int = 0
    var type: GBMeetingType = .ALL
    var status: Bool?
    var pdfPath: String = ""
    var size: Int = 0
    var createAt: String = ""
    var path: String = ""
    var name: String = ""
}

