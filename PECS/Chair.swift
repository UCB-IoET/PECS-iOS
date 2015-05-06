//
//  Chair.swift
//  PECS
//
//  Created by Leonard Truong on 4/22/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit
import Alamofire
import SwiftyJSON


class Chair: NSObject, CBPeripheralDelegate {
    
    var smapService = (UIApplication.sharedApplication().delegate as! AppDelegate).smapService
    var name: NSString = ""
    var peripheral: CBPeripheral!
    var rssi: NSNumber!
    var characteristic: CBCharacteristic!
    var heaterBottom : Int
    var heaterBack : Int
    var fanBottom : Int
    var fanBack : Int
    var occupancy : Int
    var macaddr : String!
    
    let ChairServiceUUID = CBUUID(string: "FFE0")
    let ChairCharUUID = CBUUID(string: "FFE1")
    
    init(name: String, peripheral: CBPeripheral, rssi: NSNumber!){
        self.heaterBottom = 0
        self.heaterBack = 0
        self.fanBottom = 0
        self.fanBack = 0
        self.occupancy = 0
        super.init()
        self.name = name
        self.peripheral = peripheral
        self.rssi = rssi
        self.peripheral.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChair", name: "kChairStateUpdateFromSmap", object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateChair() {
        self.heaterBack = self.smapService.heaterBack
        self.heaterBottom = self.smapService.heaterBottom
        self.fanBack = self.smapService.fanBack
        self.fanBottom = self.smapService.fanBottom
        self.sendData()
    }
    
    func sendData() {
        if self.characteristic != nil && self.peripheral.state == CBPeripheralState.Connected {
            var message : [UInt8] = [
                UInt8(self.heaterBack),
                UInt8(self.heaterBottom),
                UInt8(self.fanBack),
                UInt8(self.fanBottom),
                UInt8(1)
            ]
            var bytes = NSData(bytes: &message, length: message.count)
            println("Sending bytes via bluetooth")
            println(bytes)
            self.peripheral.writeValue(bytes, forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithoutResponse)
        }
    }
    
    func sendTime(time: Int) {
        let unsigned = UInt32(time)
        if self.characteristic != nil {
            var message : [UInt8] = [
                UInt8(unsigned >> 24),
                UInt8((unsigned >> 16) & 0xFF),
                UInt8((unsigned >> 8) & 0xFF),
                UInt8((unsigned >> 8) & 0xFF),
                UInt8(0)
            ]
            var bytes = NSData(bytes: &message, length: message.count)
            println("Sending time via bluetooth")
            println(bytes)
            self.peripheral.writeValue(bytes, forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithoutResponse)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        println("Looking for services")
        for service in peripheral.services {
            let thisService = service as! CBService
            println(thisService.UUID)
            if thisService.UUID == ChairServiceUUID {
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        println("Looking for characteristic")
        for charateristic in service.characteristics {
            let thisCharacteristic = charateristic as! CBCharacteristic
            println(thisCharacteristic.UUID)
            if thisCharacteristic.UUID == ChairCharUUID {
                self.characteristic = thisCharacteristic
                self.peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("Received value")
        if characteristic.UUID == ChairCharUUID {
            var data = [UInt8](count: 9, repeatedValue: 0)
            characteristic.value.getBytes(&data, length: 9 * sizeof(UInt8))
            println(data)
            var temp = (Int(data[5]) << 8) + Int(data[6])
            var humidity = (Int(data[7]) << 8) + Int(data[8])
            self.occupancy = Int(data[4])
            self.heaterBack = Int(data[0])
            self.heaterBottom = Int(data[1])
            self.fanBack = Int(data[2])
            self.fanBottom = Int(data[3])
            self.smapService.heaterBack = Int(data[0])
            self.smapService.heaterBottom = Int(data[1])
            self.smapService.fanBack = Int(data[2])
            self.smapService.fanBottom = Int(data[3])
            
            NSNotificationCenter.defaultCenter().postNotificationName("kChairStateUpdateFromChair", object: nil);
            if self.macaddr != nil {
                var parameters: [String: AnyObject] = [
                    "macaddr": self.macaddr,
                    "occupancy": self.occupancy == 1 ? true : false,
                    "temperature": temp,
                    "humidity": humidity
                ]
                parameters["backf"] = Int(self.fanBack.value)
                parameters["bottomf"] = Int(self.fanBottom.value)
                parameters["backh"] = Int(self.heaterBack.value)
                parameters["bottomh"] = Int(self.heaterBottom.value)
                
                let oldTime = self.smapService.lastReceievedUpdate
                self.smapService.lastReceievedUpdate = Int.max
                Alamofire.request(.POST, "http://shell.storm.pm:38001", parameters: parameters, encoding: .JSON)
                    .responseJSON { (request, response, data, error) in
                        if error != nil {
                            println("Error during smap request")
                            self.smapService.lastReceievedUpdate = oldTime
                            println(request)
                            println(response)
                            println(data)
                            println(error)
                            return;
                        }
                        println("Response from SMAP")
                        println(data);
                        let json = JSON(data!)
                        if json["time"] != nil {
                            self.smapService.lastReceievedUpdate = json["time"].int!
                            self.sendTime(json["time"].int!)
                        }
                }
            }
        }
    }
}