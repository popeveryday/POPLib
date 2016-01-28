//
//  CustomActivity.m
//  CommonLib
//
//  Created by Trung Pham Hieu on 5/8/15.
//  Copyright (c) 2015 Lapsky. All rights reserved.
//

#import "CustomActivity.h"
#import "GlobalConfig.h"
#import "StringLib.h"
#import "FileLib.h"

@implementation CustomActivity

-(id) initWithType:(NSString*)type title:(NSString*)title image:(UIImage*)image isAcceptSingleFile:(BOOL)isAcceptSingleFile isAcceptFileOnly:(BOOL) isAcceptFileOnly{
    self = [super init];
    if (self) {
        self.actType = type;
        self.actTitle = title;
        self.actImage = image;
        self.isAcceptSingleFile = isAcceptSingleFile;
        self.isAcceptFileOnly = isAcceptFileOnly;
    }
    return self;
}

- (NSString *)activityType
{
    return self.actType;
}

- (NSString *)activityTitle
{
    return self.actTitle;
}

- (UIImage *)activityImage
{
    
    return self.actImage;
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (self.isAcceptSingleFile && activityItems.count > 1) return NO;
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(customActivityReturnValidationWithActivity:type:activityURLFiles:)])
    {
        return [_delegate customActivityReturnValidationWithActivity:self type:self.actType activityURLFiles:activityItems];
    }
    
    NSMutableArray* files = [[NSMutableArray alloc] init];
    
    for (NSURL* fileurl in activityItems)
    {
        if (!self.isAcceptFileOnly || (self.isAcceptFileOnly && ![FileLib CheckPathIsDirectory:fileurl.path])) {
            [files addObject:fileurl.path];
        }
        
        if (self.isAcceptSingleFile && files.count >= 1) break;
    }
    
    self.selectedFiles = files;
    
    return self.selectedFiles.count > 0;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    
}

- (UIViewController *)activityViewController
{
    //    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void) performActivity
{
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(customActivityExecuteActionWithWithActivity:type:selectedFiles:)])
    {
        return [_delegate customActivityExecuteActionWithWithActivity:self type:self.actType selectedFiles:self.selectedFiles];
    }
    
    [self activityDidFinish:YES];
}

@end