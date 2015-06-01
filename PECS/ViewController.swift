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
import QRCodeReader
import AVFoundation


class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {

    let bleManager = (UIApplication.sharedApplication().delegate as! AppDelegate).bleManager
    let smapService = (UIApplication.sharedApplication().delegate as! AppDelegate).smapService
    var chair : Chair!
    var tableViewController : BLEListTableViewController?
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChairViewFromSmap", name: "kChairStateUpdateFromSmap", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChairViewFromChair", name: "kChairStateUpdateFromChair", object: nil);
        var chairName = NSUserDefaults.standardUserDefaults().objectForKey("chairName") as? String
        var macaddr = NSUserDefaults.standardUserDefaults().objectForKey("chairID") as? String
        if chairName != nil && macaddr != nil {
            let failed = self.connectToChair(chairName!, macaddr: macaddr!)
            if failed {
                self.displayQRCodeReader()
            }
        } else {
            self.displayQRCodeReader()
        }
    }
    
    func connectToChair(name: String, macaddr: String) -> Bool {
        let resultPredicate = NSPredicate(format: "name contains[c] %@", name)
        let results = self.bleManager.availableChairs.filteredArrayUsingPredicate(resultPredicate)
        if results.count > 0 {
            self.chair = results[0] as? Chair
            self.chair?.macaddr = macaddr
            self.smapService.macaddr = macaddr
            return false
        }
        return true
    }
    
    func displayQRCodeReader() {
        // Retrieve the QRCode content
        // By using the delegate pattern
        reader.delegate = self
        
        // Or by using the closure pattern
        reader.completionBlock = { (result: String?) in
            println("QR Code Result")
            println(result)
            if result != nil {
                let resultArr = result!.componentsSeparatedByString("?")
                if resultArr.count > 1 {
                    let query: String? = resultArr[1]
                    let queries = query!.componentsSeparatedByString("&")
                    if queries.count > 2 {
                        let nameParam: String? = queries[1]
                        let macaddrParam: String? = queries[2]
                        let macaddr = macaddrParam!.componentsSeparatedByString("=")[1]
                        let param = nameParam!.componentsSeparatedByString("=")
                        if param.count > 1 {
                            let name: String? = param[1]
                            NSUserDefaults.standardUserDefaults().setObject(name, forKey: "chairName")
                            NSUserDefaults.standardUserDefaults().setObject(macaddr, forKey: "chairID")
                            self.connectToChair(name!, macaddr: macaddr)
                        }
                    }
                }
            }
        }
        
        // Presents the reader as modal form sheet
        reader.modalPresentationStyle = .FormSheet
        presentViewController(reader, animated: true, completion: nil)
    }
    
    @IBAction func scanAction(sender: AnyObject) {
        self.displayQRCodeReader()
    }
    
    
    func reader(reader: QRCodeReaderViewController, didScanResult result: String) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var heaterBackSlider: UISlider!
    @IBAction func resetBackSlider(sender: AnyObject) {
        self.heaterBackSlider.value = 0
    }

    @IBOutlet weak var heaterBottomSlider: UISlider!
    @IBAction func resetBottomSlider(sender: AnyObject) {
        self.heaterBottomSlider.value = 0
    }

    // Update SMAP when the state of the chair changes
    @IBAction func stateDidChange(sender: AnyObject) {
        if self.chair == nil {
            return
        }
        if self.chair.peripheral.state != CBPeripheralState.Connected {
            self.handleChairDisconnect()
            return
        }
        
        if self.heaterBackSlider.value > 0 {
            self.smapService.fanBack = Int(0)
            self.smapService.heaterBack = Int(self.heaterBackSlider.value)
        } else {
            self.smapService.fanBack = Int(-self.heaterBackSlider.value)
            self.smapService.heaterBack = Int(0)
        }
        
        if self.heaterBottomSlider.value > 0 {
            self.smapService.fanBottom = Int(0)
            self.smapService.heaterBottom = Int(self.heaterBottomSlider.value)
        } else {
            self.smapService.fanBottom = Int(-self.heaterBottomSlider.value)
            self.smapService.heaterBottom = Int(0)
        }

        self.smapService.update(false)
        self.chair.updateChair()
    }
    
    func updateChairViewFromSmap() {
        if self.chair != nil {
            if self.chair.peripheral.state != CBPeripheralState.Connected {
                self.handleChairDisconnect()
                return
            }

            self.heaterBackSlider.value = Float(-self.smapService.heaterBack + self.smapService.fanBack)
            self.heaterBottomSlider.value = Float(-self.smapService.heaterBottom + self.smapService.fanBottom)
        }
    }
    
    func handleChairDisconnect() {
        let alertController = UIAlertController(title: "Lost connection with chair", message:
            "Please reconnect by scanning the QR code", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in
                self.displayQRCodeReader()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateChairViewFromChair() {
        if self.chair != nil {
            self.heaterBackSlider.value = Float(-self.chair.heaterBack + self.chair.fanBack)
            
            self.heaterBottomSlider.value = Float(-self.chair.heaterBottom + self.chair.fanBottom)
        }
    }
}

