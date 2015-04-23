//
//  Chair.swift
//  PECS
//
//  Created by Leonard Truong on 4/22/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import Foundation
import CoreBluetooth


class Chair: NSObject{
    
    var name: NSString = ""
    var peripheral: CBPeripheral!
    var rssi: NSNumber!
    var characteristic: CBCharacteristic!
    
    init(name: String, peripheral: CBPeripheral, rssi: NSNumber!){
        self.name = name
        self.peripheral = peripheral
        self.rssi = rssi
    }
    
    func sendData() {
        var enableValue = 1
        let enableBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        self.peripheral.writeValue(enableBytes, forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithResponse)
    }
    
}