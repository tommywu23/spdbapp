//
//  DocViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/8.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class DocViewController: UIViewController, UIScrollViewDelegate,UIToolbarDelegate {
    
    var url : String = ""
    
    var fileIDInfo: String?
    var fileNameInfo: String?
    
    
    @IBOutlet weak var docView: UIWebView!
    @IBOutlet var gesTap:UITapGestureRecognizer!
    @IBOutlet weak var tbTop: UIToolbar!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化时候隐藏tab bar
        hideBar()
        
        //为uivewbview中的uiscrollerview添加代理
        docView.scrollView.delegate = self
        //为uitabbar添加代理
        tbTop.delegate = self
        gesTap.addTarget(self, action: "actionBar")
        
        loadLocalPDFFile()

        var timer = Poller()
        timer.start(self, method: "timerDidFire:")

    }
    
    @IBAction func btnBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func btnGoHistory(sender: UIBarButtonItem) {
        NSLog("Go to history")
    }
    
    
    //屏幕滚动时，触发该事件
    func scrollViewDidScroll(scrollView: UIScrollView){
        hideBar()
    }
    
    
    //定时器函数，每隔5s自动隐藏tab bar
    func timerDidFire(timer: NSTimer!){
        if tbTop.hidden == false
        {
            tbTop.hidden = true
        }
    }
    
    func actionBar(){
        tbTop.hidden = !tbTop.hidden
    }
    
    func hideBar(){
        tbTop.hidden = true
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
