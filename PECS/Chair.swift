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
    
    let ChairServiceUUID = CBUUID(string: "FFE0")
    let ChairCharUUID = CBUUID(string: "FFE1")
    
    init(name: String, peripheral: CBPeripheral, rssi: NSNumber!){
        self.heaterBottom = 0
        self.heaterBack = 0
        self.fanBottom = 0
        self.fanBack = 0
        super.init()
        self.name = name
        self.peripheral = peripheral
        self.rssi = rssi
        self.peripheral.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChair", name: "kChairStateUpdateFromSmap", object: nil);
    }
    
    func updateChair() {
        self.heaterBack = self.smapService.heaterBack
        self.heaterBottom = self.smapService.heaterBottom
        self.fanBack = self.smapService.fanBack
        self.fanBottom = self.smapService.fanBottom
        self.sendData()
    }
    
    func sendData() {
        if self.characteristic != nil {
            var message : [UInt8] = [
                UInt8(self.heaterBack),
                UInt8(self.heaterBottom),
                UInt8(self.fanBack),
                UInt8(self.fanBottom)
            ]
            var bytes = NSData(bytes: &message, length: message.count)
            println("Sending bytes via bluetooth")
            println(bytes)
            self.peripheral.writeValue(bytes, forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithoutResponse)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if characteristic == self.characteristic {
            print(error)
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
            var data = [UInt8](count: 5, repeatedValue: 0)
            characteristic.value.getBytes(&data, length: 5 * sizeof(UInt8))
            self.heaterBack = Int(data[0])
            self.heaterBottom = Int(data[1])
            self.fanBack = Int(data[2])
            self.fanBottom = Int(data[3])
            NSNotificationCenter.defaultCenter().postNotificationName("kChairStateUpdateFromChair", object: nil);
        }
    }
}