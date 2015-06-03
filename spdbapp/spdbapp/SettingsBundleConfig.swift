//
//  SettingsBundleConfig.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/3.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class SettingsBundleConfig: NSObject {
   
    //register seeting.bundle info
    func registerDefaultsFromSettingsBundle() {
        
        var settingsBundle = NSBundle.mainBundle().pathForResource("Settings", ofType: "bundle")
        if(settingsBundle?.isEmpty == true) {
            NSLog("Could not find Settings.bundle");
            return;
        }
        
        var settings = NSDictionary(contentsOfFile: (settingsBundle?.stringByAppendingPathComponent("Root.plist"))!)
        var preferences: NSArray = (settings?.objectForKey("PreferenceSpecifiers"))! as! NSArray
        
        var defaultsToRegister = NSMutableDictionary(capacity: preferences.count)
        
        for(var i = 0 ; i < preferences.count ; i++){
            var prefSpecification = preferences[i] as! NSDictionary
            //println("prefSpecification = \(prefSpecification)")
            
            var key: NSCopying? = prefSpecification.objectForKey("Key") as! NSCopying?
            if (key != nil) {
                defaultsToRegister.setObject((prefSpecification.objectForKey("DefaultValue"))!, forKey: key!)
                var value: AnyObject? = prefSpecification.objectForKey("DefaultValue")
                println("writing as default:\(value!) to the key :\(key!)")
            }
        }
        
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultsToRegister as [NSObject : AnyObject])
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    let standardDefaults = NSUserDefaults.standardUserDefaults()
    
    
    
    //return txtFileURL
    func GetFileURL() -> NSString{
        var txtFileURL: NSString?
        self.registerDefaultsFromSettingsBundle()
        if let testArray: AnyObject? = standardDefaults.objectForKey("txtFileURL") {
            txtFileURL = testArray as? NSString
            //println("txtFileURL = \(txtFileURL!)")
        }
        return txtFileURL!
    }
    
    //return txtMeetingURL
    func GetMeetingURL() -> NSString{
        self.registerDefaultsFromSettingsBundle()
        var txtMeetingURL: NSString?
        if let testArray: AnyObject? = standardDefaults.objectForKey("txtMeetingURL") {
            txtMeetingURL = testArray as? NSString
            //println("txtMeetingURL = \(txtMeetingURL!)")
        }
        return txtMeetingURL!
    }


    func IsClearAllFiles() -> Bool{
     
        self.registerDefaultsFromSettingsBundle()
        var isClearCacheFile: Bool?
        if let testArray: AnyObject? = standardDefaults.objectForKey("isClearCacheFile") {
            isClearCacheFile = testArray as? Bool
            println("isClearCacheFile = \(isClearCacheFile!)")
        }
    
        return isClearCacheFile!
    }

    
}
