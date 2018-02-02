//
//  QUIBuilder.m
//  Lizks Studio
//
//  Created by Trung Pham Hieu on 8/25/17.
//  Copyright © 2017 poptato. All rights reserved.
//

#import "QUIBuilder.h"
#import <POPLib/NetServiceHelper.h>
#import <POPLib/POPLib.h>

#define CONTROL_TYPES  @{@"label": @(ALControlTypeLabel),\
@"image": @(ALControlTypeImage), \
@"view": @(ALControlTypeView), \
@"button": @(ALControlTypeButton), \
@"textview": @(ALControlTypeTextView), \
@"textfield": @(ALControlTypeTextField), \
@"progressview": @(ALControlTypeProgressView), \
@"blurview": @(ALControlTypeVisualEffectView)}

#define CONTROL_BREAK @"<<BrEak>>"
#define AUTOTEXT_BREAK @"<<AuToTeXt"
#define DEVICE_BREAK @"<<DeViCe"




@implementation QUIBuilder

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock
{
    return [self rebuildUIWithFile:file containerView:container device:QUIBuilderDeviceType_AutoDetect errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock{
    if(![FileLib checkPathExisted:file]) return nil;
    NSString* content = [FileLib readFile:file];
    
    return [self rebuildUIWithContent:content containerView:container device:device errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock{
    return [self rebuildUIWithContent:content containerView:container device:QUIBuilderDeviceType_AutoDetect errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock
{
    
    
    NSDictionary* allItemDic = [self handleContent:content withDevice:device];
    
    NSString* propKey = @"starting", *propValue;
    NSMutableDictionary* uiElements = [NSMutableDictionary new];
    NSDictionary* itemDic;
    
    @try{
        
        NSArray* sortedKeys = [allItemDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* a,NSString* b)
                               {
                                   return [a compare:b];
                               }];
        
        //for creating view
        for (NSString* sortedItemKey in sortedKeys) {
            
            itemDic = [allItemDic objectForKey:sortedItemKey];
            
            propKey = @"name";
            NSString* name = [StringLib subStringBetween:sortedItemKey startStr:@"(" endStr:@")"];
            UIView* view;
            
            propKey = @"type";
            propValue = [itemDic objectForKey:propKey];
            enum ALControlType controlType = (enum ALControlType) [[CONTROL_TYPES objectForKey:propValue.lowercaseString] integerValue];
            
            propKey = @"superedge";
            NSString* superEdge = superEdge = [itemDic objectForKey:propKey];
            
            //otherEdge = B-10:tf, T10:abc
            propKey = @"otheredge";
            NSMutableDictionary* otherEdge = [NSMutableDictionary new];
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                NSArray* otherEdgeArr = [propValue componentsSeparatedByString:@","];
                
                for (NSString* oneEdge in otherEdgeArr) {
                    if(![oneEdge containsString:@":"]) continue;
                    NSArray* arr = [oneEdge componentsSeparatedByString:@":"];
                    NSString* edgeValue = [StringLib trim:arr[0]];
                    NSString* otherViewName = [StringLib trim:arr[1]];
                    UIView* otherView = [uiElements objectForKey:otherViewName];
                    if(!otherView) continue;
                    [otherEdge setObject:otherView forKey:edgeValue];
                }
            }
            
            UIView* containerView = container;
            propKey = [@"container" lowercaseString];
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([uiElements.allKeys containsObject:propValue])
                    containerView = [uiElements objectForKey:propValue];
            }
            
            view = [ViewLib initAutoLayoutWithType:controlType viewContainer:containerView superEdge:superEdge otherEdge:otherEdge];
            [uiElements setObject:view forKey:name];
        }
        
        //for properties and action
        for (NSString* sortedItemKey in sortedKeys)
        {
            NSString* name = [StringLib subStringBetween:sortedItemKey startStr:@"(" endStr:@")"];
            UIView* view = [uiElements objectForKey:name];
            itemDic = [allItemDic objectForKey:sortedItemKey];
            
            //UIView
            propKey = @"borderwidth";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.layer.borderWidth = [propValue floatValue];
            }
            
            
            propKey = @"hidden";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.hidden = [self boolValue:propValue];
            }
            
            
            propKey = @"cornerradius";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if ([propValue.lowercaseString isEqualToString:@"auto"])
                {
                    NSString* tempstr = [itemDic objectForKey:@"superedge"];
                    for (NSString* letter in [@"T,R,L,B,C,H,V,W,E,S" componentsSeparatedByString:@","] ) {
                        tempstr = [tempstr stringByReplacingOccurrencesOfString:letter withString:[NSString stringWithFormat:@",%@",letter]];
                    }
                    
                    for (NSString* item in [tempstr componentsSeparatedByString:@","]) {
                        if(![item hasPrefix:@"W"] && ![item hasPrefix:@"S"]) continue;
                        @try{
                            view.layer.cornerRadius = [[[StringLib trim:item] substringFromIndex:1] floatValue] / 2;
                        }@catch(NSException* exception)
                        {
                            NSString* error = [NSString stringWithFormat:@"Exception(%s): \n%@", __func__, exception];
                            NSLog(@"%@", error);
                        }
                        
                        break;
                    }
                }
                else
                {
                    view.layer.cornerRadius = [propValue floatValue];
                }
            }
            
            propKey = @"bgcolor";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.backgroundColor = [self colorObj:propValue];
            }
            
            
            propKey = @"bordercolor";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.layer.borderColor = [[self colorObj:propValue] CGColor];
            }
            
            propKey = @"alpha";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.alpha = [propValue floatValue];
            }
            
            propKey = @"clipstobounds";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.clipsToBounds = [self boolValue:propValue];
            }
            
            propKey = @"interaction";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.userInteractionEnabled = [self boolValue:propValue];
            }
            
            
            
            
            //TextField, TextView
            propKey = @"placeholder";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).placeholder = [self textObj:propValue];
            }
            
            
            propKey = @"textcolor";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).textColor = [self colorObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).textColor = [self colorObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).textColor = [self colorObj:propValue];
            }
            
            
            propKey = @"returnkeytype";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).returnKeyType = [self returnKeyTypeObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).returnKeyType = [self returnKeyTypeObj:propValue];
            }
            
            propKey = @"font";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UIButton class]]) ((UIButton*)view).titleLabel.font = [self fontObj:propValue];
            }
            
            propKey = @"textalignment";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).textAlignment = [self textAlignObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).textAlignment = [self textAlignObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).textAlignment = [self textAlignObj:propValue];
            }
            
            
            propKey = @"text";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).text = [self textObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).text = [self textObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).text = [self textObj:propValue];
            }
            
            
            propKey = @"clearbuttonmode";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).clearButtonMode = [self clearButtonModeObj:propValue];
            }
            
            propKey = @"autocaptype";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).autocapitalizationType = [self autocapTypeObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).autocapitalizationType = [self autocapTypeObj:propValue];
            }
            
            
            //UIImageView, UIView
            propKey = @"contentmode";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.contentMode = [self contentModeObj:propValue];
            }
            
            
            propKey = @"src";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UIImageView class]]) ((UIImageView*)view).image = [self imageObj:propValue];
            }
            
            
            //UIButton
            if ([view isKindOfClass:[UIButton class]]) {
                propKey = @"title";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [self titleObj:propValue button:(UIButton*)view];
                }
                
                propKey = @"titlecolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [self titleColorObj:propValue button:(UIButton*)view];
                }
                
                propKey = @"bgimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [self bgImageObj:propValue button:(UIButton*)view];
                }
                
                propKey = @"titleimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [self titleImageObj:propValue button:(UIButton*)view];
                }
                
                propKey = @"showtouch";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UIButton*)view).showsTouchWhenHighlighted = [self boolValue:propValue];
                }
            }
            
            
            //UILabel, UIButton
            propKey = @"underline";
            if([itemDic.allKeys containsObject:propKey]
               && ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]]) )
            {
                propValue = [itemDic objectForKey:propKey];
                
                if([self boolValue:propValue]){
                    
                    NSString* stringValue = [view isKindOfClass:[UILabel class]] ? ((UILabel*)view).text : [((UIButton*)view) currentTitle];
                    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:stringValue];
                    [attributeString addAttribute:NSUnderlineStyleAttributeName
                                            value:[NSNumber numberWithInt:1]
                                            range:(NSRange){0,[attributeString length]}];
                    
                    if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).attributedText = attributeString;
                    if([view isKindOfClass:[UIButton class]]) ((UIButton*)view).titleLabel.attributedText = attributeString;
                }
            }
            
            //action
            propKey = @"action";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                [self applyAction:propValue forView:view uiElements:uiElements];
            }
            
            
        }
    }@catch(NSException* exception)
    {
        NSString* error = [NSString stringWithFormat:@"PropKey:%@\nException(%s): \n%@", propKey, __func__, exception];
        NSLog(@"%@", error);
        if(errorBlock) errorBlock(error, exception);
    }
    
    return uiElements;
}

+(void) clearQUIViewWithUIElement:(NSDictionary*) uiElements
{
    for (UIView* view in uiElements.allValues) {
        [view removeAllHandleEvent];
        [view removeFromSuperview];
    }
}

+(NSString*) genCode:(NSDictionary*)uiElements
{
    NSString* init = @"", *getset = @"";
    
    for (NSString* key in uiElements.allKeys)
    {
        id control = [uiElements objectForKey:key];
        init = [NSString stringWithFormat:@"%@%@* %@;\n",init, [control class], key];
        getset = [NSString stringWithFormat:@"%@%@ = [_uiElements objectForKey:@\"%@\"];\n", getset, key, key];
    }
    
    return [NSString stringWithFormat:@"%@\n\n%@", init, getset];
}

#pragma builder functions
//action = show(box)  ==> view/button tap to show the object name 'box'.
//action = hide(box)  ==> view/button tap to hide the object name 'box'.
//action = toggle(box)  ==> view/button tap to show/hide the object name 'box'.
//action = observer(number) ==> call [ObserverObject sendObserver:number]
//action = observer(number,obj,key) ==> [ObserverObject sendObserver:number object:@"obj" notificationKey:@"key"]
//action = observer(number,,key) ==> [ObserverObject sendObserver:number object:nil notificationKey:@"key"]
//action = observer(number,obj) ==> [ObserverObject sendObserver:number object:@"obj" notificationKey:nil]
// if view => userinteraction = yes + add tab gesture
// if button => addtarget for button
+(void) applyAction:(NSString*)action forView:(UIView*)view uiElements:(NSMutableDictionary*) uiElements
{
    action = [StringLib trim:action];
    NSString* actionkey = [[action componentsSeparatedByString:@"("] firstObject];
    NSString* objName = [StringLib subStringBetween:action startStr:@"(" endStr:@")"];
    void (^actionBlock)(void);
    
    if ([action hasPrefix:@"show"] || [action hasPrefix:@"hide"] || [action hasPrefix:@"toggle"])
    {
        UIView* obj = [uiElements objectForKey:objName];
        if(!objName || !obj) return;
        
        actionBlock = ^void()
        {
            [obj setHidden: [actionkey isEqualToString:@"show"] ? NO : ([actionkey isEqualToString:@"hide"] ? YES : !obj.hidden) ];
        };
    }
    else if([action hasPrefix:@"observer"])
    {
        if(!objName || ![StringLib isValid:objName]) return;
        
        actionBlock = ^void()
        {
            NSArray* arr = [objName componentsSeparatedByString:@","];
            NSInteger index = [[arr objectAtIndex:0] integerValue];
            NSString* object = arr.count >= 2 ? [arr objectAtIndex:1] : nil;
            NSString* key = arr.count >= 3 ? [arr objectAtIndex:2] : nil;
            
            [ObserverObject sendObserver:index object:object notificationKey:key];
        };
    }
    
    [view handleControlEvent:UIControlEventTouchUpInside withBlock:actionBlock];
}

+(NSDictionary*) extractKeyValueFromItemString:(NSString*)item
{
    NSArray* allValues = [StringLib deparseString:item].values;
    NSArray* allKeys = [StringLib deparseString:item.lowercaseString].keys;
    if(!allValues || !allKeys) return nil;
    return @{ @"allKeys": allKeys, @"allValues": allValues };
}

//type = view & name = abc & title = hello & bgColor = red
//CONTROL_BREAK
//type = [abc] & name = copy_of_abc & bgColor = blue
// => type = view & name = copy_of_abc & bgColor = blue & title = hello
+(NSDictionary*) typeFromObjectName:(NSString*)objectName currentObjectStr:(NSString*)currentItem arrayItems:(NSArray*)allItems deviceUpdateDic:(NSDictionary*)deviceUpdateDic
{
    objectName = [objectName stringByReplacingOccurrencesOfString:@"[" withString:@""];
    objectName = [objectName stringByReplacingOccurrencesOfString:@"]" withString:@""];
    objectName = [[StringLib trim:objectName] lowercaseString];
    
    NSDictionary* temp = [self extractKeyValueFromItemString:currentItem];
    NSArray* allValues = [temp objectForKey:@"allValues"];
    NSArray* allKeys = [temp objectForKey:@"allKeys"];
    
    NSString* propKey, *name;
    NSArray* keys, *values;
    NSMutableDictionary* resultDict = [NSMutableDictionary new];
    for (NSString* item in allItems)
    {
        temp = [self extractKeyValueFromItemString:item];
        keys = [temp objectForKey:@"allKeys"];
        values = [temp objectForKey:@"allValues"];
        
        propKey = @"name";
        if(![keys containsObject:propKey]) continue;
        name = [values objectAtIndex:[keys indexOfObject:propKey]];
        name = [[StringLib trim:name] lowercaseString];
        
        
        if ([name isEqualToString:objectName]) {
            
            for (NSString* key in keys) {
                [resultDict setObject:[values objectAtIndex:[keys indexOfObject:key]] forKey:key];
            }
            
            for (NSString* key in allKeys)
            {
                if([key isEqualToString:@"type"]) continue;
                [resultDict setObject:[allValues objectAtIndex:[allKeys indexOfObject:key]] forKey:key];
            }
            
            NSArray* _allValues, *_allKeys;
            if(deviceUpdateDic && [deviceUpdateDic.allKeys containsObject:name])
            {
                NSDictionary* _temp = [self extractKeyValueFromItemString: [deviceUpdateDic objectForKey:name]];
                _allValues = [_temp objectForKey:@"allValues"];
                _allKeys = [_temp objectForKey:@"allKeys"];
                
                for (NSString* key in _allKeys)
                {
                    if([key isEqualToString:@"type"] || [key isEqualToString:@"name"]) continue;
                    [resultDict setObject:[_allValues objectAtIndex:[_allKeys indexOfObject:key]] forKey:key];
                }
            }
            
            break;
        }
    }
    
    NSString* propValue = [resultDict objectForKey:@"type"];
    if(![CONTROL_TYPES.allKeys containsObject:propValue.lowercaseString])
    {
        return [self typeFromObjectName:propValue currentObjectStr:[StringLib parseStringFromDictionary:resultDict] arrayItems:allItems deviceUpdateDic:deviceUpdateDic];
    }
    
    return [self extractKeyValueFromItemString:[StringLib parseStringFromDictionary:resultDict]];
}


//abc > [button setTitle:@"abc" forState:UIControlStateNormal]
//abc;def > [button setTitle:@"abc" forState:UIControlStateNormal]
//          [button setTitle:@"def" forState:UIControlStateHighlighted]
+(void)titleColorObj:(NSString*)value button:(UIButton*)button
{
    if([value containsString:@";"])
    {
        NSArray* arr = [value componentsSeparatedByString:@";"];
        [button setTitleColor:[self colorObj:arr[0]] forState:UIControlStateNormal];
        [button setTitleColor:[self colorObj:arr[1]] forState:UIControlStateHighlighted];
        return;
    }
    
    [button setTitleColor:[self colorObj:value] forState:UIControlStateNormal];
}


//abc > [button setTitle:@"abc" forState:UIControlStateNormal]
//abc;def > [button setTitle:@"abc" forState:UIControlStateNormal]
//          [button setTitle:@"def" forState:UIControlStateHighlighted]
+(void)titleImageObj:(NSString*)value button:(UIButton*)button
{
    if([value containsString:@";"])
    {
        NSArray* arr = [value componentsSeparatedByString:@";"];
        [button setImage:[self imageObj:arr[0]] forState:UIControlStateNormal];
        [button setImage:[self imageObj:arr[1]] forState:UIControlStateHighlighted];
        return;
    }
    
    [button setImage:[self imageObj:value] forState:UIControlStateNormal];
}

//abc > [button setTitle:@"abc" forState:UIControlStateNormal]
//abc;def > [button setTitle:@"abc" forState:UIControlStateNormal]
//          [button setTitle:@"def" forState:UIControlStateHighlighted]
+(void)bgImageObj:(NSString*)value button:(UIButton*)button
{
    if([value containsString:@";"])
    {
        NSArray* arr = [value componentsSeparatedByString:@";"];
        [button setBackgroundImage:[self imageObj:arr[0]] forState:UIControlStateNormal];
        [button setBackgroundImage:[self imageObj:arr[1]] forState:UIControlStateHighlighted];
        return;
    }
    
    [button setBackgroundImage:[self imageObj:value] forState:UIControlStateNormal];
}



//abc > [button setTitle:@"abc" forState:UIControlStateNormal]
//abc;def > [button setTitle:@"abc" forState:UIControlStateNormal]
//          [button setTitle:@"def" forState:UIControlStateHighlighted]
+(void)titleObj:(NSString*)value button:(UIButton*)button
{
    if([value containsString:@";"])
    {
        NSArray* arr = [value componentsSeparatedByString:@";"];
        [button setTitle:[self textObj:arr[0]] forState:UIControlStateNormal];
        [button setTitle:[self textObj:arr[1]] forState:UIControlStateHighlighted];
        return;
    }
    
    
    [button setTitle:[self textObj:value] forState:UIControlStateNormal];
}

+(UIViewContentMode)contentModeObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"scaletofill"]) return UIViewContentModeScaleToFill;
    if([value isEqualToString:@"scaleaspectfit"]) return UIViewContentModeScaleAspectFit;
    if([value isEqualToString:@"scaleaspectfill"]) return UIViewContentModeScaleAspectFill;
    if([value isEqualToString:@"redraw"]) return UIViewContentModeRedraw;
    if([value isEqualToString:@"center"]) return UIViewContentModeCenter;
    if([value isEqualToString:@"top"]) return UIViewContentModeTop;
    if([value isEqualToString:@"bottom"]) return UIViewContentModeBottom;
    if([value isEqualToString:@"left"]) return UIViewContentModeLeft;
    if([value isEqualToString:@"right"]) return UIViewContentModeRight;
    if([value isEqualToString:@"topleft"]) return UIViewContentModeTopLeft;
    if([value isEqualToString:@"topright"]) return UIViewContentModeTopRight;
    if([value isEqualToString:@"bottomleft"]) return UIViewContentModeBottomLeft;
    if([value isEqualToString:@"bottomright"]) return UIViewContentModeBottomRight;
    return UIViewContentModeCenter;
}

+(UITextAutocapitalizationType) autocapTypeObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"words"]) return UITextAutocapitalizationTypeWords;
    if([value isEqualToString:@"sentences"]) return UITextAutocapitalizationTypeSentences;
    if([value isEqualToString:@"allcharacters"]) return UITextAutocapitalizationTypeAllCharacters;
    if([value isEqualToString:@"ac"]) return UITextAutocapitalizationTypeAllCharacters;
    return UITextAutocapitalizationTypeNone;
}

+(UITextFieldViewMode) clearButtonModeObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"whileediting"]) return UITextFieldViewModeWhileEditing;
    if([value isEqualToString:@"unlessediting"]) return UITextFieldViewModeUnlessEditing;
    if([value isEqualToString:@"we"]) return UITextFieldViewModeWhileEditing;
    if([value isEqualToString:@"ue"]) return UITextFieldViewModeUnlessEditing;
    if([value isEqualToString:@"always"]) return UITextFieldViewModeAlways;
    return UITextFieldViewModeNever;
}

NSString* andStr = @"[AnD]";
NSString* equalStr = @"[EqL]";

//abc > LocalizedText(@"abc", nil)
//'abc ' > LocalizedText(@"abc ", nil)
//"abc " > LocalizedText(@"abc ", nil)
//""abc "" > LocalizedText(@"\"abc \"", nil)
//[zh-Hant]:"   time is: 08:30 PM" => LocalizedText(@"   time is: 08:30 PM", @"zh-Hant")
//[localized]: en [EqL] Language [AnD] vi [EqL] Ngôn Ngữ [AnD] zh-Hant [EqL] 语言
//   => [LocalizedText(@"-") isEqualToString:@"vi"] ? @"Ngôn Ngữ" :
//      [LocalizedText(@"-") isEqualToString:@"zh-Hant"] ? @"语言" : @"Language"
//  Note: first language will be the default language
+(NSString*) textObj:(NSString*)value
{
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* langCode = [StringLib trim:arr[0]] ;
        
        
        
        if( ([langCode hasPrefix:@"["] && [langCode hasSuffix:@"]"]) )
        {
            NSString* data = @"";
            
            langCode = [StringLib trim:[[langCode substringToIndex:langCode.length-1] substringFromIndex:1]];
            
            for (int i = 1; i < arr.count; i++) {
                data = [NSString stringWithFormat:@"%@%@%@",data, data.length > 0 ? @":": @"", arr[i] ];
            }
            
            if (![langCode.lowercaseString isEqualToString:@"localized"]) {
                return LocalizedText( [self spaceAndNewLineTextObj:data], langCode);
            }
            
            data = [data stringByReplacingOccurrencesOfString:@"[EqL]" withString:@"="];
            data = [data stringByReplacingOccurrencesOfString:@"[AnD]" withString:@"&"];
            NSDictionary* langs = [[StringLib deparseString:data autoTrimKeyValue:YES] toDictionary];
            NSString* defaultKey = [StringLib trim: [[data componentsSeparatedByString:@"="] firstObject]];
            NSString* resultText = [langs objectForKey:defaultKey];
            NSString* currentLangCode = LocalizedText(@"-", nil);
            for (NSString* key in langs.allKeys)
            {
                if ([key isEqualToString:currentLangCode]) {
                    resultText = [langs objectForKey:key];
                    break;
                }
            }
            return [self spaceAndNewLineTextObj:resultText];
        }
        
    }
    
    return LocalizedText([self spaceAndNewLineTextObj: value], nil);
}

//replace " -> '
//replace \\n -> \n (line break)
+(NSString*) spaceAndNewLineTextObj:(NSString*)value
{
    value = [StringLib trim:value];
    
    
    for (NSString* letter in @[@"\"", @"'"])
    {
        if([value hasPrefix:letter] && [value hasSuffix:letter]){
            value = [[value substringToIndex:value.length-1] substringFromIndex:1];
        }
    }
    
    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    return value;
}



+(NSTextAlignment) textAlignObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"right"]) return NSTextAlignmentRight;
    if([value isEqualToString:@"center"]) return NSTextAlignmentCenter;
    if([value isEqualToString:@"justified"]) return NSTextAlignmentJustified;
    if([value isEqualToString:@"natural"]) return NSTextAlignmentNatural;
    return NSTextAlignmentLeft;
}


//12 > [UIFont systemFontOfSize:12]
//bold:12 > [UIFont boldSystemFontOfSize:12]
//Arial:12 > [UIFont fontWithName:@"Arial" size:12];
+(UIFont*) fontObj:(NSString*)value
{
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* prefix = [[StringLib trim:arr[0]] lowercaseString];
        NSString* data = [StringLib trim:arr[1]];
        if([prefix isEqualToString:@"bold"])
        {
            return [UIFont boldSystemFontOfSize:[data floatValue]];
        }else{
            return [UIFont fontWithName:[StringLib trim:arr[0]] size:[data floatValue]];
        }
    }
    
    return [UIFont systemFontOfSize:[value floatValue]];
    
    return [UIFont systemFontOfSize:[value floatValue]];
}

+(UIReturnKeyType)returnKeyTypeObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"go"]) return UIReturnKeyGo;
    if([value isEqualToString:@"google"]) return UIReturnKeyGoogle;
    if([value isEqualToString:@"join"]) return UIReturnKeyJoin;
    if([value isEqualToString:@"next"]) return UIReturnKeyNext;
    if([value isEqualToString:@"route"]) return UIReturnKeyRoute;
    if([value isEqualToString:@"search"]) return UIReturnKeySearch;
    if([value isEqualToString:@"send"]) return UIReturnKeySend;
    if([value isEqualToString:@"yahoo"]) return UIReturnKeyYahoo;
    if([value isEqualToString:@"done"]) return UIReturnKeyDone;
    if([value isEqualToString:@"emergencycall"]) return UIReturnKeyEmergencyCall;
    if([value isEqualToString:@"continue"]) return UIReturnKeyContinue;
    return UIReturnKeyDefault;
}

+(BOOL) boolValue:(NSString*)value
{
    return [value.lowercaseString isEqualToString:@"true"];
}

//red > [UIColor redColor]
//ff00ff > Color(@"ff00ff")
//ff00ff, 0.5 > Color2(@"ff00ff", 0.5)
//image:IMAGE_VALUE_FOR >
+(UIColor*) colorObj:(NSString*)value
{
    NSString* value1 = [value lowercaseString];
    if([value1 isEqualToString:@"black"]) return [UIColor blackColor];
    if([value1 isEqualToString:@"darkgray"]) return [UIColor darkGrayColor];
    if([value1 isEqualToString:@"lightgray"]) return [UIColor lightGrayColor];
    if([value1 isEqualToString:@"white"]) return [UIColor whiteColor];
    if([value1 isEqualToString:@"gray"]) return [UIColor grayColor];
    if([value1 isEqualToString:@"red"]) return [UIColor redColor];
    if([value1 isEqualToString:@"green"]) return [UIColor greenColor];
    if([value1 isEqualToString:@"blue"]) return [UIColor blueColor];
    if([value1 isEqualToString:@"cyan"]) return [UIColor cyanColor];
    if([value1 isEqualToString:@"yellow"]) return [UIColor yellowColor];
    if([value1 isEqualToString:@"magenta"]) return [UIColor magentaColor];
    if([value1 isEqualToString:@"orange"]) return [UIColor orangeColor];
    if([value1 isEqualToString:@"purple"]) return [UIColor purpleColor];
    if([value1 isEqualToString:@"brown"]) return [UIColor brownColor];
    if([value1 isEqualToString:@"clear"]) return [UIColor clearColor];
    
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* prefix = [[StringLib trim:arr[0]] lowercaseString];
        NSString* data = [StringLib trim:arr[1]];
        if([prefix isEqualToString:@"image"])
        {
            return [UIColor colorWithPatternImage:[self imageObj:data]];
        }
    }
    
    if([value containsString:@","]){
        NSArray* arr = [value componentsSeparatedByString:@","];
        return Color2([StringLib trim:arr[0]], [[StringLib trim:arr[1]] floatValue] );
    }
    
    return Color(value);
}

//abc > [UIImage imageNamed:@"abc"]
//file: abc > [UIImage imageWithContentsOfFile:@"abc"]
//doc: abc > [UIImage imageWithContentsOfFile: [FileLib getDocumentPath:@"abc"]]
//lib: abc > [UIImage imageWithContentsOfFile: [FileLib getLibraryPath:@"abc"]]
//temp: abc > [UIImage imageWithContentsOfFile: [FileLib getTempPath:@"abc"]]
+(UIImage*) imageObj:(NSString*)value
{
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* prefix = [[StringLib trim:arr[0]] lowercaseString];
        NSString* data = [StringLib trim:arr[1]];
        
        if([prefix isEqualToString:@"doc"]) data = [FileLib getDocumentPath:data];
        if([prefix isEqualToString:@"lib"]) data = [FileLib getLibraryPath:data];
        if([prefix isEqualToString:@"temp"]) data = [FileLib getTempPath:data];
        
        if([FileLib checkPathExisted:data])
            return [UIImage imageWithContentsOfFile:data];
        
        [CommonLib alert:[NSString stringWithFormat:@"%s: %@ not found",__func__, value]];
        return nil;
    }
    
    return [UIImage imageNamed:value];
}


+(NSDictionary*) handleContent:(NSString*)content withDevice:(enum QUIBuilderDeviceType)deviceType
{
    content = [self removeAllComment:content];
    
    if([content containsString:AUTOTEXT_BREAK]){
        NSString* defaultValue = [StringLib subStringBetween:content startStr:AUTOTEXT_BREAK endStr:@">>"];
        if([StringLib isValid:defaultValue])
        {
            content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@>>", AUTOTEXT_BREAK, defaultValue] withString:@""];
            
            defaultValue = [defaultValue stringByReplacingOccurrencesOfString:@"=" withString:@""];
            defaultValue = [StringLib trim:defaultValue];
            
            content = [self fillAutoTextWithContent:content autoTextFile:defaultValue];
        }
    }
    
    if(![content containsString:DEVICE_BREAK])
    {
        return [self rebuildFinalItemWithContent: [self fillAutoTextWithContent:content]];
    }
    
    NSArray* arr = [content componentsSeparatedByString:DEVICE_BREAK];
    content = arr[0];
    
    NSString* deviceCode;
    if (deviceType != QUIBuilderDeviceType_AutoDetect) {
        NSArray* deviceList = [[@"iPhone4,iPhone5,iPhone6,iPhone6p,iPhoneX" lowercaseString] componentsSeparatedByString:@","];
        if(deviceList.count > deviceType) deviceCode = [deviceList objectAtIndex:deviceType];
    }
    
    if (!deviceCode) {
        deviceCode = [CommonLib getDeviceByResolution];
    }
    
    NSString* device, *devContent;
    for (int i = 1; i < arr.count; i++)
    {
        devContent = arr[i];
        device = [StringLib subStringBetween:devContent startStr:@"=" endStr:@">>"];
        devContent = [devContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"=%@>>", device] withString:@""];
        device = [[StringLib trim:device] lowercaseString];
        
        if(![deviceCode isEqualToString:device]) continue;
        content = [content stringByAppendingFormat:@"%@\n%@", CONTROL_BREAK, devContent];
        break;
    }
    
    return [self rebuildFinalItemWithContent:[self fillAutoTextWithContent:content]];
}

//remove all // or /* */
+(NSString*) removeAllComment:(NSString*)content
{
    if (![content containsString:@"//"] && ![content containsString:@"/*"]) {
        return content;
    }
    
    NSMutableArray* comments = [NSMutableArray new];
    [comments addObjectsFromArray:[StringLib allSubStringBetween:content startStr:@"//" endStr:@"\n" includeStartEnd:YES]];
    [comments addObjectsFromArray:[StringLib allSubStringBetween:content startStr:@"/*" endStr:@"*/" includeStartEnd:YES]];
    
    for (NSString* item in comments) {
        content = [content stringByReplacingOccurrencesOfString:item withString: [item hasSuffix:@"\n"] ? @"\n" : @"" ];
    }
    
    return content;
}

+(NSString*) fillAutoTextWithContent:(NSString*)content
{
    NSMutableArray* list = [NSMutableArray new];
    NSString* autoText;
    while (YES) {
        autoText = [StringLib subStringBetween:content startStr:@"<<[" endStr:@"]>>"];
        if(![StringLib isValid:autoText]) break;
        content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<<[%@]>>", autoText] withString:@""];
        [list addObject:autoText];
    }
    
    content = [self fillAutoTextWithContent:content replaceContents:list];
    
    return content;
}

+(NSString*) fillAutoTextWithContent:(NSString*)content autoTextFile:(NSString*)autoTextFile
{
    NSString* realFile = [FileLib getFullPathFromParam:autoTextFile defaultPath:nil];
    if(![FileLib checkPathExisted:realFile]) return content;
    
    NSString* replaceContent = [FileLib readFile:realFile];
    return [self fillAutoTextWithContent:content replaceContents:@[replaceContent]];
}

+(NSString*) fillAutoTextWithContent:(NSString*)content replaceContents:(NSArray*)replaceContents
{
    NSMutableDictionary* data;
    for (NSString* each in replaceContents) {
        NSDictionary* dic = [[StringLib deparseString:each] toDictionary];
        if(data){
            for (NSString* key in dic.allKeys) {
                [data setObject:[dic objectForKey:key] forKey:key];
            }
        }else{
            data = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    }
    
    
    NSString* value;
    for (NSString* key in data.allKeys) {
        value = [data objectForKey:key];
        content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"#%@#",key] withString:value];
    }
    return content;
}

+(NSDictionary*) rebuildFinalItemWithContent:(NSString*)content
{
    NSArray* items = [content componentsSeparatedByString:CONTROL_BREAK];
    NSArray* allValues, *allKeys;
    
    NSMutableDictionary* finalDic = [NSMutableDictionary new];
    NSString* propKey, *propValue, *sortname;
    NSMutableDictionary* itemDic;
    NSMutableDictionary* itemNameDic = [NSMutableDictionary new];
    int indexer = 1;
    NSMutableDictionary* inheritedItemNames = [NSMutableDictionary new];
    
    for (NSString* item in items)
    {
        
        NSDictionary* temp = [self extractKeyValueFromItemString:item];
        if(!temp) continue;
        allValues = [temp objectForKey:@"allValues"];
        allKeys = [temp objectForKey:@"allKeys"];
        
        propKey = @"name";
        NSString* name = [allKeys containsObject:propKey] ? [allValues objectAtIndex:[allKeys indexOfObject:propKey]] : [NSString stringWithFormat:@"view%@", @(finalDic.count)];
        NSLog(@"Name >> %@", name);
        
        
        if ([itemNameDic.allKeys containsObject:name])
        {
            sortname = [itemNameDic objectForKey:name];
            itemDic = [finalDic objectForKey:sortname];
        }
        else
        {
            itemDic = [NSMutableDictionary new];
            sortname = [NSString stringWithFormat:@"%05d(%@)", indexer++,name];
            [itemNameDic setObject:sortname forKey:name];
        }
        
        for (NSString* key in allKeys)
        {
            propValue = [allValues objectAtIndex:[allKeys indexOfObject:key]];
            [itemDic setObject:propValue forKey:key];
            
            if ([key isEqualToString:@"type"] && ![CONTROL_TYPES.allKeys containsObject:propValue.lowercaseString])
            {
                [inheritedItemNames setObject:propValue forKey:sortname];
            }
        }
        
        [finalDic setObject:itemDic forKey:sortname];
    }
    
    
    //Fill for repeat view
    for (NSString* itemkey in inheritedItemNames.allKeys)
    {
        //itemTypeName to find
        NSString* typeItemName = [inheritedItemNames objectForKey:itemkey];
        NSMutableDictionary* srcDic = [self getSrcDicWithTypeItemName:typeItemName finalDic:finalDic itemNameDic:itemNameDic];
        
        if (!srcDic)
        {
            NSLog(@"Type not found: %@ for item name: %@", typeItemName, itemkey);
            [finalDic removeObjectForKey:itemkey];
            continue;
        }
        
        itemDic = [finalDic objectForKey:itemkey];
        NSMutableDictionary* resultDic = [[NSMutableDictionary alloc] initWithDictionary:srcDic];
        for (NSString* key in itemDic.allKeys)
        {
            if([key isEqualToString:@"type"]) continue;
            [resultDic setObject:[itemDic objectForKey:key] forKey:key];
        }
        
        [finalDic setObject:resultDic forKey:itemkey];
    }
    
    return finalDic;
}

+(NSMutableDictionary*) getSrcDicWithTypeItemName:(NSString*)typeItemName finalDic:(NSMutableDictionary*)finalDic itemNameDic:(NSMutableDictionary*) itemNameDic
{
    NSString* sortname = [itemNameDic objectForKey:typeItemName];
    
    if (!sortname)
    {
        NSLog(@"Type not found: %@ for item name: %@", typeItemName, sortname);
        return nil;
    }
    
    NSMutableDictionary* srcDic = [finalDic objectForKey:sortname];
    
    NSString* type = [srcDic objectForKey:@"type"];
    if (![CONTROL_TYPES.allKeys containsObject:type.lowercaseString])
    {
        NSMutableDictionary* parentDic = [self getSrcDicWithTypeItemName:type finalDic:finalDic itemNameDic:itemNameDic];
        NSMutableDictionary* resultDic = [[NSMutableDictionary alloc] initWithDictionary:parentDic];
        for (NSString* key in srcDic.allKeys)
        {
            if([key isEqualToString:@"type"]) continue;
            [resultDic setObject:[srcDic objectForKey:key] forKey:key];
        }
        return resultDic;
    }
    
    return srcDic;
}

@end


@implementation UIView (UIBlockActionView)

NSMutableDictionary* _actionBlock;

-(void) handleControlEvent:(UIControlEvents)event
                 withBlock:(ActionBlock) action
{
    if(!_actionBlock) _actionBlock = [NSMutableDictionary new];
    NSString* key = [[[NSString stringWithFormat:@"%@",self] componentsSeparatedByString:@";"] firstObject];
    [_actionBlock setObject:action forKey:key ];
    
    if ([self isKindOfClass:[UIButton class]])
    {
        [(UIButton*)self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
    }else{
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapgesture:)]];
    }
}

-(void) removeAllHandleEvent
{
    if(!_actionBlock) return;
    NSString* key = [[[NSString stringWithFormat:@"%@",self] componentsSeparatedByString:@";"] firstObject];
    [_actionBlock removeObjectForKey: key];
    
}

- (void) tapgesture: (UITapGestureRecognizer *)recognizer
{
    [self callActionBlock:nil];
}

-(void) callActionBlock:(id)sender
{
    NSString* key = [[[NSString stringWithFormat:@"%@",self] componentsSeparatedByString:@";"] firstObject];
    ActionBlock block = [_actionBlock objectForKey: key];
    if (block) {
        block();
    }
}
@end



















