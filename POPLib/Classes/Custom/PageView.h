//
//  PageView.h
//  POPLib
//
//  Created by Trung Pham on 5/10/18.
//

#import <UIKit/UIKit.h>

@interface PageView: UIView <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
//item is qui content or patch to qui file
@property (nonatomic) NSArray* pageData;
@property (nonatomic) BOOL isPageContinous;
-(void) initUI;
@end
