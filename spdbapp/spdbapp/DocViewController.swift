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
    
    @IBOutlet weak var btnServer: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer.start(self, method: "checkstatus:",timerInter: 5.0)
        
        loadLocalPDFFile()
        
        btnBack.layer.cornerRadius = 8
        btnReconnect.layer.cornerRadius = 8
        btnBack.addTarget(self, action: "GoBack", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnServer.layer.cornerRadius = 8
        btnServer.addTarget(self, action: "ToServerVC", forControlEvents: UIControlEvents.TouchUpInside)
        
        if appManager.netConnect == true {
            ShowToolbarState.netConnectSuccess(self.lblShowState, btn: self.btnReconnect)
        }
    }

    
    func getReconn(){
        ShowToolbarState.netConnectLinking(self.lblShowState, btn: self.btnReconnect)
        appManager.starttimer()
    }
    
    
    //ServerBox
    func ToServerVC(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let serverBoxView: ServerViewController = storyboard.instantiateViewControllerWithIdentifier("ServerBox") as! ServerViewController
        
        serverBoxView.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        serverBoxView.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        self.presentViewController(serverBoxView, animated: false) { () -> Void in
            serverBoxView.view.backgroundColor = UIColor.clearColor()
        }
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
    
    func GoBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //获取本地pdf文档
    func loadLocalPDFFile(){
        var filePath: String = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(self.fileNameInfo!)")
        var urlString = NSURL(fileURLWithPath: "\(filePath)")
        var request = NSURLRequest(URL: urlString!)
        self.docView.loadRequest(request)
//        println("path = \(filePath)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
