//
//  UIViewController+DesignStyle.h
//  CommonLib
//
//  Created by Trung Pham Hieu on 7/11/15.
//  Copyright (c) 2015 Lapsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommonLib.h"

@interface UIViewController (DesignStyle)

@property (nonatomic) enum ViewDesignStyle designStyle;
@property (nonatomic) UIColor* designCustomColor;

-(void) updateViewNavigationDesignStyle;

@end
