//
//  ServerViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/29.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class ServerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate, UIGestureRecognizerDelegate{

    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewLeft: UIView!
    @IBOutlet weak var viewRight: UIView!
    @IBOutlet weak var viewBottom: UIView!
    
    let servers = [
    ["name":"笔","pic":"Pan-white"],
    ["name":"纸","pic":"paper-on"],
    ["name":"服务人员","pic":"server-on"],
    ["name":"茶水","pic":"tea-on"],
    ["name":"咖啡","pic":"coffee-on"],
    ["name":"矿泉水","pic":"water-on"],
    ["name":"纸巾","pic":"tissue-on"],
    ["name":"秘书","pic":"secretary-on"]
    ]
    
    @IBOutlet weak var serverColView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.serverColView.delegate = self
        self.serverColView.dataSource = self
        self.serverColView.layer.cornerRadius = 8
        self.serverColView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.tapGesture.addTarget(self, action: "hideServerView")
//        self.view.addGestureRecognizer(tapGesture)
        self.viewTop.addGestureRecognizer(tapGesture)
        self.viewBottom.addGestureRecognizer(tapGesture)
        self.viewLeft.addGestureRecognizer(tapGesture)
        self.viewRight.addGestureRecognizer(tapGesture)
        
    }
   
    
    func hideServerView(){
        println("======tsp=======")
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return servers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.serverColView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        let imgView = UIImageView(frame: CGRect(x: 10, y: 5, width: 80, height: 85))
        imgView.image = UIImage(named: servers[indexPath.row]["pic"]!)

        cell.addSubview(imgView)
        
        return cell
    }
    
    func addZero(value: Int) -> String{
        var result = String(value)
        if value / 10 == 0 && value != 10{
            result = "0" + String(value)
        }
        return result
    }
    
    func getCurrentTime() -> String {
        var date = NSDate()
        var calendar = NSCalendar.currentCalendar()
        var components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
        var year = components.year
        var month = components.month
        var day = components.day
        var hour = addZero(components.hour)
        var minutes = addZero(components.minute)
        var sec = addZero(components.second)
        
        return "\(year)/\(month)/\(day)  \(hour):\(minutes):\(sec)"
    }
    
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        var cell = self.serverColView.cellForItemAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var cell = self.serverColView.cellForItemAtIndexPath(indexPath)
        var serviceName = servers[indexPath.row]["name"]!
        var name = "cheng"
        var id = NSUUID().UUIDString
        let paras = ["id": id,"name": name,"chairname": name,"service": serviceName ,"createtime":getCurrentTime()]
        var url = "http://192.168.16.141:10086/service"
        
        Alamofire.request(.POST, url, parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in

            if response?.statusCode == 200 || response?.statusCode == 309 {
                println("code = \(response?.statusCode)")
                UIAlertView(title: "提示", message: "\(serviceName)服务已发送，请您耐心等候", delegate: self, cancelButtonTitle: "确定").show()
            }else{
                println("服务请求失败")
                UIAlertView(title: "提示", message: "\(serviceName)服务请求失败，请检查网络后重试", delegate: self, cancelButtonTitle: "确定").show()
            }
        }
        self.dismissViewControllerAnimated(false, completion: nil)
        
    }
    

}
