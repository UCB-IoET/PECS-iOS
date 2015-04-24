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
    let smapService = (UIApplication.sharedApplication().delegate as! AppDelegate).smapService
    var chair : Chair!
    var tableViewController : BLEListTableViewController?
    @IBOutlet weak var disconnectFromChairButton: UIButton!


    @IBOutlet weak var chairLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        disconnectFromChairButton.hidden = self.chair == nil
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChairView", name: "kChairStateUpdate", object: nil);
    }
    
    // Called when the list of nearby chairs view is closed.
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        self.tableViewController = nil
        var source: BLEListTableViewController = segue.sourceViewController as! BLEListTableViewController
        
        // If a chair was chosen from the list
        if let chair = source.chosenChair {
            self.chair = chair
            self.chairLabel.text = chair.name as String
            // Connect to the BLE peripheral associated with the chair
            self.bleManager.centralManager.connectPeripheral(chair.peripheral, options: nil)
            disconnectFromChairButton.hidden = false
        }
    }
    
    // Disconnect from the current chair peripheral
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

    // Update SMAP when the state of the chair changes
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
    
    func updateChairView() {
        self.fanBackSlider.value = Float(self.smapService.fanBack)
        self.fanBackLabel.text = "\(self.smapService.fanBack)"

        self.fanBottomSlider.value = Float(self.smapService.fanBottom)
        self.fanBottomLabel.text = "\(self.smapService.fanBottom)"
        
        self.heaterBackSlider.value = Float(self.smapService.heaterBack)
        self.heaterBackLabel.text = "\(self.smapService.heaterBack)"
        
        self.heaterBottomSlider.value = Float(self.smapService.heaterBottom)
        self.heaterBottomLabel.text = "\(self.smapService.heaterBottom)"
    }
}

