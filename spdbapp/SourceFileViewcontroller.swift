//
//  SourceFileViewcontroller.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/7/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class SourceFileViewcontroller: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var sourceTableview: UITableView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnReconnect: UIButton!
    
    @IBOutlet weak var lblShowFileStatue: UILabel!
    @IBOutlet weak var lblShowAgendaName: UILabel!
    
    @IBOutlet weak var lblShowUserName: UILabel!
    @IBOutlet weak var lblShowState: UILabel!
    
    var agendaNameInfo = String()
    
    var gbSource = GBSource()
    var gbAgenda = GBAgenda()
    
    var gbSourceName = [String]()
    
    var sourceNameInfo = String()
    var timer = Poller()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.layer.cornerRadius = 8
        btnReconnect.layer.cornerRadius = 8
        btnBack.addTarget(self, action: "GoBack", forControlEvents: UIControlEvents.TouchUpInside)
        
        timer.start(self, method: "checkstatus:",timerInter: 5.0)
        
        btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        btnReconnect.layer.cornerRadius = 8
        if appManager.netConnect == true {
            ShowToolbarState.netConnectSuccess(self.lblShowState,btn: self.btnReconnect)
        }
        
        
        sourceTableview.delegate = self
        sourceTableview.dataSource = self
        sourceTableview.separatorStyle = UITableViewCellSeparatorStyle.None
        sourceTableview.tableFooterView = UIView(frame: CGRectZero)
        sourceTableview.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        

        var cell = UINib(nibName: "SourceTableViewCell", bundle: nil)
        sourceTableview.registerNib(cell, forCellReuseIdentifier: "cell")
        
        getSourceFile()
        getName()
    }
    
    //定时器，每隔5s刷新页面下方的toolbar控件显示
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

    
    
    func getName() {
        self.lblShowAgendaName.text = self.agendaNameInfo
        
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var readData = NSData(contentsOfFile: filePath)
        var name = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
        
        if (name.length > 0 && appManager.netConnect == true){
            self.lblShowUserName.text = "当前用户:\(name)"
        }
    }

    
    func getReconn(){
        ShowToolbarState.netConnectLinking(self.lblShowState, btn: self.btnReconnect)
        appManager.starttimer()
    }
    
    
    func GoBack(){
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    
    func showSourceInfo(json: JSON , agendaName: String){
        if let agendasInfo = json["agenda"].array{
             for var  i = 0 ; i < agendasInfo.count ; i++ {
                self.gbAgenda.name = agendasInfo[i]["name"].stringValue
                
                if self.gbAgenda.name == agendaName{
                    if let sourcesInfo = agendasInfo[i]["source"].array{
                        for var  j = 0 ; j < sourcesInfo.count ; j++ {
                            self.gbSource.id = sourcesInfo[j].stringValue

                            //根据当前source文件的id寻找对应的source文件的name
                            if let sources = json["source"].array{
                                for var k = 0 ; k < sources.count ; k++ {
                                    if self.gbSource.id == sources[k]["id"].stringValue{
                                        self.gbSource.name = sources[k]["name"].stringValue
                                    }
                                }
                            }
                            
                            gbSourceName.append(self.gbSource.name)
                            sourceTableview.reloadData()

                        }
                    }
                }
            }
        }
    }
    
    
    
    func getSourceFile(){
        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, err) -> Void in
            
            //            println("data = \(data)")
            
            if (err != nil || data?.stringValue == ""){
                println("source getmeeting err = \(err?.description)")
                var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
                
                var filemanager = NSFileManager.defaultManager()
                if filemanager.fileExistsAtPath(localJSONPath){
                    var jsonLocal = filemanager.contentsAtPath(localJSONPath)
                    var json = JSON(data: jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                    
                    println("=================local=====================")
                    self.showSourceInfo(json, agendaName: self.agendaNameInfo)
                }
                return
            }
            
            println("fileinfo ===============jsonfile================")
            var json = JSON(data!)
            self.showSourceInfo(json, agendaName: self.agendaNameInfo)
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gbSourceName.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SourceTableViewCell
        
        cell.lblShowSourceFileName.text = self.gbSourceName[indexPath.row].stringByDeletingPathExtension
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        var name = self.gbSourceName[indexPath.row]
        println("segue name==================\(name)")
        self.sourceNameInfo = name
        
        
        var isFileExist = DownLoadManager.isFileDownload(self.sourceNameInfo)
        if isFileExist == false{
            
//            cell.detailTextLabel?.text = "该文件尚在下载，请稍后..."
            self.lblShowFileStatue.text = "该文件尚在下载，请稍后..."
        }else{
            cell.detailTextLabel?.text = ""
            self.lblShowFileStatue.text = ""
//            self.performSegueWithIdentifier("sourceToDoc", sender: self)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sourceToDoc"{
            var obj = segue.destinationViewController as! DocViewController
            obj.fileNameInfo = self.sourceNameInfo
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}