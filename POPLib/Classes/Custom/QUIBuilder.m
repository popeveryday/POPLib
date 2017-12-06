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

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock{
    return [self rebuildUIWithFile:file containerView:container device:QUIBuilderDeviceType_Default errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock{
    if(![FileLib checkPathExisted:file]) return nil;
    NSString* content = [FileLib readFile:file];
    
    return [self rebuildUIWithContent:content containerView:container device:device errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock{
    return [self rebuildUIWithContent:content containerView:container device:QUIBuilderDeviceType_Default errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock
{
    NSDictionary* breakData = [self handleContent:content];
    content = [breakData objectForKey:@"content"];
    
    NSString* propKey = @"starting", *propValue;
    NSMutableDictionary* uiElements = [NSMutableDictionary new];
    
    @try{
        
        NSArray* items = [content componentsSeparatedByString:CONTROL_BREAK];
        
        
        for (NSString* item in items) {
            
            NSArray* allValues = [StringLib deparseString:item].values;
            NSArray* allKeys = [StringLib deparseString:item.lowercaseString].keys;
            
            
            propKey = @"type";
            if(![allKeys containsObject:propKey]) continue;
            propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
            
            if(![CONTROL_TYPES.allKeys containsObject:propValue.lowercaseString])
            {
                NSArray* temp = [self typeFromObjectName:propValue currentObjectStr:item arrayItems:items];
                allKeys = temp[0];
                allValues = temp[1];
                
                if(![allKeys containsObject:propKey]) continue;
                propValue = [[allValues objectAtIndex:[allKeys indexOfObject:propKey]] lowercaseString];
                
                if(![CONTROL_TYPES.allKeys containsObject:propValue]) continue;
            }
            
            enum ALControlType controlType = (enum ALControlType) [[CONTROL_TYPES objectForKey:propValue.lowercaseString] integerValue];
            
            propKey = [@"superEdge" lowercaseString];
            NSString* superEdge = nil;
            if([allKeys containsObject:propKey]){
                superEdge = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
            }
            
            //otherEdge = B-10:tf, T10:abc
            propKey = [@"otherEdge" lowercaseString];
            NSMutableDictionary* otherEdge = [NSMutableDictionary new];
            if([allKeys containsObject:propKey]){
                NSArray* otherEdgeArr = [[allValues objectAtIndex:[allKeys indexOfObject:propKey]] componentsSeparatedByString:@","];
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
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([uiElements.allKeys containsObject:propValue])
                    containerView = [uiElements objectForKey:propValue];
            }
            
            UIView* view = [ViewLib initAutoLayoutWithType:controlType viewContainer:containerView superEdge:superEdge otherEdge:otherEdge];
            
            propKey = @"name";
            NSString* name = [allKeys containsObject:propKey] ? [allValues objectAtIndex:[allKeys indexOfObject:propKey]] : [NSString stringWithFormat:@"view%@", @(uiElements.count)];
            [uiElements setObject:view forKey:name];
            
            
            
            //UIView
            propKey = @"borderwidth";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                view.layer.borderWidth = [propValue floatValue];
            }
            
            
            propKey = @"hidden";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                view.hidden = [self boolValue:propValue];
            }
            
            
            propKey = @"cornerradius";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                view.layer.cornerRadius = [propValue floatValue];
                
            }
            
            propKey = @"bgcolor";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                view.backgroundColor = [self colorObj:propValue];
            }
            
            
            propKey = @"bordercolor";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                view.layer.borderColor = [[self colorObj:propValue] CGColor];
            }
            
            propKey = @"alpha";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                view.alpha = [propValue floatValue];
            }
            
            propKey = @"clipstobounds";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                view.clipsToBounds = [self boolValue:propValue];
            }
            
            
            //TextField, TextView
            propKey = @"placeholder";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).placeholder = propValue;
            }
            
            
            propKey = @"textcolor";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).textColor = [self colorObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).textColor = [self colorObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).textColor = [self colorObj:propValue];
            }
            
            
            propKey = @"returnkeytype";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).returnKeyType = [self returnKeyTypeObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).returnKeyType = [self returnKeyTypeObj:propValue];
            }
            
            propKey = @"font";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UIButton class]]) ((UIButton*)view).titleLabel.font = [self fontObj:propValue];
            }
            
            propKey = @"textalignment";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).textAlignment = [self textAlignObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).textAlignment = [self textAlignObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).textAlignment = [self textAlignObj:propValue];
            }
            
            
            propKey = @"text";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).text = [self textObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).text = [self textObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).text = [self textObj:propValue];
            }
            
            
            propKey = @"clearbuttonmode";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).clearButtonMode = [self clearButtonModeObj:propValue];
            }
            
            propKey = @"autocaptype";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).autocapitalizationType = [self autocapTypeObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).autocapitalizationType = [self autocapTypeObj:propValue];
            }
            
            
            //UIImageView, UIView
            propKey = @"contentmode";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                view.contentMode = [self contentModeObj:propValue];
            }
            
            
            propKey = @"src";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UIImageView class]]) ((UIImageView*)view).image = [self imageObj:propValue];
            }
            
            
            
            
            //UIButton
            propKey = @"title";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UIButton class]]) [self titleObj:propValue button:(UIButton*)view];
            }
            
            propKey = @"titlecolor";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UIButton class]]) [self titleColorObj:propValue button:(UIButton*)view];
            }
            
            propKey = @"bgimage";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UIButton class]]) [self bgImageObj:propValue button:(UIButton*)view];
            }
            
            propKey = @"titleimage";
            if([allKeys containsObject:propKey])
            {
                propValue = [allValues objectAtIndex:[allKeys indexOfObject:propKey]];
                if([view isKindOfClass:[UIButton class]]) [self titleImageObj:propValue button:(UIButton*)view];
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
+(NSArray*) extractKeyValueFromItemString:(NSString*)item
{
    NSArray* allValues = [StringLib deparseString:item].values;
    NSArray* allKeys = [StringLib deparseString:item.lowercaseString].keys;
    return @[allKeys, allValues];
}

//type = view & name = abc & title = hello & bgColor = red
//CONTROL_BREAK
//type = [abc] & name = copy_of_abc & bgColor = blue
// => type = view & name = copy_of_abc & bgColor = blue & title = hello
+(NSArray*) typeFromObjectName:(NSString*)objectName currentObjectStr:(NSString*)currentItem arrayItems:(NSArray*)allItems
{
    objectName = [objectName stringByReplacingOccurrencesOfString:@"[" withString:@""];
    objectName = [objectName stringByReplacingOccurrencesOfString:@"]" withString:@""];
    objectName = [[StringLib trim:objectName] lowercaseString];
    
    NSArray* temp = [self extractKeyValueFromItemString:currentItem];
    NSArray* allKeys = [temp objectAtIndex:0];
    NSArray* allValues = [temp objectAtIndex:1];
    
    NSString* propKey, *name;
    NSArray* keys, *values;
    NSMutableDictionary* resultDict = [NSMutableDictionary new];
    for (NSString* item in allItems)
    {
        temp = [self extractKeyValueFromItemString:item];
        keys = [temp objectAtIndex:0];
        values = [temp objectAtIndex:1];
        
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
            
            break;
        }
    }
    
    NSString* propValue = [resultDict objectForKey:@"type"];
    if(![CONTROL_TYPES.allKeys containsObject:propValue.lowercaseString])
    {
        return [self typeFromObjectName:propValue currentObjectStr:[StringLib parseStringFromDictionary:resultDict] arrayItems:allItems];
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

//abc > LocalizedText(@"abc", nil)
//'abc ' > LocalizedText(@"abc ", nil)
//"abc " > LocalizedText(@"abc ", nil)
//""abc "" > LocalizedText(@"\"abc \"", nil)
//[zh-Hant]:"   time is: 08:30 PM" => LocalizedText(@"   time is: 08:30 PM", @"zh-Hant")
+(NSString*) textObj:(NSString*)value
{
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* langCode = [StringLib trim:arr[0]] ;
        
        if( ([langCode hasPrefix:@"["] && [langCode hasSuffix:@"]"]) ){
            NSString* data = @"";
            
            langCode = [StringLib trim:[[langCode substringToIndex:langCode.length-1] substringFromIndex:1]];
            
            for (int i = 1; i < arr.count; i++) {
                data = [NSString stringWithFormat:@"%@%@%@",data, data.length > 0 ? @":": @"", arr[i] ];
            }
            
            return LocalizedText( [self spaceTextObj:data], langCode);
        }
        
    }
    
    return LocalizedText([self spaceTextObj: value], nil);
}


+(NSString*) spaceTextObj:(NSString*)value
{
    value = [StringLib trim:value];
    for (NSString* letter in @[@"\"", @"'"])
    {
        if([value hasPrefix:letter] && [value hasSuffix:letter]){
            return [[value substringToIndex:value.length-1] substringFromIndex:1];
        }
    }
    
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


+(NSDictionary*) handleContent:(NSString*)content
{
    NSMutableDictionary* data = [NSMutableDictionary new];
    if([content containsString:AUTOTEXT_BREAK]){
        NSString* defaultValue = [StringLib subStringBetween:content startStr:AUTOTEXT_BREAK endStr:@">>"];
        if([StringLib isValid:defaultValue])
        {
            content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@>>", AUTOTEXT_BREAK, defaultValue] withString:@""];
            defaultValue = [defaultValue stringByReplacingOccurrencesOfString:@"=" withString:@""];
            defaultValue = [StringLib trim:defaultValue];
            [data setObject:defaultValue forKey:@"autotext"];
        }
    }
    
    if(![content containsString:DEVICE_BREAK]){
        [data setObject:content forKey:@"content"];
        return data;
    }
    
    NSArray* arr = [content componentsSeparatedByString:DEVICE_BREAK];
    content = arr[0];
    [data setObject:content forKey:@"content"];
    
    NSString* device, *devContent;
    for (int i = 1; i < arr.count; i++)
    {
        devContent = arr[i];
        device = [StringLib subStringBetween:devContent startStr:@"=" endStr:@">>"];
        devContent = [devContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"=%@>>", device] withString:@""];
        device = [[StringLib trim:device] lowercaseString];
        [data setObject:devContent forKey:device];
    }
    return data;
}

//+(void) handle

@end






















