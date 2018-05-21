//
//  PageView.m
//  POPLib
//
//  Created by Trung Pham on 5/10/18.
//

#import "PageView.h"
#import "FileLib.h"
#import "QUIBuilder.h"
#import "ViewLib.h"

@implementation PageView
{
    UIPageViewController* pageController;
    NSMutableArray* views, *uiElements;
}

-(void) initUI
{
    pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:Nil];
    pageController.view.backgroundColor = [UIColor whiteColor];
    pageController.view.frame = self.frame;
    
    pageController.dataSource = self;
    pageController.delegate = self;
    
    [self addSubview:pageController.view];
    
    [ViewLib updateLayoutForView:pageController.view superEdge:@"L0R0T0B0" otherEdge:nil];
    
    views = [NSMutableArray new];
    uiElements = [NSMutableArray new];
    
    NSDictionary* elements;
    UIViewController* vc;
    for (NSString* item in self.pageData) {
        vc = [UIViewController new];
        if ([FileLib checkPathExisted:item]) {
            elements = [QUIBuilder rebuildUIWithFile:item containerView:vc.view errorBlock:^(NSString *msg, NSException *exception) {
                NSLog(@"%@ %@", msg, exception);
            }];
        }else{
            elements = [QUIBuilder rebuildUIWithContent:item containerView:vc.view errorBlock:^(NSString *msg, NSException *exception) {
                NSLog(@"%@ %@", msg, exception);
            }];
        }
        
        [uiElements addObject:elements];
        [views addObject:vc];
    }
    
    [pageController setViewControllers:@[[views objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:Nil];
}



#pragma PageViewController delegate
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    if ([self.delegate respondsToSelector:@selector(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)])
    {
        [self.delegate pageViewController:pageViewController didFinishAnimating:finished previousViewControllers:previousViewControllers transitionCompleted:completed];
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    if ([self.delegate respondsToSelector:@selector(pageViewController:willTransitionToViewControllers:)])
    {
        [self.delegate pageViewController:pageViewController willTransitionToViewControllers:pendingViewControllers];
    }
}

-(UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([self.delegate respondsToSelector:@selector(pageViewController:viewControllerBeforeViewController:)])
    {
        return [self.delegate pageViewController:pageViewController viewControllerBeforeViewController:viewController];
    }
    
    NSInteger index = [views indexOfObject:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if (index == 0)
    {
        if (self.isPageContinous) {
            index = views.count;
        }else{
            return nil;
        }
    }
    
    index--;
    return [views objectAtIndex:index];
}

-(UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([self.delegate respondsToSelector:@selector(pageViewController:viewControllerAfterViewController:)])
    {
        return [self.delegate pageViewController:pageViewController viewControllerAfterViewController:viewController];
    }
    
    NSInteger index = [views indexOfObject:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == views.count)
    {
        if (self.isPageContinous) {
            index = 0;
        }else{
            return nil;
        }
    }
    return [views objectAtIndex:index];
}

-(NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    if ([self.delegate respondsToSelector:@selector(presentationCountForPageViewController:)])
    {
        return [self.delegate presentationCountForPageViewController:pageViewController];
    }
    
    return views.count;
}

-(NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    if ([self.delegate respondsToSelector:@selector(presentationIndexForPageViewController:)])
    {
        return [self.delegate presentationIndexForPageViewController:pageViewController];
    }
    
    return 0;
}

@end
