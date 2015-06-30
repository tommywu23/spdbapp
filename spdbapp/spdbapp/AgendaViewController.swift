//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var lbConfType: UILabel!
    @IBOutlet weak var tvAgenda: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnReconnect: UIButton!
    @IBOutlet weak var lblShowState: UILabel!
    @IBOutlet weak var btnServer: UIButton!
    
    var filesDataInfo:[JSON] = []
    
    var fileIDInfo:String?
    var fileNameInfo: String?
    
    var server = Server()
    
    var timer = Poller()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        lbConfType.text = "党政联系会议"
        tvAgenda?.dataSource = self
        tvAgenda?.delegate = self
        tvAgenda?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tvAgenda.backgroundColor = UIColor(red: 34/255, green: 63/255, blue: 117/255, alpha: 1)
        tvAgenda.separatorStyle = UITableViewCellSeparatorStyle.None
        var cell = UINib(nibName: "AgendaTableViewCell", bundle: nil)
        self.tvAgenda.registerNib(cell, forCellReuseIdentifier: "cell")
        
        getMeetingFiles()
        
        timer.start(self, method: "checkstatus:",timerInter: 5.0)
        
        btnBack.layer.cornerRadius = 8
        btnReconnect.layer.cornerRadius = 8
        btnBack.addTarget(self, action: "GoBack", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnServer.layer.cornerRadius = 8
               
        if appManager.netConnect == true {
            ShowToolbarState.netConnectSuccess(self.lblShowState,btn: self.btnReconnect)
        }
    }
    
    
    func getReconn(){
        ShowToolbarState.netConnectLinking(self.lblShowState, btn: self.btnReconnect)
        appManager.starttimer()
    }
    
    
    func GoBack(){
        if self.presentingViewController?.presentingViewController != nil {
            self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
        }else if self.presentingViewController != nil{
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    //每隔5s检测网络连接状态，刷新toolbar下方的控件状态
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
    
    
    
    func getMeetingFiles(){

        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, err) -> Void in
            
            println("data = \(data)")
            println("response = \(response?.statusCode)")
            if (err != nil || data?.stringValue == ""){
                println("err = \(err?.description)")
                var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
                
                var filemanager = NSFileManager.defaultManager()
                if filemanager.fileExistsAtPath(localJSONPath){
                    var jsonLocal = filemanager.contentsAtPath(localJSONPath)
                    var json = JSON(data: jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                    if let filesInfo = json["files"].array {
                        self.filesDataInfo = filesInfo
                        println("fileInfo ==========localfile============ \(self.filesDataInfo)")
                        self.tvAgenda.reloadData()
                    }
                }
                return
            }
            
            var json = JSON(data!)
            if let filesInfo = json["files"].array {
                println("fileinfo ===============jsonfile================ \(filesInfo)")
                self.filesDataInfo = filesInfo
                self.tvAgenda.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesDataInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AgendaTableViewCell
        var row = indexPath.row as Int
        
        var rowData = filesDataInfo[indexPath.row]
        
        cell.lbAgenda.text = rowData["name"].stringValue
        cell.lbAgendaIndex.text = (String)(indexPath.row + 1)
        
        var customColorView = UIView();
        customColorView.backgroundColor = UIColor(red: 34/255, green: 63/255, blue: 117/255, alpha: 0.85)
        cell.selectedBackgroundView =  customColorView;
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        var rowData: JSON = filesDataInfo[indexPath.row]
        var id = rowData["_id"].stringValue
        var name = rowData["name"].stringValue
        
        self.fileIDInfo = id
        self.fileNameInfo = name     
        
        self.performSegueWithIdentifier("toDoc", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Create a new variable to store the instance of DocViewController
        if segue.identifier ==  "toDoc" {
            var obj = segue.destinationViewController as! DocViewController
            obj.fileIDInfo = self.fileIDInfo
            obj.fileNameInfo = self.fileNameInfo
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
