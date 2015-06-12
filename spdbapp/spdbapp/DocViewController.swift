//
//  DocViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/8.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class DocViewController: UIViewController {
    
    var url : String = ""
    
    var fileIDInfo: String?
    var fileNameInfo: String?
    
    var server = Server()
    var timer = Poller()
    
    @IBOutlet weak var docView: UIWebView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnReconnect: UIButton!
    @IBOutlet weak var lblShowState: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.start(self, method: "checkstatus:",timerInter: 5.0)
        
        loadLocalPDFFile()
        
        btnBack.layer.cornerRadius = 8
        btnReconnect.layer.cornerRadius = 8
        btnBack.addTarget(self, action: "GoBack", forControlEvents: UIControlEvents.TouchUpInside)
        
        if appManager.netConnect == true {
           self.netConnectSuccess()
        }else{
            btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }

    
    func getReconn(){
        btnReconnect.backgroundColor = UIColor.grayColor()
        btnReconnect.enabled = false
        lblShowState.text = "网络正在连接..."
        lblShowState.textColor = UIColor.blueColor()
        
        
        appManager.starttimer()
    }
    
    
    func checkstatus(timer: NSTimer){
        //println("3===============\(appManager.netConnect)=====================3")
        if appManager.netConnect {
            self.netConnectSuccess()
        }
        else{
            self.netConnectFail()
        }
        
    }
    
    
    func netConnectFail(){
        self.lblShowState.textColor = UIColor.redColor()
        self.lblShowState.text = "网络连接失败"
        
        self.btnReconnect.hidden = false
        self.btnReconnect.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 249/255, alpha: 1)
        self.btnReconnect.enabled = true
    }
    
    func netConnectSuccess(){
        self.lblShowState.textColor = UIColor.greenColor()
        self.lblShowState.text = "网络已连接"
        
        self.btnReconnect.hidden = true
        
    }
    
    func GoBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startHeartbeat(timer: NSTimer){
//         appManager.startHeartbeat(timer)

//        var url = server.heartBeatServiceUrl + GBNetwork.getMacId()
//        Alamofire.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
//            
//            if response?.statusCode == 200{
//                appManager.netConnect = true
//                self.lblShowState.textColor = UIColor.greenColor()
//                self.lblShowState.text = "网络已连接"
//                self.btnReconnect.hidden = true
//                
//                self.count = 0
//                println("netConnect ok3,count = \(self.count)")
//                
//            }else{
//                self.count++
//                println("netConnect fail3,count = \(self.count)")
//                if self.count == 3{
//                    appManager.netConnect = false
//                    println("netConnect daoshijian3,count = \(self.count)")
//                    self.count = 0
//                    timer.invalidate()
//                    self.lblShowState.textColor = UIColor.redColor()
//                    self.lblShowState.text = "网络连接失败"
//                    self.btnReconnect.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 249/255, alpha: 1)
//                    self.btnReconnect.enabled = true
//                }
//            }
//        }
    }
    
    //获取本地pdf文档
    func loadLocalPDFFile(){
        var filePath: String = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(self.fileNameInfo!)")
        var urlString = NSURL(fileURLWithPath: "\(filePath)")
        var request = NSURLRequest(URL: urlString!)
        self.docView.loadRequest(request)
        println("path = \(filePath)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
