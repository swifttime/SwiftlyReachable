//
//  STReachabilityBridge.m
//  SwiftlyReachable
//
//  Created by Rick Windham on 2/4/15.
//  Copyright (c) 2015 SwiftTime. All rights reserved.
//

#import "STReachabilityBridge.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <SwiftlyReachable/SwiftlyReachable-Swift.h>

@interface STReachabilityBridge ()
@property (assign) BOOL monitoring;
@property (nonatomic, strong) dispatch_queue_t  reachabilitySerialQueue;
@end

static void STReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void* info) {
    
    changeBlock block = (__bridge changeBlock)info;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        block(flags);
    });
}

@implementation STReachabilityBridge

+ (STReachabilityBridge *)bridgeWithTarget:(SCNetworkReachabilityRef)target andBlock:(changeBlock)block {
    return [[STReachabilityBridge alloc] initWithTarget:target andBlock:block];
}

- (instancetype)initWithTarget:(SCNetworkReachabilityRef)target andBlock:(changeBlock)block {
    self = [super init];
    if (!self) {
        return nil;
    }
    _monitoring = NO;
    _block = block;
    _target = target;
    
    return self;
}

- (BOOL)startMonitoring {
    [self stopMonitoring];
    
    SCNetworkReachabilityContext    context = { 0, NULL, NULL, NULL, NULL };
    
    _reachabilitySerialQueue = dispatch_queue_create("me.swiftti.streachability", NULL);
    if(_reachabilitySerialQueue == nil)
    {
        return NO;
    }
    
    context.info = (__bridge void *)_block;
    
    if (!SCNetworkReachabilitySetCallback(_target, STReachabilityCallback, &context)) {
        
        SCNetworkReachabilitySetCallback(_target, NULL, NULL);
        
        if (_reachabilitySerialQueue) {
            _reachabilitySerialQueue = nil;
        }
        
        return NO;
    }
    
    if (!SCNetworkReachabilitySetDispatchQueue(_target, _reachabilitySerialQueue)) {
        SCNetworkReachabilitySetCallback(_target, NULL, NULL);
        if (_reachabilitySerialQueue) {
            _reachabilitySerialQueue = nil;
        }
        
        return NO;
    }
    _monitoring = YES;
    
    return YES;
}

- (void)stopMonitoring {
    SCNetworkReachabilitySetCallback(_target, NULL, NULL);
    SCNetworkReachabilitySetDispatchQueue(_target, NULL);
    _reachabilitySerialQueue = nil;
    _monitoring = NO;
}

- (UInt32)getStatus {
    UInt32 flags;
    
    if (!SCNetworkReachabilityGetFlags(_target, &flags)) {
        return 0;
    }
    
    return flags;
}

@end
