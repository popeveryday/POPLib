//
//  SharedObject.h
//  RelaxMuzikWord
//
//  Created by popeveryday on 6/25/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObserverObject : NSObject

@property (nonatomic) NSMutableDictionary* messages;
@property (nonatomic) NSMutableDictionary* objects;
@property (nonatomic) NSInteger key;
@property (nonatomic) NSInteger counter;


+(ObserverObject*)instance;

+(void)removeObserverToTarget:(id)target;
+(void)addObserverToTarget:(id)target;

+(void)sendObserver:(NSInteger) key;
+(void)sendObserver:(NSInteger) key object:(id)object;
+(void)sendObserver:(NSInteger) key message:(NSString*)message;
+(void)sendObserver:(NSInteger) key message:(NSString*)message object:(id)object;

+(NSInteger) key;
+(NSString*) messageForKey:(NSInteger)key;
+(id) objectForKey:(NSInteger)key;
+(id) removeObjectForKey:(NSInteger)key;
+(void) cleanup;
@end

/*
 //viewDidLoad
 [ObserverObject addObserverToTarget:self];
 
 -(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 {
 switch (ObserverObject.key)
 {
 case OBS_FinishRoundDialog_NextRound:
 NSLog(@"next");
 break;
 case OBS_FinishRoundDialog_ReplayRound:
 NSLog(@"replay");
 break;
 case OBS_FinishRoundDialog_ReturnPackage:
 NSLog(@"return");
 break;
 }
 }
 
 -(void) dealloc{
 [ObserverObject removeObserverToTarget:self];
 }
 */
