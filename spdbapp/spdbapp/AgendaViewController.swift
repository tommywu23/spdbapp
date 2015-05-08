//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var lbConfType: UILabel!
    @IBOutlet weak var tvAgenda: UITableView!
    
    var items = ["上海浦东发展银行股份有限公司第二届董事会第一次会议上海浦东发展银行股份有限公司第二届董事会第一次会议上海浦东发展银行股份有限公司第二届董事会第一次会议",
        "上海浦东发展银行股份有限公司第二届董事会第二次会议",
        "上海浦东发展银行股份有限公司第二届董事会第三次会议",
        "上海浦东发展银行股份有限公司第二届董事会第四次会议",
        "上海浦东发展银行股份有限公司第二届董事会第五次会议",
        "上海浦东发展银行股份有限公司第二届董事会第六次会议",
        "上海浦东发展银行股份有限公司第二届董事会第七次会议",
        "上海浦东发展银行股份有限公司第二届董事会第八次会议",
        "上海浦东发展银行股份有限公司第二届董事会第九次会议"]
    var index = ["一、","二十一、","三、","四、","五、","六、","七十、","八、","九、","十、","二十一、"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbConfType.text = "党政联系会议"
        tvAgenda?.dataSource = self
        tvAgenda?.delegate = self
        tvAgenda?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tvAgenda.backgroundColor = UIColor(red: 34/255, green: 63/255, blue: 117/255, alpha: 1)
        //tvAgenda.tableHeaderView = UIView(frame: CGRectZero)
        //tvAgenda.tableFooterView = UIView(frame: CGRectZero)
        //tvAgenda.separatorColor = UIColor.clearColor()
        tvAgenda.separatorStyle = UITableViewCellSeparatorStyle.None
        var cell = UINib(nibName: "AgendaTableViewCell", bundle: nil)
        self.tvAgenda.registerNib(cell, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AgendaTableViewCell
        var row = indexPath.row as Int
        cell.lbAgenda.text = self.items[row]
        cell.lbAgendaIndex.text = self.index[row]
        
        var customColorView = UIView();
        customColorView.backgroundColor = UIColor(red: 34/255, green: 63/255, blue: 117/255, alpha: 0.85)
        cell.selectedBackgroundView =  customColorView;
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
       self.performSegueWithIdentifier("toDoc", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Create a new variable to store the instance of DocViewController
        let c = segue.destinationViewController as! DocViewController
        c.url = "/Users/tommy/Desktop/公司第五届董事会第三十五次会议决议公告.pdf"

    }
}
