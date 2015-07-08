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
    @IBOutlet weak var lblShowFileStatue: UILabel!
    @IBOutlet weak var lblMeetingName: UILabel!
    @IBOutlet weak var lblShowUserName: UILabel!
    
    var agendaNameInfo = String()
    
    var gbAgenda = GBAgenda()
    var gbSource = GBSource()
    var gbSourceInfo = [GBSource]()
    var gbAgendInfo = [GBAgenda]()
    var agendaName = [String]()
    var agendaId = [String]()
    var agendaStarttime = [String]()
    var agendaEndtime = [String]()
    var agendaReporter = [String]()

    var timer = Poller()
    var meetingName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
  
        tvAgenda?.dataSource = self
        tvAgenda?.delegate = self
        tvAgenda?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tvAgenda.separatorStyle = UITableViewCellSeparatorStyle.None
//        tvAgenda.tableFooterView = UIView(frame: CGRectZero)
         //tvAgenda.backgroundColor = UIColor(red: 34/255, green: 63/255, blue: 117/255, alpha: 1.0)
        
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
        
        self.getName()
    }
    
    override func viewWillAppear(animated: Bool) {
        println("meeting anme = \(meetingName)")
        self.lblMeetingName.text = meetingName
    }
    
    
    func getReconn(){
        ShowToolbarState.netConnectLinking(self.lblShowState, btn: self.btnReconnect)
        appManager.starttimer()
    }
    
    
    func GoBack(){
        self.dismissViewControllerAnimated(false, completion: nil)
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

    
    func showMeetingInfo(json: JSON) {
        if let agendasInfo = json["agenda"].array {
            
            //遍历议程信息,获取议程的name、id、source等信息
            for var  i = 0 ; i < agendasInfo.count ; i++ {
                self.gbAgenda.id = agendasInfo[i]["id"].stringValue
                self.gbAgenda.name = agendasInfo[i]["name"].stringValue
                self.gbAgenda.starttime = agendasInfo[i]["starttime"].stringValue
                self.gbAgenda.endtime = agendasInfo[i]["endtime"].stringValue
                self.gbAgenda.reporter = "report\(i)"

                
                self.gbAgendInfo.append(self.gbAgenda)
                self.agendaName.append(self.gbAgenda.name)
                self.agendaId.append(self.gbAgenda.id)
                self.agendaStarttime.append(self.gbAgenda.starttime)
                self.agendaEndtime.append(self.gbAgenda.endtime)
                self.agendaReporter.append(self.gbAgenda.reporter)
                self.tvAgenda.reloadData()
            }
            
        }

    }
    
    
    func getName() {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var readData = NSData(contentsOfFile: filePath)
        var name = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
        
        if (name.length > 0){
            self.lblShowUserName.text = "当前用户:\(name)"
        }
    }


    
    func getMeetingFiles(){

        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, err) -> Void in
    
            if (err != nil || data?.stringValue == ""){
                println("aegnda getmeeting err = \(err?.description)")
                var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
                
                var filemanager = NSFileManager.defaultManager()
                if filemanager.fileExistsAtPath(localJSONPath){
                    var jsonLocal = filemanager.contentsAtPath(localJSONPath)
                    var json = JSON(data: jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                   
                    println("=================local=====================")
                    self.showMeetingInfo(json)
                }
                return
            }
   
            println("fileinfo ===============jsonfile================")
            var json = JSON(data!)
            self.showMeetingInfo(json)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gbAgendInfo.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")

        var name = self.agendaName[indexPath.row]
        println("segue name==================\(name)")
        self.agendaNameInfo = name
        self.performSegueWithIdentifier("toSource", sender: self)
        
        var selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor(red: 26/255, green: 46/255, blue: 97/255, alpha: 0.9)
        cell.selectedBackgroundView = selectedView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AgendaTableViewCell
        cell.lblTime.text = "\(self.agendaStarttime[indexPath.row]) - \(self.agendaEndtime[indexPath.row])"
        cell.lblReporter.text = self.agendaReporter[indexPath.row]
        cell.lbAgenda.text = "\(self.agendaName[indexPath.row])"
        cell.tag = indexPath.row
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Create a new variable to store the instance of DocViewController
        if segue.identifier ==  "toSource" {
            var obj = segue.destinationViewController as! SourceFileViewcontroller
            obj.agendaNameInfo = self.agendaNameInfo
        }
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
