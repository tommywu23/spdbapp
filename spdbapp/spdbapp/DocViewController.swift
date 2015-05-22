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
    
    @IBOutlet weak var docView: UIWebView!
    @IBOutlet var gesTap:UITapGestureRecognizer!
    //@IBOutlet weak var tbTop: UITabBar!
    @IBOutlet weak var tbTop: UIToolbar!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("111111111111")
        var urlString = NSURL(fileURLWithPath: url)
        var request = NSURLRequest(URL: urlString!)
        NSLog("%@",request)
        docView.loadRequest(request)
        
        
        //初始化时候隐藏tab bar
        hideBar()
        
        //为uivewbview中的uiscrollerview添加代理
        docView.scrollView.delegate = self
        //为uitabbar添加代理
        tbTop.delegate = self
        gesTap.addTarget(self, action: "actionBar")
        

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
