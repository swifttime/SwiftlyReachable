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

#if TARGET_OS_IPHONE
#import <SwiftlyReachable/SwiftlyReachable-Swift.h>
#else
#import <SwiftlyReachableOSX/SwiftlyReachableOSX-Swift.h>
#endif

@interface STReachabilityBridge ()
@property (assign) BOOL monitoring;
@property (nonatomic, strong) dispatch_queue_t  reachabilitySerialQueue;
@end

static void STReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void* info) {
    
    changeBlock block = (__bridge changeBlock)info;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block(flags);
    });
}

@implementation STReachabilityBridge

+ (STReachabilityBridge *)bridgeWithTarget:(SCNetworkReachabilityRef)target andBlock:(changeBlock)block {
    return [[STReachabilityBridge alloc] initWithTarget:target andBlock:block];
}

- (instancetype)initWithTarget:(SCNetworkReachabilityRef)target andBlock:(changeBlock)block {
    self = [super init];
    if (self) {
        _monitoring = NO;
        _block = block;
        _target = target;        
    }
    
    return self;
}

- (BOOL)startMonitoring {
    [self stopMonitoring];
    
    _reachabilitySerialQueue = dispatch_queue_create("me.swiftti.streachability", NULL);
    if(_reachabilitySerialQueue == nil)
    {
        return NO;
    }
    
    SCNetworkReachabilityContext    context = { 0, NULL, NULL, NULL, NULL };
    context.info = (__bridge void *)_block;
    
    if (!SCNetworkReachabilitySetCallback(_target, STReachabilityCallback, &context)) {
        [self stopMonitoring];
        
        return NO;
    }
    
    if (!SCNetworkReachabilitySetDispatchQueue(_target, _reachabilitySerialQueue)) {
        [self stopMonitoring];
        
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
    SCNetworkReachabilityFlags flags;
    
    if (!SCNetworkReachabilityGetFlags(_target, &flags)) {
        return 0;
    }
    
    return flags;
}

@end
