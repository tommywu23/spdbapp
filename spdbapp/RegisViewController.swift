//
//  RegisViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/26.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire


class RegisViewController: UIViewController,UIAlertViewDelegate, UITextFieldDelegate {

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
    
        self.view.backgroundColor = UIColor.clearColor()
        self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        
        txtName.delegate = self
        txtPwd.delegate = self
        
        txtName.becomeFirstResponder()
        
        mainView.layer.cornerRadius = 8
        
        btnOK.layer.cornerRadius = 8
        btnOK.addTarget(self, action: "goLogin", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnCancel.layer.cornerRadius = 8
        btnCancel.addTarget(self, action: "cancelLogin", forControlEvents: UIControlEvents.TouchUpInside)
    
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txtName{
            txtPwd.becomeFirstResponder()
        }else if textField == txtPwd{
            goLogin()
        }
        return true
    }
    
    
    
    func goLogin(){
        let paras = ["name":txtName.text,"password":txtPwd.text]
        Alamofire.request(.POST, server.loginServiceUrl ,parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request,response, data, error) ->
            
            Void in
            
            if error != nil{
                println("login err = \(error)")
                UIAlertView(title: "提示", message: "登录失败，无法连接到服务器，请检查网络设置后重试", delegate: self, cancelButtonTitle: "确定").show()
                println("登录失败，无法连接到服务器，请检查网络设置后重试")
                self.dismissViewControllerAnimated(false, completion: nil)
                return
            }else if(response?.statusCode != 200){
                self.lblShowState.text = "用户名或密码错误"
                self.txtName.text = ""
                self.txtPwd.text = ""
                return
            }
            
            self.flag = true
            self.lblShowState.text = ""
            self.gbUser.name = data?.objectForKey("name") as! String
            self.gbUser.password = data?.objectForKey("password") as! String
            self.gbUser.type = data?.objectForKey("type") as? GBMeetingType
            DownLoadManager.isStart(true)
            println("\(self.txtName.text)登录成功===================")

            self.saveUser()
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func IsIdFileExist() -> Bool {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        
        //判断该文件是否存在，则创建该UserInfo.txt文件
        var manager = NSFileManager.defaultManager()
        if !manager.fileExistsAtPath(filePath){
            return false
        }
        return true
    }

    
    func saveUser(){
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var name = self.gbUser.name
        var isWritten = name.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if isWritten {
            println("name save ok!")
        }
    }
    
    func cancelLogin(){
        self.flag = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //returnToMain  
        if segue.identifier ==  "returnToMain" {
            //ToAgendaVC
            var obj = segue.destinationViewController as! MainViewController
            obj.flag = self.flag
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
