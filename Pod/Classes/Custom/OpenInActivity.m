//
//  OpenInActivity.m
//  CommonLib
//
//  Created by Trung Pham Hieu on 1/9/15.
//  Copyright (c) 2015 Lapsky. All rights reserved.
//

#import "OpenInActivity.h"
#import "GlobalConfig.h"
#import "StringLib.h"


@implementation OpenInActivity

- (NSString *)activityType
{
    return @"com.poptato.openin";
}

- (NSString *)activityTitle
{
    return @"Open In";
}

- (UIImage *)activityImage
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIImage imageNamed:@"CommonLib.bundle/ActivityOpenInIpad"];
    }
    
    return [UIImage imageNamed:@"CommonLib.bundle/ActivityOpenIn"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (activityItems.count > 1) return NO;
    
    id item = [activityItems firstObject];
    
    if (![item isKindOfClass:[NSURL class]]) return NO;
    
    NSString* path = ((NSURL*)item).path;
    
    if ( IsOpenInAvailable(path) ) return YES;
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    _selectedItem = [((NSURL*)[activityItems firstObject]) path];
    //    NSLog(@"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController
{
    //    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void) performActivity
{
    //    NSLog(@"%s",__FUNCTION__);
    [self activityDidFinish:YES];
}



@end
