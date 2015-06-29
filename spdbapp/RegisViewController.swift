//
//  RegisViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/26.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire


class RegisViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var lblShowState: UILabel!
    
    dynamic var gbUser = GBUser()
    var flag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mainView.layer.cornerRadius = 8
        
        btnOK.layer.cornerRadius = 8
        btnOK.addTarget(self, action: "goLogin", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnCancel.layer.cornerRadius = 8
        btnCancel.addTarget(self, action: "cancelLogin", forControlEvents: UIControlEvents.TouchUpInside)
    
    }
    
    func goLogin(){
        let paras = ["name":txtName.text,"password":txtPwd.text]
        var url = "http:192.168.21.83:3003/login"    
        
        Alamofire.request(.POST, url ,parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request,response, data, error) ->
            
            Void in
            println("post data = \(data!)")
   
            if(response?.statusCode != 200){
                self.lblShowState.text = "登陆失败，请检查用户名和密码后重试"
                self.txtName.text = ""
                self.txtPwd.text = ""
                self.flag = false
                return
            }
            
            self.flag = true
            self.lblShowState.text = ""
            self.gbUser.name = data?.objectForKey("name") as! String
            self.gbUser.password = data?.objectForKey("password") as! String
            self.gbUser.type = data?.objectForKey("type") as? GBMeetingType
            
//            loginUser.name = data?.objectForKey("name") as! String
//            loginUser.password = data?.objectForKey("password") as! String
//            loginUser.type = data?.objectForKey("type") as? GBMeetingType

            
            self.saveUser()

            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let agendaView: AgendaViewController = storyboard.instantiateViewControllerWithIdentifier("agenda") as! AgendaViewController
            self.presentViewController(agendaView, animated: true, completion: nil)
        
        }
    }
    
    func IsIdFileExist() -> Bool {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        
        //判断该文件是否存在，则创建该iddata. txt文件
        var manager = NSFileManager.defaultManager()
        if !manager.fileExistsAtPath(filePath){
            return false
        }
        return true
    }

    
    func saveUser(){
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
//        NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
        var b = IsIdFileExist()
                
        //如果iddata文件夹不存在，则创建iddata.txt文件
//        if !b{
//            var manager = NSFileManager.defaultManager()
//            var bCreateFile = manager.createFileAtPath(filePath, contents: nil, attributes: nil)
//            if bCreateFile{
//                println("username文件创建成功")
//                //idstr = GBNetwork.getMacId()
//            }
//        }
        
        NSLog("filePath = %@", filePath)
        var name = self.gbUser.name
        var isWritten = name.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if isWritten {
            println("name save ok!")
        }
        
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier ==  "LoginToMain" {
//            var obj = segue.destinationViewController as! MainViewController
//            var userName = self.txtName.text
//            obj.userName = userName
//            println("name = \(obj.userName)")
//        }
//
//    }
    
    
    func cancelLogin(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
