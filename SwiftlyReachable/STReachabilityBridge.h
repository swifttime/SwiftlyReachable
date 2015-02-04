//
//  STReachabilityBridge.h
//  SwiftlyReachable
//
//  Created by Rick Windham on 2/4/15.
//  Copyright (c) 2015 SwiftTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@class STReachability;

typedef void(^changeBlock)(UInt32);

@interface STReachabilityBridge : NSObject
@property (nonatomic, strong) changeBlock block;
@property (assign) SCNetworkReachabilityRef target;
@property (assign, readonly) BOOL monitoring;
+ (STReachabilityBridge *)bridgeWithTarget:(SCNetworkReachabilityRef)target andBlock:(changeBlock)block;
- (instancetype)initWithTarget:(SCNetworkReachabilityRef)target andBlock:(changeBlock)block;
- (BOOL)startMonitoring;
- (void)stopMonitoring;
- (UInt32)getStatus;
@end