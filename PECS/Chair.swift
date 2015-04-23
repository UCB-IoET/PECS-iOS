//
//  Chair.swift
//  PECS
//
//  Created by Leonard Truong on 4/22/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import Foundation
import CoreBluetooth


class Chair: NSObject, CBPeripheralDelegate {
        
    var name: NSString = ""
    var peripheral: CBPeripheral!
    var rssi: NSNumber!
    var characteristic: CBCharacteristic!
    
    let ChairServiceUUID = CBUUID(string: "FFE0")
    let ChairCharUUID = CBUUID(string: "FFE1")
    
    init(name: String, peripheral: CBPeripheral, rssi: NSNumber!){
        super.init()
        self.name = name
        self.peripheral = peripheral
        self.rssi = rssi
        self.peripheral.delegate = self
    }
    
    func sendData() {
        var enableValue = 1
        let enableBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        self.peripheral.writeValue(enableBytes, forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithResponse)
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
            println(characteristic.value)
        }
    }
}