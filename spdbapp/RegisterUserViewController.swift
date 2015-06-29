//
//  RegisterUserViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/25.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class RegisterUserViewController: UIViewController {

    @IBOutlet weak var lblName: UITextField!
    @IBOutlet weak var lblPwd: UITextField!
    
    
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var lblShowState: UILabel!
    
    @IBOutlet weak var registerView: UIView!
    
    var gbUser = GBUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnCancel.layer.cornerRadius = 8
        btnCancel.addTarget(self, action: "btnCancelFile", forControlEvents: UIControlEvents.TouchUpInside)
        btnOK.layer.cornerRadius = 8
        btnOK.addTarget(self, action: "btnRegisterOK", forControlEvents: UIControlEvents.TouchUpInside)

    }

    
    
    func btnRegisterOK(){
        let paras = ["name":lblName.text,"password":lblPwd.text]
        var url = "http:192.168.19.116:3003/login"
        
        
        Alamofire.request(.POST, url ,parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request,response, data, error) ->
            
            Void in
            println("post data = \(data!)")
            
            if(error != nil){
                self.lblShowState.text = "登陆失败，请检查用户名和密码后重试"
                return
            }
    
            self.gbUser.name = data?.objectForKey("name") as! String
            self.gbUser.password = data?.objectForKey("password") as! String
            self.gbUser.type = data?.objectForKey("type") as? GBMeetingType
            
        }

    }
    
    
    
    func btnCancelFile(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
