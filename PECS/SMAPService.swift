//
//  SMAPService.swift
//  PECS
//
//  Created by Leonard Truong on 4/23/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON
import UIKit


class SMAPService: NSObject, WebSocketDelegate {
    var socket = WebSocket(url: NSURL(scheme: "ws", host: "shell.storm.pm:8078", path: "/republish")!)
    var fanBack      : Int
    var fanBottom    : Int
    var heaterBack   : Int
    var heaterBottom : Int

    override init() {
        fanBack      = 0
        fanBottom    = 0
        heaterBack   = 0
        heaterBottom = 0
        super.init()
        socket.delegate = self
        socket.connect()
        socket.writeString(
            "uuid = 'a99daf41-f3b3-51a7-97bf-48fb3e7bf130' or " +
            "uuid = '33ecc20c-e636-58eb-863f-142717105075' or " +
            "uuid = 'b7ef2e98-2e0a-515b-b534-69894fdddf6f' or " +
            "uuid = '27e1e889-b749-5cf9-8f90-5cc5f1750ddf'"
        )
    }
    
    func websocketDidConnect(ws: WebSocket) {
        println("websocket is connected")
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            println("websocket is disconnected: \(e.localizedDescription)")
        }
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        let data = JSON(data: text.dataUsingEncoding(NSUTF8StringEncoding)!)
        let uuid = data["UUID"].stringValue
        let value = data["Readings"][0][1]
        switch uuid {
            case "a99daf41-f3b3-51a7-97bf-48fb3e7bf130":
                self.heaterBottom = value.intValue
            case "33ecc20c-e636-58eb-863f-142717105075":
                self.heaterBack = value.intValue
            case "b7ef2e98-2e0a-515b-b534-69894fdddf6f":
                self.fanBottom = value.intValue
            case "27e1e889-b749-5cf9-8f90-5cc5f1750ddf":
                self.fanBack = value.intValue
            default:
                println("Found unrecognized UUID \(uuid)")
            
        }
        NSNotificationCenter.defaultCenter().postNotificationName("kChairStateUpdateFromSmap", object: nil);
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        println("Received data: \(data.length)")
    }
}