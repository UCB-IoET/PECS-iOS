//
//  ViewController.swift
//  PECS
//
//  Created by Leonard Truong on 4/4/15.
//  Copyright (c) 2015 Leonard Truong. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.restoreChairState()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveSwitchesStates", name: "kSaveChairState", object: nil);

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
            "backFan": Int(self.fanBackSlider.value),
            "bottomFan": Int(self.fanBottomSlider.value),
            "backHeater": Int(self.heaterBackSlider.value),
            "bottomHeater": Int(self.heaterBottomSlider.value),
            "occupancy": self.seatedSwitch!.on
        ]
        
        Alamofire.request(.POST, "http://shell.storm.pm:38027", parameters: parameters, encoding: .JSON)
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
}

