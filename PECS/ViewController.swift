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


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChairViewFromSmap", name: "kChairStateUpdateFromSmap", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChairViewFromChair", name: "kChairStateUpdateFromChair", object: nil);
        if self.chair == nil {
            performSegueWithIdentifier("showBLEListSegue", sender: self)
        }
    }
    
    // Called when the list of nearby chairs view is closed.
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        self.tableViewController = nil
        var source: BLEListTableViewController = segue.sourceViewController as! BLEListTableViewController
        
        // If a chair was chosen from the list
        if let chair = source.chosenChair {
            self.chair = chair
            // Connect to the BLE peripheral associated with the chair
            self.bleManager.centralManager.connectPeripheral(chair.peripheral, options: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBLEListSegue" {
            if self.chair != nil {
                self.bleManager.centralManager.cancelPeripheralConnection(self.chair.peripheral)
                self.chair = nil
            }
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
        if self.chair.peripheral.state != CBPeripheralState.Connected {
            self.performSegueWithIdentifier("showBLEListSegue", sender: self)
            return
        }
        self.smapService.fanBack = Int(self.fanBackSlider.value)
        self.smapService.fanBottom = Int(self.fanBottomSlider.value)
        self.smapService.heaterBack = Int(self.heaterBackSlider.value)
        self.smapService.heaterBottom = Int(self.heaterBottomSlider.value)
        self.smapService.update()
        self.chair.updateChair()
    }
    
    func updateChairViewFromSmap() {
        if self.chair != nil {
            if self.chair.peripheral.state != CBPeripheralState.Connected {
                self.performSegueWithIdentifier("showBLEListSegue", sender: self)
                return
            }
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
    
    func updateChairViewFromChair() {
        if self.chair != nil {
            self.fanBackSlider.value = Float(self.chair.fanBack)
            self.fanBackLabel.text = "\(self.chair.fanBack)"
            
            self.fanBottomSlider.value = Float(self.chair.fanBottom)
            self.fanBottomLabel.text = "\(self.chair.fanBottom)"
            
            self.heaterBackSlider.value = Float(self.chair.heaterBack)
            self.heaterBackLabel.text = "\(self.chair.heaterBack)"
            
            self.heaterBottomSlider.value = Float(self.chair.heaterBottom)
            self.heaterBottomLabel.text = "\(self.chair.heaterBottom)"
        }
    }
}

