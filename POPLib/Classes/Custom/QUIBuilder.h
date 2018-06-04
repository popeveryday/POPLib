//
//  QUIBuilder.h
//  Lizks Studio
//
//  Created by Trung Pham Hieu on 8/25/17.
//  Copyright © 2017 poptato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum QUIBuilderDeviceType
{
    QUIBuilderDeviceType_iPhone4,
    QUIBuilderDeviceType_iPhone5,
    QUIBuilderDeviceType_iPhone6,
    QUIBuilderDeviceType_iPhone6p,
    QUIBuilderDeviceType_iPhoneX,
    QUIBuilderDeviceType_AutoDetect
};

enum QUIBuilderGenUIType
{
    QUIBuilderGenUITypeDefault,
    QUIBuilderGenUITypeSkipItemIfExist,
    QUIBuilderGenUITypeUpdateItemIfExist,
    QUIBuilderGenUITypeRemoveAndAddItemIfExist,
};

@interface QUIBuilder : NSObject

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock;

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock;

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device genUIType:(enum QUIBuilderGenUIType)genUIType genUIModeKey:(NSString*)genUIModeKey updateContentBlock:(NSString*(^)(NSString *content)) updateContentBlock errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock;

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device genUIType:(enum QUIBuilderGenUIType)genUIType genUIModeKey:(NSString*)genUIModeKey errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock;

+(void) clearQUIViewWithUIElement:(NSDictionary*) uiElements;

+(NSString*) genCode:(NSDictionary*)uiElements;
+(NSString*) genCode:(NSDictionary*)uiElements shouldGenCodeForView:(BOOL(^)(UIView *view)) checkViewBlock;

+(void) refreshLocalizedForView:(UIView*)view withKey:(NSString*)key;
+(double) valueByDeviceScale:(double)value;
+(double) valueByDeviceScale:(double)value withDevice:(enum QUIBuilderDeviceType)deviceType;

@end


typedef void (^ActionBlock)(void);
@interface UIView (UIBlockActionView)

@property (nonatomic) NSString* viewName;
@property (nonatomic) NSMutableDictionary* localizedTexts;

-(void) handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock) action;
-(void) removeAllHandleEvent;

@end

