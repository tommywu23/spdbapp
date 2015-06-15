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
        
       
        if appManager.netConnect == true {
            ShowToolbarState.netConnectSuccess(self.lblShowState,btn: self.btnReconnect)
        }
    }
    
    func getReconn(){
        ShowToolbarState.netConnectLinking(self.lblShowState, btn: self.btnReconnect)
        appManager.starttimer()
    }
    
    func GoBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //每隔5s检测网络连接状态，刷新toolbar下方的控件状态
    func checkstatus(timer: NSTimer){
        //println("2===============\(appManager.netConnect)=====================2")
        if appManager.netConnect {
            ShowToolbarState.netConnectSuccess(self.lblShowState,btn: self.btnReconnect)
            self.lblShowState.reloadInputViews()
            self.btnReconnect.reloadInputViews()
        }
        else{
            ShowToolbarState.netConnectFail(self.lblShowState,btn: self.btnReconnect)
            self.lblShowState.reloadInputViews()
            self.btnReconnect.reloadInputViews()
        }
        
    }

    func netConnectFail(){
        self.lblShowState.textColor = UIColor.redColor()
        self.lblShowState.text = "网络连接失败"
        
        self.btnReconnect.hidden = false
        self.btnReconnect.enabled = true
        self.btnReconnect.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 249/255, alpha: 1)
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

    
    
    
    func getMeetingFiles(){

        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, err) -> Void in
            if (err != nil || data?.stringValue == ""){
                var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
                
                var filemanager = NSFileManager.defaultManager()
                if filemanager.fileExistsAtPath(localJSONPath){
                    var jsonLocal = filemanager.contentsAtPath(localJSONPath)
                    var json = JSON(data: jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                    if let filesInfo = json["files"].array {
                        self.filesDataInfo = filesInfo
                        println("fileInfo ==========jsonfile============ \(self.filesDataInfo)")
                        self.tvAgenda.reloadData()
                    }
                }
                return
            }
            
            var json = JSON(data!)
            if let filesInfo = json["files"].array {
                println("fileinfo ===============localfile================ \(filesInfo)")
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
