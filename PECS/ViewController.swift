//
//  ViewController.swift
//  PECS
//
//  Created by Leonard Truong on 4/4/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import UIKit
import Alamofire
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    var chair : Chair!
    var availableChairs : NSMutableArray = []

    @IBOutlet weak var chairLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restoreChairState()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager(delegate: self, queue: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveSwitchesStates", name: "kSaveChairState", object: nil);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showBLEListSegue" {
            var controller = segue.destinationViewController as! UINavigationController
            var tableViewController = controller.viewControllers.first as! BLEListTableViewController
            tableViewController.availableChairs = self.availableChairs
        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        var source: BLEListTableViewController = segue.sourceViewController as! BLEListTableViewController
        println(source.chosenChair)
        if let chair = source.chosenChair {
            self.chair = chair
            self.chairLabel.text = chair.name as String
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var heaterBackSlider: UISlider!
    @IBOutlet weak var heaterBackLabel: UILabel!
    @IBAction func heaterBackSliderChanged(sender: AnyObject) {
        self.heaterBackLabel.text = "\(Int(self.heaterBackSlider.value))"
    }

    @IBOutlet weak var heaterBottomLabel: UILabel!
    @IBOutlet weak var heaterBottomSlider: UISlider!
    @IBAction func heaterBottomSliderChanged(sender: UISlider) {
        self.heaterBottomLabel.text = "\(Int(sender.value))"
    }

    @IBOutlet weak var fanBackLabel: UILabel!
    @IBOutlet weak var fanBackSlider: UISlider!
    @IBAction func fanBackSliderChanged(sender: UISlider) {
        self.fanBackLabel.text = "\(Int(sender.value))"
    }
    @IBOutlet weak var fanBottomLabel: UILabel!
    @IBOutlet weak var fanBottomSlider: UISlider!
    @IBAction func fanBottomSliderChanged(sender: UISlider) {
        self.fanBottomLabel.text = "\(Int(sender.value))"
    }
    @IBOutlet weak var seatedSwitch: UISwitch!
    @IBAction func seatedSwitchClicked(sender: UISwitch) {
        if sender.on {
            sender.setOn(false, animated:true)
        } else {
            sender.setOn(true, animated:true)
        }
    }
    @IBAction func stateDidChange(sender: AnyObject) {
        let parameters: [String: AnyObject] = [
            "macaddr": "12345",
            "backf": Int(self.fanBackSlider.value),
            "bottomf": Int(self.fanBottomSlider.value),
            "backh": Int(self.heaterBackSlider.value),
            "bottomh": Int(self.heaterBottomSlider.value),
        ]

        Alamofire.request(.POST, "http://shell.storm.pm:38001", parameters: parameters, encoding: .JSON)
                 .responseJSON { (request, response, data, error) in
                    println(request)
                    println(response)
                    println(data)
                    println(error)
        }
    }

    @IBAction func syncWithSMAP(sender: AnyObject) {
        let bottomHeater = "select data before now where uuid = a99daf41-f3b3-51a7-97bf-48fb3e7bf130"

        let queries = [
            [
                "query": "select data before now where uuid = a99daf41-f3b3-51a7-97bf-48fb3e7bf130",
                "slider": self.heaterBottomSlider,
                "label": self.heaterBottomLabel
            ],
            [
                "query": "select data before now where uuid = 33ecc20c-e636-58eb-863f-142717105075",
                "slider": self.heaterBackSlider,
                "label": self.heaterBackLabel
            ],
            [
                "query": "select data before now where uuid = b7ef2e98-2e0a-515b-b534-69894fdddf6f",
                "slider": self.fanBottomSlider,
                "label": self.fanBottomLabel
            ],
            [
                "query": "select data before now where uuid = 27e1e889-b749-5cf9-8f90-5cc5f1750ddf",
                "slider": self.fanBackSlider,
                "label": self.fanBackLabel
            ]
        ]
        for info in queries {
            let URL = NSURL(string: "http://shell.storm.pm:8079/api/query")!
            let mutableURLRequest = NSMutableURLRequest(URL: URL)
            mutableURLRequest.HTTPMethod = "POST"

            mutableURLRequest.HTTPBody = (info["query"] as! String).dataUsingEncoding(NSUTF8StringEncoding)
            Alamofire.request(mutableURLRequest)
                .responseJSON { (request, response, data , error) in
                    println(data)
                    if let respArr = data as? NSArray{
                        if let resp = respArr[0] as? NSDictionary{
                            if let readings = resp["Readings"] as? NSArray{
                                if let values = readings[0] as? NSArray{
                                    (info["slider"] as! UISlider).value = values[1] as! Float
                                    (info["label"] as! UILabel).text = "\(values[1] as! Int)"
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func saveChairState() {
        NSUserDefaults.standardUserDefaults().setInteger(Int(self.heaterBackSlider.value), forKey: "heaterBackSlider")
        NSUserDefaults.standardUserDefaults().setInteger(Int(self.heaterBottomSlider.value), forKey: "heaterBottomSlider")
        NSUserDefaults.standardUserDefaults().setInteger(Int(self.fanBackSlider.value), forKey: "fanBackSlider")
        NSUserDefaults.standardUserDefaults().setInteger(Int(self.fanBottomSlider.value), forKey: "fanBottomSlider")
        NSUserDefaults.standardUserDefaults().setInteger(Int(self.fanBottomSlider.value), forKey: "fanBottomSlider")
        NSUserDefaults.standardUserDefaults().setBool(self.seatedSwitch!.on, forKey: "seated")
    }

    func restoreChairState() {
        self.seatedSwitch!.on = NSUserDefaults.standardUserDefaults().boolForKey("seated")

        var fanBottom = NSUserDefaults.standardUserDefaults().integerForKey("fanBottomSlider")
        self.fanBottomLabel.text = "\(fanBottom)"
        self.fanBottomSlider.value = Float(fanBottom)
        var fanBack = NSUserDefaults.standardUserDefaults().integerForKey("fanBackSlider")
        self.fanBackLabel.text = "\(fanBack)"
        self.fanBackSlider.value = Float(fanBottom)

        var heaterBottom = NSUserDefaults.standardUserDefaults().integerForKey("heaterBottomSlider")
        self.heaterBottomLabel.text = "\(heaterBottom)"
        self.heaterBottomSlider.value = Float(heaterBottom)
        var heaterBack = NSUserDefaults.standardUserDefaults().integerForKey("heaterBackSlider")
        self.heaterBackLabel.text = "\(heaterBack)"
        self.heaterBackSlider.value = Float(heaterBack)
    }
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            println("Bluetooth switched off or not initialized")
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? String
        
        if nameOfDeviceFound != nil {
            var chair = Chair(name: nameOfDeviceFound!, peripheral: peripheral)
            self.availableChairs.addObject(chair)
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        //self.bleStatusLabel.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
    }
    
    // Check if the service discovered is a valid IR Temperature Service
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        //self.bleStatusLabel.text = "Looking at peripheral services"
        for service in peripheral.services {
            let thisService = service as! CBService
//            if service.UUID == IRTemperatureServiceUUID {
//                // Discover characteristics of IR Temperature Service
//                peripheral.discoverCharacteristics(nil, forService: thisService)
//            }
            // Uncomment to print list of UUIDs
            println(thisService.UUID)
        }
    }
}

