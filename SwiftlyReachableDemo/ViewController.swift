//
//  ViewController.swift
//  SwiftlyReachableDemo
//
//  Created by Rick Windham on 2/4/15.
//  Copyright (c) 2015 SwiftTime. All rights reserved.
//

import UIKit
import SwiftlyReachable

class ViewController: UIViewController {

    // MARK: - outlets
    
    @IBOutlet weak var flagsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var monitorButton: UIButton!
    
    // MARK: - properties
    
    let reachability = STReachability()
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        reachability.changedBlock = {[weak self] status in
            if let strongSelf = self {
                strongSelf.flagsLabel.text = strongSelf.reachability.binaryFlags
                strongSelf.statusLabel.text = strongSelf.statusString(status)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateStatus()
    }
    
    // MARK: - actions
    
    @IBAction func monitorAction(sender: AnyObject) {
        if reachability.isMonitoring {
            reachability.startMonitor()
            monitorButton.setTitle("Start", forState: .Normal)
        } else {
            if reachability.startMonitor() {
                monitorButton.setTitle("Stop", forState: .Normal)
            }
        }
    }
    
    @IBAction func getStatusAction(sender: AnyObject) {
        updateStatus()
    }
    
    // MARK: - functions
    
    func updateStatus() {
        flagsLabel.text = reachability.binaryFlags
        statusLabel.text = statusString(reachability.getStatus())
    }
    
    func statusString(status:STReachability.Status) -> String {
        switch (status) {
        case (.ViaCellData):
            return "Cell Data"
        case (.ViaWiFi):
            return "WiFi"
        case (.Unknown):
            return "Unknown"
        default:
            return "None"
        }
    }
    

}

