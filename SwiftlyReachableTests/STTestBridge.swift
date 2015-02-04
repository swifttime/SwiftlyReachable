//
//  STTestBridge.swift
//  SwiftlyReachable
//
//  Created by Rick Windham on 2/4/15.
//  Copyright (c) 2015 SwiftTime. All rights reserved.
//

import Foundation
import SystemConfiguration

typealias changeBlock = ((UInt32) -> Void)

class STReachabilityBridge {
    var monitoring:Bool = false
    var target:SCNetworkReachability!
    var block:changeBlock!
    
    init(target:SCNetworkReachability, andBlock block:changeBlock) {
        println("statusFlags \(statusFlags)")
        self.block = block
    }
    
    deinit {
        println("*** bridge de-init ***")
    }
    
    func startMonitoring() -> Bool {
        dispatch_async(dispatch_get_main_queue()) {self.block(statusFlags)}
        
        return true
    }
    
    func stopMonitoring() {
        monitoring = false
    }
    
    func getStatus() -> UInt32 {
        return statusFlags
    }
}