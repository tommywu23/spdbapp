//
//  Networking.swift
//  spdbapp
//
//  Created by tommy on 15/5/11.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Foundation
import UIKit


class GBNetwork {
    class func getMacId() -> String {
        return UIDevice.currentDevice().identifierForVendor.UUIDString
    }
}

