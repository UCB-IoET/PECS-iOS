//
//  BLEListTableViewController.swift
//  PECS
//
//  Created by Leonard Truong on 4/22/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import UIKit
import CoreBluetooth
import QRCodeReader
import AVFoundation


class BLEListTableViewController : UITableViewController, QRCodeReaderViewControllerDelegate {

    let bleManager = (UIApplication.sharedApplication().delegate as! AppDelegate).bleManager
    var chosenChair: Chair?
    var centralManager : CBCentralManager!
    var targetNameFromQr: String?
    var smapService = (UIApplication.sharedApplication().delegate as! AppDelegate).smapService
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadView", name: "kNewChairFound", object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Called either when the cancel button is tapped or an item in the list is chosen.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if bleManager.availableChairs.count > 0 {
            var indexPath = self.tableView.indexPathForSelectedRow()
            if indexPath != nil {
                self.chosenChair = bleManager.availableChairs.objectAtIndex(indexPath!.row) as? Chair
                self.tableView.reloadData()
            }
        }
    }
    
    // Trigger a new scan to refresh list of available peripherals
    @IBAction func scanForPeripherals(sender: AnyObject!) {
        bleManager.scan()
        self.tableView.reloadData()
    }
    
    @IBAction func scanAction(sender: AnyObject) {
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
                        let macaddr = macaddrParam!.componentsSeparatedByString("=")
                        let param = nameParam!.componentsSeparatedByString("=")
                        if param.count > 1 {
                            let name: String? = param[1]
                            let resultPredicate = NSPredicate(format: "name contains[c] %@", name!)
                            let results = self.bleManager.availableChairs.filteredArrayUsingPredicate(resultPredicate)
                            if results.count > 0 {
                                self.chosenChair = results[0] as? Chair
                                self.chosenChair?.macaddr = macaddr[1]
                                self.smapService.macaddr = macaddr[1]
                                self.performSegueWithIdentifier("unwindToMain", sender: self)
                            }
                        }
                    }
                }
            }
        }
        
        // Presents the reader as modal form sheet
        reader.modalPresentationStyle = .FormSheet
        presentViewController(reader, animated: true, completion: nil)
    }
    
    func reader(reader: QRCodeReaderViewController, didScanResult result: String) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reloadView() {
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleManager.availableChairs.count
    }
    
    // Display nearby chairs and their RSSI value
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIndentifier: NSString = "ListPrototypeCell"
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIndentifier as String) as! UITableViewCell
        var chair: Chair = bleManager.availableChairs.objectAtIndex(indexPath.row) as! Chair
        cell.textLabel?.text = "\(chair.name as String)"
        cell.detailTextLabel?.text = "RSSI: \(chair.rssi)"
        if chair == self.chosenChair {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

