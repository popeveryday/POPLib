//
//  UIView+Extend.h
//  RelaxMuzikWord
//
//  Created by popeveryday on 6/21/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAKeyframeAnimation+AHEasing.h"
#import <UIKit/UIKit.h>

@interface UIView (Animation)

-(void) Animation_Shake;
-(void) Animation_ShakeWithDelay:(float)delay;
-(void) Animation_ShakeWithCount:(int)count interval:(NSTimeInterval)interval;
-(void) Animation_ShakeWithCount:(int)count interval:(NSTimeInterval)interval delay:(float)delay;

-(void) Animation_DropDownToTargetCenter:(CGPoint)point duration:(float)duration delay:(float) delay;
-(void) Animation_DropDownToTargetCenter:(CGPoint)point duration:(float)duration delay:(float)delay completeAction:(void (^)(void))completeAction;

-(void) Animation_MoveElasticToTargetCenter:(CGPoint)point duration:(float)duration completeAction:(void (^)(void))completeAction;
-(void) Animation_MoveElasticToTargetCenter:(CGPoint)point duration:(float)duration delay:(float)delay;
-(void) Animation_MoveElasticToTargetCenter:(CGPoint)point duration:(float)duration delay:(float)delay completeAction:(void (^)(void))completeAction;

-(void) Animation_ZoomDropDownToTargetCenter:(CGPoint)point;
-(void) Animation_ZoomDropDownToTargetCenter:(CGPoint)point delay:(float) delay;
-(void) Animation_ZoomDropDownToTargetCenter:(CGPoint)point delay:(float) delay completeAction:(void (^)(BOOL finished))completeAction;
-(void) Animation_ZoomDropDownToTargetCenter:(CGPoint)point duration:(float)duration delay:(float) delay completeAction:(void (^)(BOOL finished))completeAction;

-(void) SetLocationX:(float) x y:(float) y;
-(void) SetScale:(float) scale alignCenter:(BOOL) alignCenter;

// Moves
- (void)Animation_MoveToCenterTarget:(CGPoint)center duration:(float)secs option:(UIViewAnimationOptions)option delay:(float)delay;
- (void)Animation_MoveToCenterTarget:(CGPoint)center duration:(float)secs option:(UIViewAnimationOptions)option delay:(float)delay callback:(void (^)(BOOL finished))method;

// Speed Move
- (void) Animation_RaceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack;
- (void) Animation_RaceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack delegate:(id)delegate callback:(SEL)method;

//Alpha display
-(void) Animation_Alpha:(float) alpha  duration:(float)duration delay:(float)delay;
-(void) Animation_Alpha:(float) alpha  duration:(float)duration delay:(float)delay callback:(SEL)method;

// Remove from view
-(void) Animation_RemoveWithAlpha:(float)duration delay:(float)delay;
-(void) Animation_RemoveWithAlpha:(float)duration delay:(float)delay callback:(SEL) method;

- (void) Animation_RemoveWithSink:(int)steps;
- (void) Animation_RemoveWithSink:(int)steps withDelay:(int)delay;

@end
