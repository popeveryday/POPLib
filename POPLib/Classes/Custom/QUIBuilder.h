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
    QUIBuilderDeviceType_Default,
    QUIBuilderDeviceType_iPhone5SE,
    QUIBuilderDeviceType_iPhone68,
    QUIBuilderDeviceType_iPhone68plus,
    QUIBuilderDeviceType_iPhoneX
};

@interface QUIBuilder : NSObject

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock;

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock;

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock;

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock;

+(void) clearQUIViewWithUIElement:(NSDictionary*) uiElements;

+(NSString*) genCode:(NSDictionary*)uiElements;

@end


