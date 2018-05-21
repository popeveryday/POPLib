//
//  PageView.h
//  POPLib
//
//  Created by Trung Pham on 5/10/18.
//

#import <UIKit/UIKit.h>

@protocol PageViewDelegate <NSObject>

@optional
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers;

-(UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;

-(UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;

-(NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController;

-(NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController;
@end

@interface PageView: UIView <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
//item is qui content or patch to qui file
@property (nonatomic) id<PageViewDelegate> delegate;
@property (nonatomic) NSArray* pageData;
@property (nonatomic) BOOL isPageContinous;
-(void) initUI;
@end
