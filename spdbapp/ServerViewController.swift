//
//  ServerViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/29.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class ServerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let servers = [
    ["name":"笔","pic":"Pan-white"],
    ["name":"纸笔","pic":"paper&pan-on"],
    ["name":"服务人员","pic":"server-on"],
    ["name":"茶水","pic":"tea-on"],
    ["name":"咖啡","pic":"coffee-on"],
    ["name":"矿泉水","pic":"water-on"],
    ["name":"其余","pic":"tissue-on"]
    ]
    
    @IBOutlet weak var serverColView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.serverColView.delegate = self
        self.serverColView.dataSource = self
        
        self.serverColView.layer.cornerRadius = 8
        
        self.serverColView.registerClass(UICollectionViewCell.self
            , forCellWithReuseIdentifier: "Cell")
        
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
        
        let imgView = UIImageView(frame: CGRect(x: 25, y: 5, width: 100, height: 100))
        imgView.image = UIImage(named: servers[indexPath.row]["pic"]!)
        
        let lblName = UILabel(frame: CGRect(x: 25, y: 120, width: 100, height: 25))
        lblName.text = servers[indexPath.row]["name"]
        lblName.textAlignment = NSTextAlignment.Center
        lblName.layer.cornerRadius = 3
        lblName.backgroundColor = UIColor.orangeColor()
        
        cell.addSubview(imgView)
        cell.addSubview(lblName)
        
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
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var service = servers[indexPath.row]["name"]!

        var name = "cheng"
        var id = NSUUID().UUIDString
        let paras = ["id": id,"name": name,"chairname": name,"service": service ,"createtime":getCurrentTime()]
        println("paras = \(paras)")
        var url = "http://192.168.16.141:10086/service"
        
        Alamofire.request(.POST, url, parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            
//            println("error = \(error)")
//            println("response = \(response)")
            
            if response?.statusCode == 200 || response?.statusCode == 309 {
                println("code = \(response?.statusCode)")
//                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                println("发送服务失败")
//                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    

}
