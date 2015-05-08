//
//  DocViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/8.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class DocViewController: UIViewController {
    var url : String = ""
    
    @IBOutlet weak var docView: UIWebView!
    @IBOutlet var gesTap:UITapGestureRecognizer!
    @IBOutlet weak var tbTop: UITabBar!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var urlString = NSURL(fileURLWithPath: url)
        var request = NSURLRequest(URL: urlString!)
        
        docView.loadRequest(request)
        
        gesTap.addTarget(self, action: "actionBar")
        // Do any additional setup after loading the view.
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
