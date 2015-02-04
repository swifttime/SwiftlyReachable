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

    let reachability = STReachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        reachability.changedBlock = {status in
            NSLog("status changed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if reachability.startMonitor() {
            NSLog("Started: true")
        } else {
            NSLog("Started: false")
        }
    }
}

