//
//  UIView+Extend.m
//  RelaxMuzikWord
//
//  Created by popeveryday on 6/21/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#import "UIView+Animation.h"

@implementation UIView (Animation)


#pragma Shaking Animation
- (void)shaking:(NSTimer *)aTimer {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[aTimer userInfo]];
    [aTimer invalidate];
    aTimer = nil;
    int shakeCnt = [[info objectForKey:@"count"] intValue];
    CGPoint orgCenter = [[info objectForKey:@"center"] CGPointValue];
	CGPoint to;
	if (shakeCnt % 2 == 0 && shakeCnt > 0) {
		to = CGPointMake(orgCenter.x + floor(random() % shakeCnt) - shakeCnt / 2,
						 orgCenter.y + floor(random() % shakeCnt) - shakeCnt / 2);
	}else {
		to = orgCenter;
	}
    
	[self setCenter:to];
	shakeCnt--;
	if (shakeCnt > 0) {
        [info setObject:[NSNumber numberWithInt:shakeCnt] forKey:@"count"];
        [NSTimer scheduledTimerWithTimeInterval:[[info objectForKey:@"interval"] doubleValue]
                                         target:self
                                       selector:@selector(shaking:)
                                       userInfo:info repeats:NO];
    }
}

-(void)Animation_Shake{
    [self Animation_ShakeWithCount:10 interval:0.03];
}

-(void)Animation_ShakeWithDelay:(float)delay{
    [self Animation_ShakeWithCount:10 interval:0.03 delay:delay];
}

-(void)Animation_ShakeWithCount:(int)count interval:(NSTimeInterval)interval {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithDouble:interval], @"interval",
                          [NSNumber numberWithInt:count],@"count",
                          [NSValue valueWithCGPoint:self.center],@"center",
                          nil];
	[NSTimer scheduledTimerWithTimeInterval:interval target:self
								   selector:@selector(shaking:)
								   userInfo:info repeats:NO];
}

-(void) Animation_ShakeWithParam:(NSArray*)params_count_interval
{
    [self Animation_ShakeWithCount:[[params_count_interval objectAtIndex:0] intValue] interval:[[params_count_interval objectAtIndex:1] floatValue]];
}

-(void)Animation_ShakeWithCount:(int)count interval:(NSTimeInterval)interval delay:(float)delay{
    [self performSelector:@selector(Animation_ShakeWithParam:) withObject:@[[NSNumber numberWithInt:count] , [NSNumber numberWithFloat:interval]] afterDelay:delay];
}


#pragma DropDown Animation
-(void) Animation_DropDownToTargetCenter:(CGPoint)point duration:(float)duration delay:(float) delay{
    [self Animation_DropDownToTargetCenter:point duration:duration delay:delay completeAction:^(void){}];
}

-(void) Animation_DropDownToTargetCenter:(CGPoint)point duration:(float)duration completeAction:(void (^)(void))completeAction{
    CALayer *layer= [self layer];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *chase = [CAKeyframeAnimation animationWithKeyPath:@"position"
                                                          function:BounceEaseOut
                                                         fromPoint:[self center]
                                                           toPoint:point];
    
    [chase setDelegate:self];
    [layer addAnimation:chase forKey:@"postion"];
    
    [CATransaction setCompletionBlock:completeAction];
    
    [CATransaction commit];
    
    [self setCenter:point];
}

-(void) Animation_DropDownToTargetCenterWithParam:(NSArray*)params_pointx_pointy_duration_completeAction{
    CGPoint point = CGPointMake( [[params_pointx_pointy_duration_completeAction objectAtIndex:0] floatValue], [[params_pointx_pointy_duration_completeAction objectAtIndex:1] floatValue]);
    
    [self Animation_DropDownToTargetCenter:point
                                  duration:[[params_pointx_pointy_duration_completeAction objectAtIndex:2] floatValue] completeAction:[params_pointx_pointy_duration_completeAction objectAtIndex:3]];
}

-(void) Animation_DropDownToTargetCenter:(CGPoint)point duration:(float)duration delay:(float)delay completeAction:(void (^)(void))completeAction
{
    [self performSelector:@selector(Animation_DropDownToTargetCenterWithParam:) withObject:@[[NSNumber numberWithFloat:point.x], [NSNumber numberWithFloat:point.y], [NSNumber numberWithFloat:duration], completeAction] afterDelay:delay];
}



-(void) Animation_MoveElasticToTargetCenter:(CGPoint)point duration:(float)duration completeAction:(void (^)(void))completeAction{
    CALayer *layer= [self layer];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *chase = [CAKeyframeAnimation animationWithKeyPath:@"position"
                                                          function:ElasticEaseOut
                                                         fromPoint:[self center]
                                                           toPoint:point];
    
    [chase setDelegate:self];
    [layer addAnimation:chase forKey:@"postion"];
    
    [CATransaction setCompletionBlock:completeAction];
    
    [CATransaction commit];
    
    [self setCenter:point];
}

-(void) Animation_MoveElasticToTargetCenter:(CGPoint)point duration:(float)duration delay:(float)delay{
    [self Animation_MoveElasticToTargetCenter:point duration:duration delay:delay completeAction:^(void){}];
}

-(void) Animation_MoveElasticToTargetCenter:(CGPoint)point duration:(float)duration delay:(float)delay completeAction:(void (^)(void))completeAction
{
    [self performSelector:@selector(Animation_MoveElasticToTargetCenterWithParam:) withObject:@[[NSNumber numberWithFloat:point.x], [NSNumber numberWithFloat:point.y], [NSNumber numberWithFloat:duration], completeAction] afterDelay:delay];
}

-(void) Animation_MoveElasticToTargetCenterWithParam:(NSArray*) params_pointx_pointy_duration_completeAction{
    CGPoint point = CGPointMake( [[params_pointx_pointy_duration_completeAction objectAtIndex:0] floatValue], [[params_pointx_pointy_duration_completeAction objectAtIndex:1] floatValue]);
    
    [self Animation_MoveElasticToTargetCenter:point
                                     duration:[[params_pointx_pointy_duration_completeAction objectAtIndex:2] floatValue] completeAction:[params_pointx_pointy_duration_completeAction objectAtIndex:3]];
}







-(void) Animation_ZoomDropDownToTargetCenter:(CGPoint)point{
    [self Animation_ZoomDropDownToTargetCenter:point duration:0.3 delay:0 completeAction:nil];
}

-(void) Animation_ZoomDropDownToTargetCenter:(CGPoint)point delay:(float) delay{
    [self Animation_ZoomDropDownToTargetCenter:point duration:0.3 delay:delay completeAction:nil];
}

-(void) Animation_ZoomDropDownToTargetCenter:(CGPoint)point delay:(float) delay completeAction:(void (^)(BOOL finished))completeAction{
    [self Animation_ZoomDropDownToTargetCenter:point duration:0.3 delay:delay completeAction:completeAction];
}

-(void) Animation_ZoomDropDownToTargetCenter:(CGPoint)point duration:(float)duration delay:(float) delay completeAction:(void (^)(BOOL finished))completeAction
{
    self.center = point;
    self.alpha = 0;
    [self SetScale:8 alignCenter:YES];
    
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 1;
        self.frame = CGRectMake(point.x - self.frame.size.width/16, point.y - self.frame.size.height/16, self.frame.size.width/8, self.frame.size.width/8);
    } completion:completeAction];
}

-(void) SetLocationX:(float) x y:(float) y{
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
    
}

-(void) SetScale:(float) scale alignCenter:(BOOL) alignCenter{
    if(alignCenter){
        CGPoint center = self.center;
        self.frame = CGRectMake(0,0,self.frame.size.width*scale, self.frame.size.height*scale);
        self.center = center;
    }else{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width*scale, self.frame.size.height*scale);
    }
}

#pragma mark - Moves

- (void)Animation_MoveToCenterTarget:(CGPoint)center duration:(float)secs option:(UIViewAnimationOptions)option delay:(float)delay{
    [self Animation_MoveToCenterTarget:center duration:secs option:option delay:delay callback:nil];
}

- (void)Animation_MoveToCenterTarget:(CGPoint)center duration:(float)secs option:(UIViewAnimationOptions)option delay:(float)delay callback:(void (^)(BOOL finished))method {
    [UIView animateWithDuration:secs delay:delay options:option
                     animations:^{
                         self.center = center;
                     }
                    completion:method];
}

#pragma Moves with high speed (Race To)
- (void)Animation_RaceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack {
    [self Animation_RaceTo:destination withSnapBack:withSnapBack delegate:nil callback:nil];
}

- (void)Animation_RaceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack delegate:(id)delegate callback:(SEL)method {
    CGPoint stopPoint = destination;
    if (withSnapBack) {
        // Determine our stop point, from which we will "snap back" to the final destination
        int diffx = destination.x - self.frame.origin.x;
        int diffy = destination.y - self.frame.origin.y;
        if (diffx < 0) {
            // Destination is to the left of current position
            stopPoint.x -= 10.0;
        } else if (diffx > 0) {
            stopPoint.x += 10.0;
        }
        if (diffy < 0) {
            // Destination is to the left of current position
            stopPoint.y -= 10.0;
        } else if (diffy > 0) {
            stopPoint.y += 10.0;
        }
    }
    
    // Do the animation
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = CGRectMake(stopPoint.x, stopPoint.y, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (withSnapBack) {
                             [UIView animateWithDuration:0.1
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  self.frame = CGRectMake(destination.x, destination.y, self.frame.size.width, self.frame.size.height);
                                              }
                                              completion:^(BOOL finished) {
                                                  [delegate performSelector:method];
                                              }];
                         } else {
                             [delegate performSelector:method];
                         }
                     }];
}
//============================================================================================================
-(void) Animation_Alpha:(float) alpha  duration:(float)duration delay:(float)delay{
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = alpha;
    } completion:^(BOOL a){
        
    }];
}

-(void) Animation_Alpha:(float) alpha  duration:(float)duration delay:(float)delay callback:(SEL)method{
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = alpha;
    } completion:^(BOOL a){
        [self performSelector:method withObject:self];
    }];
}



//============================================================================================================
-(void) Animation_RemoveWithAlpha:(float)duration delay:(float)delay{
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0;
    } completion:^(BOOL a){
        [self removeFromSuperview];
    }];
}

-(void) Animation_RemoveWithAlpha:(float)duration delay:(float)delay callback:(SEL)method {
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0;
    } completion:^(BOOL a){
        [self removeFromSuperview];
        [self performSelector:method withObject:self];
    }];
}
//============================================================================================================
#pragma Remove with Sink
- (void) Animation_RemoveWithSink:(int)steps
{
	NSTimer *timer;
	if (steps > 0 && steps < 100)	// just to avoid too much steps
		self.tag = steps;
	else
		self.tag = 50;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(removeWithSinkAnimationRotateTimer:) userInfo:nil repeats:YES];
}

- (void) removeWithSinkAnimationRotateTimer:(NSTimer*) timer
{
	CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformScale(self.transform, 0.9, 0.9),0.314);
	self.transform = trans;
	self.alpha = self.alpha * 0.98;
	self.tag = self.tag - 1;
	if (self.tag <= 0)
	{
		[timer invalidate];
		[self removeFromSuperview];
	}
}

- (void) Animation_RemoveWithSink:(int)steps withDelay:(int)delay{
    [self performSelector:@selector(Animation_RemoveWithSink:) withObject:[NSNumber numberWithInt:steps] afterDelay:delay];
}

@end























