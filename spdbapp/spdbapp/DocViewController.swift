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
    
    var timer = Poller()
    
    @IBOutlet weak var docView: UIWebView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnReconnect: UIButton!
    @IBOutlet weak var lblShowState: UILabel!
    @IBOutlet weak var lblShowUserName: UILabel!
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.start(self, method: "checkstatus:",timerInter: 5.0)
        
        loadLocalPDFFile()
        
        btnBack.layer.cornerRadius = 8
        btnReconnect.layer.cornerRadius = 8
        btnBack.addTarget(self, action: "GoBack", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        btnReconnect.layer.cornerRadius = 8
   
        
        if appManager.netConnect == true {
            ShowToolbarState.netConnectSuccess(self.lblShowState, btn: self.btnReconnect)
        }
        
        self.getName()
    }

    
    func getReconn(){
        ShowToolbarState.netConnectLinking(self.lblShowState, btn: self.btnReconnect)
        appManager.starttimer()
    }
    
    func checkstatus(timer: NSTimer){
        if appManager.netConnect {
            ShowToolbarState.netConnectSuccess(self.lblShowState,btn: self.btnReconnect)
        }
        else{
            ShowToolbarState.netConnectFail(self.lblShowState,btn: self.btnReconnect)
        }
        self.lblShowState.reloadInputViews()
        self.btnReconnect.reloadInputViews()
        
    }
    
    func getName() {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var readData = NSData(contentsOfFile: filePath)
        var name = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
        
        if (name.length > 0 && appManager.netConnect == true){
            self.lblShowUserName.text = "当前用户:\(name)"
        }
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
