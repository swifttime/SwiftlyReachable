//
//  SwiftlyReachableTests.swift
//  SwiftlyReachableTests
//
//  Created by Rick Windham on 2/4/15.
//  Copyright (c) 2015 SwiftTime. All rights reserved.
//
#if os(iOS)
    import UIKit
    #else
    import Cocoa
#endif

import XCTest

public var statusFlags:UInt32 = 0

class SwiftlyReachableTests: XCTestCase {
    
    let FLAGS_FOR_UNREACHABLE:UInt32 = 0b0
    let FLAGS_FOR_WIFI:UInt32 = 0b10
    let FLAGS_FOR_CELL:UInt32 = 0b1000000000000000011
    
    let STATUS_UNREACHABLE = STReachability.Status.UnReachable
    let STATUS_WIFI        = STReachability.Status.ViaWiFi
    let STATUS_CELL        = STReachability.Status.ViaCellData
    
    var reachability:STReachability! = nil
    var expect:XCTestExpectation! = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        reachability = STReachability()
        expect = self.expectationWithDescription("blockExpectation")
    }
    
    override func tearDown() {
        reachability = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStatusChangedBlock() {
        
        var blockStatus:STReachability.Status = .UnReachable
        statusFlags = FLAGS_FOR_WIFI
        reachability.changedBlock = {status
            in
            blockStatus = status
            self.expect.fulfill()
        }
        reachability.startMonitor()
        
        self.waitForExpectationsWithTimeout(2.5, handler: nil)
        
        XCTAssertEqual(blockStatus, self.STATUS_WIFI, "status should be ViaWiFi")
    }
    
}
