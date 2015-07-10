//
//  DeleteManager.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/2.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class DeleteManager: NSObject {
   
    
    class func deleteInfo(docPathExt: String){
        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        var txtpath = filepath.stringByAppendingPathComponent(docPathExt)
        
        var manager = NSFileManager.defaultManager()
        
        var isTxtExist = manager.fileExistsAtPath(txtpath)
        if isTxtExist{
            var b = manager.removeItemAtPath(txtpath, error: nil)
            if b {
                println("\(docPathExt)文件删除成功")
            }
        }
    }
    
    class func deleteAllInfo(){
        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        var manager = NSFileManager.defaultManager()
        if let filelist = manager.contentsOfDirectoryAtPath(filepath, error: nil){
            
            println("file = \(filelist)")
            
            var count = filelist.count
            for (var i = 0 ; i < count ; i++ ){
                var docpath = filepath.stringByAppendingPathComponent("\(filelist[i])")
                var b = manager.removeItemAtPath(docpath, error: nil)
                if b{
                    println("\(filelist[i])文件删除成功")
                }
            }
        }
    }
    
}
