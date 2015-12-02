//
//  RootViewController.m
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "RootViewController.h"
#import "ContentViewController.h"

@interface RootViewController () <UIPageViewControllerDelegate,UIPageViewControllerDataSource,ContentViewControllerDelegate>


@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (assign, nonatomic) NSUInteger numberOfPages;

@property (strong, nonatomic) IBOutlet UIView *pageIndicator1;
@property (strong, nonatomic) IBOutlet UIView *pageIndicator2;
@property (strong, nonatomic) IBOutlet UIView *pageIndicator3;
@property (strong, nonatomic) IBOutlet UIView *pageIndicator4;


@end

@implementation RootViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberOfPages = 4;
    
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    UIViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = self.containerView.bounds;
    
    [self addChildViewController:_pageViewController];
    [self.containerView addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == self.numberOfPages) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    ContentViewController *vc = nil;
    if(index==0) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePage1"];
        vc.pageIndex = 0;
        vc.delegate = self;
    } else if(index==1){
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePage2"];
        vc.pageIndex = 1;
        vc.imageView.animationRepeatCount = 10;
        vc.delegate = self;
    } else if(index==2) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePage1"];
        vc.pageIndex = 2;
        vc.delegate = self;
    } else if(index==3) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePage1"];
        vc.pageIndex = 3;
        vc.delegate = self;
    }
    
    return vc;
    
}


- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    
}

-(void)advancePageTo:(NSInteger)pageIndex animated:(BOOL)animated{
    __weak typeof(self)welf = self;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:pageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:^(BOOL finished) {
        [welf pageViewController:welf.pageViewController didFinishAnimating:YES previousViewControllers:@[] transitionCompleted:YES];
    }];
}

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    ContentViewController *vc = pageViewController.viewControllers.firstObject;
    if(vc.pageIndex==1){

        
        [vc.imageView setAnimatedImage:[FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"instructions" ofType:@"gif"]]]];
    }
    
    if(vc.pageIndex>=1){ self.pageIndicator2.alpha = 1.0f; } else { self.pageIndicator2.alpha = 0.4f; }
    if(vc.pageIndex>=2){ self.pageIndicator3.alpha = 1.0f; } else { self.pageIndicator3.alpha = 0.4f; }
    if(vc.pageIndex>=3){ self.pageIndicator4.alpha = 1.0f; } else { self.pageIndicator4.alpha = 0.4f; }
}

-(void)contentViewControllerDidTapMainButton:(ContentViewController *)contentViewController{
    if(contentViewController.pageIndex==0){
        [self advancePageTo:1 animated:YES];
    } else if(contentViewController.pageIndex==1){
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        [self advancePageTo:2 animated:YES];
    } else if(contentViewController.pageIndex==2){
        [self advancePageTo:3 animated:YES];
    } else if(contentViewController.pageIndex==3){
        //[self advancePageTo:1 animated:YES];
    }
}
@end
