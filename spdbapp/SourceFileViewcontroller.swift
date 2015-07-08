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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.layer.cornerRadius = 8
        btnReconnect.layer.cornerRadius = 8
        btnBack.addTarget(self, action: "GoBack", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnReconnect.addTarget(self, action: "getReconn", forControlEvents: UIControlEvents.TouchUpInside)
        
        if appManager.netConnect == true {
            ShowToolbarState.netConnectSuccess(self.lblShowState,btn: self.btnReconnect)
        }

        
        sourceTableview.delegate = self
        sourceTableview.dataSource = self
        sourceTableview.tableFooterView = UIView(frame: CGRectZero)
        sourceTableview.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        getSourceFile()
        getName()
    }
    
    
    func getName() {
        self.lblShowAgendaName.text = self.agendaNameInfo
        
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var readData = NSData(contentsOfFile: filePath)
        var name = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
        
        if (name.length > 0){
            self.lblShowUserName.text = "当前用户:\(name)"
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        
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
        let cellIdentify = "SourceTableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        var imgView = UIImageView(frame: CGRectMake(0, 0, 768, 55))
        imgView.image = UIImage(named: "cell_bgred")
        cell.addSubview(imgView)
       
        cell.textLabel?.font = UIFont(name: "KaiTi_GB2312", size: 20.0)
        cell.textLabel?.text = self.gbSourceName[indexPath.row].stringByDeletingPathExtension
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        var name = self.gbSourceName[indexPath.row]
        println("segue name==================\(name)")
        self.sourceNameInfo = name
        
        var isFileExist = DownLoadManager.isFileDownload(self.sourceNameInfo)
        if isFileExist == false{
            self.lblShowFileStatue.text = "该文件尚在下载，请稍后..."
        }else{
            self.lblShowFileStatue.text = ""
            self.performSegueWithIdentifier("sourceToDoc", sender: self)
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