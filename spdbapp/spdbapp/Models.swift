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
    case HANGBAN, DANGBAN, DANGWEI, DONGSHI, ALL
}


class GBBase: NSObject {
    var basename = ""
}

class GBUser: NSObject{
    var name = String()
    var password = String()
    var type: GBMeetingType?
}

class GBServer:NSObject{
    var id = String()
    var name = String()
    var chairname = String()
    var service = String()
    var createtime = String()
}


class GBBox: GBBase {
    var macId : String = "11-22-33-44-55-66"
    var type : GBMeetingType?
    var name: String = ""

    
    var connect: Bool = false
    
    override init(){
        super.init()
        type = GBMeetingType.ALL
        macId = GBNetwork.getMacId()
        name = ""

        connect = false
    }
}


class GBMeeting: GBBase {
    var name: String = ""
//    var type : GBMeetingType = .ALL
    var startTime: NSDate = NSDate()
    var status: Bool?
//    var files:[GBDoc] = []
    
    var id: String = ""
    var agenda = [GBAgenda]()
    var source = [GBSource]()
}

class GBSource {
    var id: String = ""
    var type: String = ""
    var name: String = ""
    var sourextension: String = ""
    var sourpublic: String = ""
    var link: String = ""
    var aidlink: String = ""
    var local: String = ""
}

class GBAgenda {
    var id: String = ""
    var name: String = ""
    var source: [String] = []
    var index: String = ""
    var starttime: String = ""
    var endtime: String = ""
    var reporter: String = ""
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

