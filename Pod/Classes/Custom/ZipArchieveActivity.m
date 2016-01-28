//
//  ZipArchieveActivity.m
//  CommonLib
//
//  Created by Trung Pham Hieu on 3/18/15.
//  Copyright (c) 2015 Lapsky. All rights reserved.
//

#import "ZipArchieveActivity.h"
#import "GlobalConfig.h"
#import "StringLib.h"

@implementation ZipArchieveActivity

- (NSString *)activityType
{
    return _isExtractFile ? @"com.poptato.zipextract" : @"com.poptato.zipcompress";
}

- (NSString *)activityTitle
{
    if (_isExtractFile)
    {
        return @"Extract File";
    }
    
    return [NSString stringWithFormat: @"Compress %lu Items", (unsigned long)_selectedItems.count];
}

- (UIImage *)activityImage
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIImage imageNamed: _isExtractFile ? @"CommonLib.bundle/ActivityZipExtractIpad" : @"CommonLib.bundle/ActivityZipCompressIpad"];
    }
    
    return [UIImage imageNamed: _isExtractFile ? @"CommonLib.bundle/ActivityZipExtract" : @"CommonLib.bundle/ActivityZipCompress"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    _selectedItems = activityItems;
    _isExtractFile = _selectedItems.count == 1 && [[[[((NSURL*)[_selectedItems firstObject]) path] pathExtension] uppercaseString] isEqualToString:@"ZIP"];
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
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
