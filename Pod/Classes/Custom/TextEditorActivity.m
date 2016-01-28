//
//  TextEditorActivity.m
//  CommonLib
//
//  Created by Trung Pham Hieu on 4/17/15.
//  Copyright (c) 2015 Lapsky. All rights reserved.
//

#import "TextEditorActivity.h"
#import "GlobalConfig.h"
#import "StringLib.h"
#import "FileLib.h"


@implementation TextEditorActivity
- (NSString *)activityType
{
    return @"com.poptato.texteditor";
}

- (NSString *)activityTitle
{
    return @"Text Editor";
}

- (UIImage *)activityImage
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIImage imageNamed:@"CommonLib.bundle/ActivityTextEditorIpad"];
    }
    
    return [UIImage imageNamed:@"CommonLib.bundle/ActivityTextEditor"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (activityItems.count > 1) return NO;
    
    id item = [activityItems firstObject];
    
    if (![item isKindOfClass:[NSURL class]]) return NO;
    
    NSString* path = ((NSURL*)item).path;
    
    if ( ![FileLib CheckPathIsDirectory:path] ) return YES;
    
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
