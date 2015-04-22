//
//  BLEListTableViewController.swift
//  PECS
//
//  Created by Leonard Truong on 4/22/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import UIKit

class BLEListTableViewController : UITableViewController {

    var availableChairs : NSMutableArray = []
    var chosenChair: Chair?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if self.availableChairs.count > 0 {
            var indexPath = self.tableView.indexPathForSelectedRow()
            if indexPath != nil {
                self.chosenChair = self.availableChairs.objectAtIndex(indexPath!.row) as? Chair
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableChairs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIndentifier: NSString = "ListPrototypeCell"
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIndentifier as String) as! UITableViewCell
        var chair: Chair = self.availableChairs.objectAtIndex(indexPath.row) as! Chair
        cell.textLabel?.text = chair.name as String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

