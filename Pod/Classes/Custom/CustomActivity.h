//
//  CustomActivity.h
//  CommonLib
//
//  Created by Trung Pham Hieu on 5/8/15.
//  Copyright (c) 2015 Lapsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomActivityDelegate <NSObject>

-(BOOL) customActivityReturnValidationWithActivity:(UIActivity*)activity type:(NSString*)type activityURLFiles:(NSArray*)activityURLFiles;
-(void) customActivityExecuteActionWithWithActivity:(UIActivity*)activity type:(NSString*)type selectedFiles:(NSArray*)selectedFiles;

@end

@interface CustomActivity : UIActivity

@property (nonatomic) NSString* actType;
@property (nonatomic) NSString* actTitle;
@property (nonatomic) UIImage* actImage;
@property (nonatomic) NSArray* selectedFiles;

@property (nonatomic) BOOL isAcceptSingleFile;
@property (nonatomic) BOOL isAcceptFileOnly;

@property (nonatomic) id<CustomActivityDelegate> delegate;


-(id) initWithType:(NSString*)type title:(NSString*)title image:(UIImage*)image isAcceptSingleFile:(BOOL)isAcceptSingleFile isAcceptFileOnly:(BOOL) isAcceptFileOnly;

@end
