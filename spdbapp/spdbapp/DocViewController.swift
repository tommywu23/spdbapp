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
        
        btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        
        if appManager.netConnect == true {
            self.netConnectSuccess()
        }else{
            //btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }

    
    func getReconn(){
        self.netConnectLinking()
        
        appManager.starttimer()
    }
    
    
    func checkstatus(timer: NSTimer){
        //println("3===============\(appManager.netConnect)=====================3")
        if appManager.netConnect {
            self.netConnectSuccess()
            self.lblShowState.reloadInputViews()
            self.btnReconnect.reloadInputViews()

        }
        else{
            self.netConnectFail()
            self.lblShowState.reloadInputViews()
            self.btnReconnect.reloadInputViews()
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
        self.lblShowState.textColor = UIColor(red: 37/255, green: 189/255, blue: 54/255, alpha: 1.0)
        self.lblShowState.text = "网络已连接"
        
        self.btnReconnect.hidden = true
        
    }
    
    func netConnectLinking(){
        btnReconnect.backgroundColor = UIColor.grayColor()
        btnReconnect.enabled = false
        
        lblShowState.text = "网络正在连接..."
        lblShowState.textColor = UIColor.blueColor()
    }
    
    func GoBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
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
