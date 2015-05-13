//
//  Router.swift
//  spdbapp
//
//  Created by tommy on 15/5/13.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Alamofire
import Foundation

enum Router: URLRequestConvertible {
    static let baseURLString = "http://192.168.21.45:8080"
    static var OAuthToken: String?
    
    case RegBox([String: AnyObject])
    case ReadBox(String)
    case UpdateBox(String, [String: AnyObject])
    case DestroyBox(String)
    
    var method: Alamofire.Method {
        switch self {
        case .RegBox:
            return .POST
        case .ReadBox:
            return .GET
        case .UpdateBox:
            return .PATCH
        case .DestroyBox:
            return .DELETE
        }
    }
    
    var path: String {
        switch self {
        case .RegBox:
            return "/box"
        case .ReadBox(let id):
            return "/box/\(id)"
        case .UpdateBox(let id, _):
            return "/box/\(id)"
        case .DestroyBox(let id):
            return "/box/\(id)"
        }
    }
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = Router.OAuthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .RegBox(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
//        case .UpdateUser(_, let parameters):
//            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}