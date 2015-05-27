//
//  HTTPController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/5/14.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Alamofire

class HTTPController: NSObject {
    
    //定义一个代理
    var delegate: HttpProtocol?
    
    //接收网址，回调代理的方法传回数据
    func onSearch(url: String){
        Alamofire.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, error) -> Void in
            if(error != nil)
            {
                println("网络错误，将读取本地会议文件")
                return
            }
            
            self.delegate?.didReceiveResult(data!)
        }
    }
}

//定义http协议
protocol HttpProtocol{
    func didReceiveResult(results: AnyObject)
}