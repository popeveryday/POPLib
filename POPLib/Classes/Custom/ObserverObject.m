//
//  SharedObject.m
//  RelaxMuzikWord
//
//  Created by popeveryday on 6/25/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import "ObserverObject.h"
#define OBS_KEY @"ObserverObjectKey"

@implementation ObserverObject
{
    NSLock* targetLock;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.targetObjects = [NSMutableArray new];
        targetLock = [NSLock new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionObserver:) name:OBS_KEY object:nil];
    }
    return self;
}

-(void) actionObserver:(NSNotification*)sender
{
    NSDictionary* data = sender.object;
    NSInteger key = [[data objectForKey:@"key"] integerValue];
    NSObject* value = [data objectForKey:@"value"];
    
    NSMutableArray* copiedTargets = [self.targetObjects mutableCopy];
    
    for (id target in copiedTargets) {
        if(target && [target respondsToSelector:@selector(observerObjectDidCallWithKey:value:)]){
            [target observerObjectDidCallWithKey:key value:value];
        }
    }
}

-(void)addObserverToTarget:(id<ObserverObjectDelegate>)target
{
    if ([self.targetObjects containsObject:target]) return;
    [targetLock lock];
    [self.targetObjects addObject:target];
    [targetLock unlock];
}

-(void)removeObserverWithTarget:(id<ObserverObjectDelegate>)target
{
    if (![self.targetObjects containsObject:target]) return;
    [targetLock lock];
    [self.targetObjects removeObject:target];
    [targetLock unlock];
}





+(ObserverObject*)instance
{
    static ObserverObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ObserverObject alloc] init];
    });
    
    return sharedInstance;
}

+(void)addObserverToTarget:(id<ObserverObjectDelegate>)target
{
    [[ObserverObject instance] addObserverToTarget:target];
}

+(void)removeObserverWithTarget:(id<ObserverObjectDelegate>)target
{
    [[ObserverObject instance] removeObserverWithTarget:target];
}

+(void)sendObserver:(NSInteger)key object:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OBS_KEY object: object ? @{ @"key":@(key), @"value": object } : @{ @"key":@(key) } ];
}

+(void)sendObserver:(NSInteger)key
{
    [self sendObserver:key object:nil];
}



@end
