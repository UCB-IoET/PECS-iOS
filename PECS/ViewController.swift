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


class ViewController: UIViewController {

    let bleManager = (UIApplication.sharedApplication().delegate as! AppDelegate).bleManager
    var chair : Chair!
    var tableViewController : BLEListTableViewController?
    @IBOutlet weak var disconnectFromChairButton: UIButton!


    @IBOutlet weak var chairLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restoreChairState()
        // Do any additional setup after loading the view, typically from a nib.
        disconnectFromChairButton.hidden = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveChairState", name: "kSaveChairState", object: nil);
    }

    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        self.tableViewController = nil
        var source: BLEListTableViewController = segue.sourceViewController as! BLEListTableViewController
        if let chair = source.chosenChair {
            self.chair = chair
            self.chairLabel.text = chair.name as String
            self.bleManager.centralManager.connectPeripheral(chair.peripheral, options: nil)
            disconnectFromChairButton.hidden = false
        }
    }
    
    @IBAction func disconnectFromChair(sender: AnyObject) {
        if self.chair != nil {
            self.bleManager.centralManager.cancelPeripheralConnection(self.chair.peripheral)
            self.chair = nil
            self.disconnectFromChairButton.hidden = true
            self.chairLabel.text = "None"
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
    }

    func restoreChairState() {

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
}

