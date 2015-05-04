//
//  SMAPService.swift
//  PECS
//
//  Created by Leonard Truong on 4/23/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import Alamofire


class SMAPService: NSObject {
    var fanBack      : Int
    var fanBottom    : Int
    var heaterBack   : Int
    var heaterBottom : Int
    
    var disableUpdates : Bool
    var disableUpdatesEndTime : dispatch_time_t?
    var lastReceievedUpdate : Int

    override init() {
        fanBack      = 0
        fanBottom    = 0
        heaterBack   = 0
        heaterBottom = 0
        disableUpdates = false
        lastReceievedUpdate = -1
        super.init()
        self.poll()
        var timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("poll"), userInfo: nil, repeats: true)
    }
    
    func poll() {
        println("Polling SMAP for updates")
        Alamofire.request(.GET, "http://shell.storm.pm:38001", parameters: ["macaddr": "12345"], encoding: .URL)
                 .responseJSON { (request, response, data, error) in
                    if error != nil {
                        println("Error during poll to SMAP")
                        println(request)
                        println(response)
                        println(data)
                        println(error)
                        return
                    }
                    let json = JSON(data!)
                    let timestamp = json["time"].int
                    if timestamp > self.lastReceievedUpdate {
                        self.lastReceievedUpdate = timestamp!
                        self.fanBack = json["backf"].int!
                        self.fanBottom = json["bottomf"].int!
                        self.heaterBack = json["backh"].int!
                        self.heaterBottom = json["bottomh"].int!
                        NSNotificationCenter.defaultCenter().postNotificationName("kChairStateUpdateFromSmap", object: nil);
                    }
        }
    }
    
    func update() {
        let parameters: [String: AnyObject] = [
            "macaddr": "12345",
            "backf": Int(self.fanBack),
            "bottomf": Int(self.fanBottom),
            "backh": Int(self.heaterBack),
            "bottomh": Int(self.heaterBottom),
        ]
        Alamofire.request(.POST, "http://shell.storm.pm:38001", parameters: parameters, encoding: .JSON)
                 .responseJSON { (request, response, data, error) in
                    if error != nil {
                        println("Error updating smap")
                        println(request)
                        println(response)
                        println(data)
                        println(error)
                        return
                    }
                    let json = JSON(data!)
                    if json["time"] != nil {
                        self.lastReceievedUpdate = json["time"].int!
                    }
        }
        self.disableUpdates = true
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
        self.disableUpdatesEndTime = delayTime
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if self.disableUpdatesEndTime == delayTime {
                self.disableUpdates = false
            }
        }
    }
}