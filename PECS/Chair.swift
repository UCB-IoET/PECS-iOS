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
    var peripheral: CBPeripheral?
    
    init(name: String, peripheral: CBPeripheral){
        self.name = name
        self.peripheral = peripheral
    }
    
}