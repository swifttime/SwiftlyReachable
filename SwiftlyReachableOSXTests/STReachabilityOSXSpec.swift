//
//  STReachabilityOSXSpec.swift
//  SwiftlyReachable
//
//  Created by Rick Windham on 2/16/15.
//  Copyright (c) 2015 SwiftTime. All rights reserved.
//

import Cocoa
import Quick
import Nimble

public var statusFlags:UInt32 = 0

class STReachabilityOSXSpec: QuickSpec {

    override func spec() {
        let FLAGS_FOR_UNREACHABLE:UInt32 = 0b0
        let FLAGS_FOR_WIFI:UInt32        = 0b10
        let FLAGS_FOR_CELL:UInt32        = 0b1000000000000000011

        let STATUS_UNREACHABLE = STReachability.Status.UnReachable
        let STATUS_WIFI        = STReachability.Status.ViaWiFi
        let STATUS_CELL        = STReachability.Status.ViaCellData

        var reachability:STReachability!
        
        beforeEach {
            reachability = STReachability()
        }
        
        describe("STReachability") {
            context("when background updates are started") {
                it("should execute the block when the status changes") {
                    statusFlags = FLAGS_FOR_WIFI
                    var blockStatus:STReachability.Status = .Unknown
                    reachability.changedBlock = {status
                        in
                        blockStatus = status
                    }
                    reachability.startMonitor()
                    expect(blockStatus).toEventually(equal(STATUS_WIFI), timeout: 3, pollInterval: 0.5)
                }
            }
        }
    }
}