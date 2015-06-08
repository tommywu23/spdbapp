//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIToolbarDelegate {
   
    @IBOutlet weak var lbConfType: UILabel!
    @IBOutlet weak var tvAgenda: UITableView!
    @IBOutlet weak var getTopView: UIView!
    
    @IBOutlet weak var tbTop: UIToolbar!
    @IBOutlet var gesTap: UITapGestureRecognizer!
    @IBOutlet var gesTap1: UITapGestureRecognizer!
    
    var filesDataInfo:[JSON] = []
    
    var fileIDInfo:String?
    var fileNameInfo: String?
    
    
    var router = Router()
    
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
        
        
        //初始化时候隐藏tab bar
        hideBar()
        
        //为uitabbar添加代理
        tbTop.delegate = self
        
        //gestap是对于底部的toolbar进行设置，gestap1是对头部的toolbar进行设置
        gesTap.addTarget(self, action: "actionBar")
        gesTap1.addTarget(self, action: "actionBar")
        self.getTopView.addGestureRecognizer(self.gesTap1)
        
        //添加定时器，每隔5s自动隐藏tar bar
        var timer = Poller()
        timer.start(self, method: "timerDidFire:")
        
    }
    
   
    
    func getMeetingFiles(){

        Alamofire.request(.GET, ServerConfig.getMeetingService()).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, err) -> Void in
            println("data================\(data!)")
            
            if (err != nil || (data)!.length <= 0){
                var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
                var filemanager = NSFileManager.defaultManager()
                if filemanager.fileExistsAtPath(localJSONPath){
                    var jsonLocal = filemanager.contentsAtPath(localJSONPath)
                    var json = JSON(data: jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                    if let filesInfo = json["files"].array {
                        self.filesDataInfo = filesInfo
                        println("fileInfo = \(self.filesDataInfo)")
                        self.tvAgenda.reloadData()
                        self.createViewHeight()
                    }
                }
                return
            }
            
            var json = JSON(data!)
            if let filesInfo = json["files"].array {
                self.filesDataInfo = filesInfo
                //println("fileInfo = \(self.filesDataInfo)")
                self.tvAgenda.reloadData()
                self.createViewHeight()
            }
        }
    }
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        
//        var touch = (touches as NSSet).anyObject()?.locationInView(self.view)
//        println("x= \(touch?.x) === y =\(touch?.y)")
//    }
    
    //根据tableview的cell数目对tableview空白部分的toolbar显示进行设置。当count数<=6,则底部也会显示toobar，否则不显示
    func createViewHeight(){
        var count = self.filesDataInfo.count
        var y = CGFloat(140 * count)
        if count <= 6{
            var height = CGFloat(869 - 140 * count + 10)
            var tapView = UIView(frame: CGRectMake(0, y, 768, height))
            tapView.backgroundColor = UIColor.clearColor()
            self.tvAgenda.addSubview(tapView)
            tapView.addGestureRecognizer(self.gesTap)
        }
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
        
        cell.removeGestureRecognizer(self.gesTap)
        
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
    
    @IBAction func btnBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnGoToHistory(sender: UIBarButtonItem) {
        
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
