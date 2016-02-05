//
//  UIViewController+DesignStyle.m
//  CommonLib
//
//  Created by Trung Pham Hieu on 7/11/15.
//  Copyright (c) 2015 Lapsky. All rights reserved.
//

#import "UIViewController+DesignStyle.h"

@implementation UIViewController (DesignStyle)

enum ViewDesignStyle _designStyle;
UIColor* _designCustomColor;

-(void) updateViewNavigationDesignStyle{
    if (self.designStyle == ViewDesignStyleFlatBlue) {
        [ViewLib setNavigationBarColorHex:@"5cc2d2" viewController:self];
    }else if (self.designStyle == ViewDesignStyleFlatCustomColor) {
        [ViewLib setNavigationBarColor:self.designCustomColor viewController:self];
    }
}

-(enum ViewDesignStyle) designStyle{
    return _designStyle;
}

-(UIColor*) designCustomColor{
    return _designCustomColor;
}

-(void) setDesignStyle:(enum ViewDesignStyle)designStyle{
    _designStyle = designStyle;
}

-(void) setDesignCustomColor:(UIColor *)designCustomColor{
    _designCustomColor = designCustomColor;
}

@end
