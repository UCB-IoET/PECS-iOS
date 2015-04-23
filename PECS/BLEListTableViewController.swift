//
//  BLEListTableViewController.swift
//  PECS
//
//  Created by Leonard Truong on 4/22/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEListTableViewController : UITableViewController {

    let bleManager = (UIApplication.sharedApplication().delegate as! AppDelegate).bleManager
    var chosenChair: Chair?
    var centralManager : CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadView", name: "kNewChairFound", object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if bleManager.availableChairs.count > 0 {
            var indexPath = self.tableView.indexPathForSelectedRow()
            if indexPath != nil {
                self.chosenChair = bleManager.availableChairs.objectAtIndex(indexPath!.row) as? Chair
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func scanForPeripherals(sender: AnyObject!) {
        bleManager.scan()
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIndentifier: NSString = "ListPrototypeCell"
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIndentifier as String) as! UITableViewCell
        var chair: Chair = bleManager.availableChairs.objectAtIndex(indexPath.row) as! Chair
        cell.textLabel?.text = "\(chair.name as String) - RSSI: \(chair.rssi)"
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
