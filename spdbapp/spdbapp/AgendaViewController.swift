//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIToolbarDelegate,HttpProtocol {
   
    @IBOutlet weak var lbConfType: UILabel!
    @IBOutlet weak var tvAgenda: UITableView!
    
    
    @IBOutlet weak var tbTop: UIToolbar!
    @IBOutlet var gesTap: UITapGestureRecognizer!
    
    
//    var filesDataInfo:[JSON] = []
    var eHTTP: HTTPController = HTTPController()
    var baseURl = "http://192.168.16.141:8080/meeting/current"
    var meetinglist:[JSON] = []
    var fileIDInfo:String?
    var fileNameInfo: String?
    var meetingListCount = 0
    var namelist = String()
    var idlist = String()
    var meetingNameArray = [String]()
    var meetingIdArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getMeetingFils()
        localGetMeetingFiles()
        lbConfType.text = "党政联系会议"
        tvAgenda?.dataSource = self
        tvAgenda?.delegate = self
        tvAgenda?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tvAgenda.backgroundColor = UIColor(red: 34/255, green: 63/255, blue: 117/255, alpha: 1)
        tvAgenda.separatorStyle = UITableViewCellSeparatorStyle.None
        var cell = UINib(nibName: "AgendaTableViewCell", bundle: nil)
        self.tvAgenda.registerNib(cell, forCellReuseIdentifier: "cell")
        eHTTP.delegate = self
        eHTTP.onSearch(baseURl)
        self.tvAgenda.reloadData()
        
        //初始化时候隐藏tab bar
        hideBar()
        
        // 点击该区域内，添加手势，弹出tabbar
        var topView = UIView(frame: CGRectMake(0, 0, 768, 155))
        topView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(topView)
        
        //为uitabbar添加代理
        tbTop.delegate = self
        gesTap.addTarget(self, action: "actionBar")
        topView.addGestureRecognizer(gesTap)
        
        //添加定时器，每隔5s自动隐藏tar bar
        var timer = Poller()
        timer.start(self, method: "timerDidFire:")
        
        
    }
    //离线状态下获取会议内容
    func localGetMeetingFiles(){
        //println("离线会议")
        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
        var filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(localJSONPath){
            var jsonLocal = filemanager.contentsAtPath(localJSONPath)
            var json: AnyObject = NSJSONSerialization.JSONObjectWithData(jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
            var meetinglist = json.objectForKey("files") as! NSMutableArray
            self.meetingListCount = meetinglist.count
            for var i = 0;i < self.meetingListCount;i++ {
                var meeting:AnyObject = json.objectForKey("files")![i]
                self.namelist = meeting.objectForKey("name")! as! String
                self.idlist = meeting.objectForKey("_id")! as! String
                self.meetingNameArray.append(self.namelist)
                self.meetingIdArray.addObject(self.idlist)
            }
        }
    }
    //在线状态下获取会议内容
    func getMeetingFils(){
//        var router = Router.GetCurrentMeeting()
//         Alamofire.request(router.0,router.1).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
//            if(error != nil){
//                println("网络错误，将从本地读取会议文件创建会议\(error )")
//                var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
//                var filemanager = NSFileManager.defaultManager()
//                if filemanager.fileExistsAtPath(localJSONPath){
//                    var jsonLocal = filemanager.contentsAtPath(localJSONPath)
//                    var json: AnyObject = NSJSONSerialization.JSONObjectWithData(jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
//                    var meetinglist = json.objectForKey("files") as! NSMutableArray
//                    self.meetingListCount = meetinglist.count
//                    for var i = 0;i < self.meetingListCount;i++ {
//                        var meeting:AnyObject = json.objectForKey("files")![i]
//                        self.namelist = meeting.objectForKey("name")! as! String
//                        self.idlist = meeting.objectForKey("_id")! as! String
//                        self.meetingNameArray.append(self.namelist)
//                        self.meetingIdArray.addObject(self.idlist)
//                    }
//                    return
//                }
//                
//            }
            var url = NSURL(string: "http://192.168.16.141:8080/meeting/current")
            var data = NSData(contentsOfURL: url!)
            var json: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error:nil)!
            if json.data == nil{
                println("网络错误，将进入离线会议模式")
            }
            var meetinglist = json.objectForKey("files")! as! NSArray
            self.meetingListCount = meetinglist.count
            for var i = 0;i < self.meetingListCount;i++ {
                var meeting:AnyObject = json.objectForKey("files")![i]
                self.namelist = meeting.objectForKey("name")! as! String
                self.idlist = meeting.objectForKey("_id")! as! String
                self.meetingNameArray.append(self.namelist)
                self.meetingIdArray.addObject(self.idlist)
            }
    }
//
//    func didReceiveResult(results: AnyObject) {
//        let json = JSON(results)
//        
//        if let filesInfo = json["files"].array
//        {
//            //获取所有的文件信息
//            self.filesDataInfo = filesInfo
//            //println("fileInfo = \(self.filesDataInfo)")
//            self.tvAgenda.reloadData()
//        }
//        
//    }


    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return self.items.count
        println("议程数\(meetingListCount)")
        return meetingListCount
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AgendaTableViewCell
        //var row = indexPath.row as Int
        //cell.lbAgenda.text = self.items[row]
        //var rowData = self.meetinglist[indexPath.row]
        //println("议程列表\(self.meetinglist)")
        cell.lbAgenda.text = self.meetingNameArray[indexPath.row]
        cell.lbAgendaIndex.text = (String)(indexPath.row + 1)
        
        var customColorView = UIView();
        customColorView.backgroundColor = UIColor(red: 34/255, green: 63/255, blue: 117/255, alpha: 0.85)
        cell.selectedBackgroundView =  customColorView;
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        if  var thisName = self.meetingNameArray[indexPath.row] as? NSString{
            if thisName.length > 0{
                self.fileNameInfo = thisName as String
                self.performSegueWithIdentifier("toDoc", sender: self)
            }
            else
            {
                return
                
            }
        }

//        var rowData: JSON = self.meetinglist[indexPath.row]
//        var id = rowData["_id"].stringValue
//        var name = rowData["name"].stringValue
//        
//        self.fileIDInfo = id
//        self.fileNameInfo = name
//        
//        self.performSegueWithIdentifier("toDoc", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Create a new variable to store the instance of DocViewController
        
        if segue.identifier ==  "toDoc" {
            var obj = segue.destinationViewController as! DocViewController
            obj.fileIDInfo = self.fileIDInfo
            obj.fileNameInfo = self.fileNameInfo
            
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

    
    @IBAction func btnBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnGoToHistory(sender: UIBarButtonItem) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
