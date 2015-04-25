//
//  BLEManager.swift
//  PECS
//
//  Created by Leonard Truong on 4/23/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import Foundation
import CoreBluetooth


class BLEManager: NSObject, CBCentralManagerDelegate {
    var centralManager : CBCentralManager!
    var availableChairs : NSMutableArray = []
    
    let ChairServiceUUID = CBUUID(string: "FFE0")
    let ChairCharUUID = CBUUID(string: "FFE1")
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scan() {
        self.availableChairs = []
        let services = [ChairServiceUUID]
        self.centralManager.scanForPeripheralsWithServices(services, options: nil)
    }
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            println("Bluetooth succesfully enabled")
            self.scan()
        }
        else {
            println("Bluetooth switched off or not initialized")
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if peripheral.name != nil {
            let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as! String
            var chair = Chair(name: nameOfDeviceFound, peripheral: peripheral, rssi: RSSI)
            self.availableChairs.addObject(chair)
            NSNotificationCenter.defaultCenter().postNotificationName("kNewChairFound", object: nil);
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Discovering services")
        peripheral.discoverServices(nil)
    }

}