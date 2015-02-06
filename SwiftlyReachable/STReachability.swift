//
//  STReachability.swift
//  SwiftlyReachable
//
//  Created by Rick Windham on 2/4/15.
//  Copyright (c) 2015 SwiftTime. All rights reserved.
//

import Foundation
import SystemConfiguration


public class STReachability {

    // MARK: - data structures
    
    public enum STReachabilityStatus {
        case Unknown
        case UnReachable
        case ViaWiFi
        case ViaCellData
    }
    
    public struct STReachabilityFlags {
        enum ReachabilityFlags:UInt32 {
            case Unknown = 0
            case TransientConnection = 1 // 1<<0
            case Reachable = 2 // 1<<1
            case ConnectionRequired = 4 // 1<<2
            case ConnectionOnTraffic, ConnectionAutomatic = 8 // 1<<3
            case InterventionRequired = 16 // 1<<4
            case ConnectionOnDemand = 32 // 1<<5
            case IsLocalAddress = 65_536 // 1<<16
            case IsDirect = 131_072 // 1<<17
            case IsWWAN = 262_144 // 1<<18
        }
        
        var flags:UInt32 = 0
        
        func isSet(flag:ReachabilityFlags) -> Bool {
            return flags & flag.rawValue > 0
        }
    }
    
    // MARK: - demo app property
    
    public var binaryFlags:String {
        var fmtString = ""
        var fmtFlags = flags.flags
        
        do {
            let temp = fmtFlags & 1 > 0 ? "1" : "0"
            fmtString = temp + fmtString
            fmtFlags /= 2;
        } while fmtFlags > 0
        
        return String(count: 32 - fmtString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), repeatedValue: Character("0")) + fmtString
    }
    
    // MARK: - properties
    
    public   var changedBlock:((STReachabilityStatus)->())?

    public   var isMonitoring:Bool {
        get {
            return bridge.monitoring
        }
    }
    
    internal var status:STReachabilityStatus = .Unknown
    private  let reachability:SCNetworkReachability
    
    private var bridge:STReachabilityBridge!
    
    private var flags:STReachabilityFlags = STReachabilityFlags() {
        didSet {
            if flags.flags != oldValue.flags {
                updateStatus()
                
                if let block = changedBlock {
                    dispatch_async(dispatch_get_main_queue()) {block(self.status)}
                }
            }
        }
    }
    
    // MARK: - lifecycle
    
    public convenience init() {
        self.init(nodeName: "www.apple.com")
    }
    
    public init(nodeName:String) {
        /*
        // alternate to node name method
        
        var address = sockaddr(sa_len: UInt8(sizeof(sockaddr)),
        sa_family: sa_family_t(AF_INET),
        sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0))
        
        reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &address).takeRetainedValue()
        */
        
        
        reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, nodeName).takeRetainedValue()
        
        bridge = STReachabilityBridge(target:reachability, andBlock:{[weak self] newFlags
            in
            
            if let strongSelf = self {
                strongSelf.flags.flags = newFlags
            }
            
            return Void()
        })

        updateFlags()
    }
    
    deinit {
        
    }
    
    // MARK: - functions
    
    public func getUpdate() {
        updateFlags()
    }
    
    public func getStatus() -> STReachabilityStatus {
        return status
    }
    
    public func startMonitor() -> Bool {
        return bridge.startMonitoring()
    }
    
    public func stopMonitor() {
        bridge.stopMonitoring()
    }
    
    public func statusHasUpdated(newFlags: UInt32) {
        flags.flags = newFlags
    }

    private func updateStatus() {
        if flags.isSet(.IsWWAN) {
            status = .ViaCellData
        } else if flags.isSet(.Reachable) {
            status = .ViaWiFi
        } else {
            status = .UnReachable
        }
    }

    private func updateFlags() {
        flags.flags = bridge.getStatus();
    }
    
}