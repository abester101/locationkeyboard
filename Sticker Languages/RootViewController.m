//
//  RootViewController.m
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "RootViewController.h"
#import "ContentViewController.h"
#import "Mixpanel.h"

#import "DataManager.h"


@interface RootViewController () <UIPageViewControllerDelegate,UIPageViewControllerDataSource,ContentViewControllerDelegate,CLLocationManagerDelegate,DataManagerDelegate>


@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (assign, nonatomic) NSUInteger numberOfPages;

@property (strong, nonatomic) IBOutlet UIView *pageIndicator1;
@property (strong, nonatomic) IBOutlet UIView *pageIndicator2;
@property (strong, nonatomic) IBOutlet UIView *pageIndicator3;

@property (strong, nonatomic) DataManager *dataManager;

@property (assign, nonatomic) NSInteger currentPage;

@property (assign, nonatomic) BOOL foundLocation;

@end

@implementation RootViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberOfPages = 3;
    
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    //self.pageViewController.dataSource = self;
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
    self.currentPage = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCurrentPage:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(void)checkCurrentPage:(NSNotification*)notification{
    if(self.currentPage==0&&[self keyboardInstalled]){
        [self advancePageTo:1 animated:YES];
    }
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
        vc.movieFileName = @"instructions";
        vc.pageIndex = 0;
        vc.delegate = self;
    } else if(index==1){
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePage2"];
        vc.pageIndex = 1;
//        vc.imageView.animationRepeatCount = 10;
        vc.delegate = self;
    } else if(index==2) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePage3"];
        vc.pageIndex = 2;
        vc.delegate = self;
    }
    
    return vc;
    
}


- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    
}

-(void)advancePageTo:(NSInteger)pageIndex animated:(BOOL)animated{
    __weak typeof(self)welf = self;
    self.currentPage = pageIndex;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:pageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:^(BOOL finished) {
        [welf pageViewController:welf.pageViewController didFinishAnimating:YES previousViewControllers:@[] transitionCompleted:YES];
    }];
}

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    ContentViewController *vc = pageViewController.viewControllers.firstObject;
    if(vc.pageIndex==1){

    } else if(vc.pageIndex==2){
        [self.dataManager start];
        
    }
    self.currentPage = vc.pageIndex;
    
    if(vc.pageIndex>=1){ self.pageIndicator2.alpha = 1.0f; } else { self.pageIndicator2.alpha = 0.4f; }
    if(vc.pageIndex>=2){ self.pageIndicator3.alpha = 1.0f; } else { self.pageIndicator3.alpha = 0.4f; }
}

-(void)contentViewControllerDidTapMainButton:(ContentViewController *)contentViewController{
    NSLog(@"Keyboards: %@",[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    if(contentViewController.pageIndex==0){
        if([self keyboardInstalled]){
            [self advancePageTo:1 animated:YES];
        } else {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:"]]){
            
            NSURL *url = [NSURL URLWithString:@"prefs:root=General&path=Keyboard"];
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        }
        //[self advancePageTo:1 animated:YES];
        [[Mixpanel sharedInstance] track:@"Tapped Open Settings"];
    } else if(contentViewController.pageIndex==1){
        [self.dataManager getAuthorization:^(BOOL success) {
            if(success){
                [self advancePageTo:2 animated:YES];
            } else {
                #warning TODO: Something to handle case where user rejected access
            }
        }];
    } else if(contentViewController.pageIndex==2){
        
        
    } else if(contentViewController.pageIndex==3){
        //[self advancePageTo:1 animated:YES];
    }
}

-(DataManager *)dataManager{
    if(!_dataManager){
        _dataManager = [[DataManager alloc] init];
        _dataManager.delegate = self;
    }
    return _dataManager;
}

-(void)gotLocation:(Location *)location dataManager:(DataManager *)dataManager{
    if(self.foundLocation){
        return;
    }
    ContentViewController *vc = self.pageViewController.viewControllers.firstObject;
    if(vc.pageIndex==2){
        if(location){
            self.foundLocation = YES;
            [UIView transitionWithView:vc.mainLabel duration:0.15f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                vc.mainLabel.text = [NSString stringWithFormat:@"Welcome to Speakeazy %@!",location.locationDescription.length?location.locationDescription:location.name];
        
            } completion:^(BOOL finished) {
                
            }];
        } else {
            vc.mainLabel.text = [NSString stringWithFormat:@"Sorry, Speakeazy isn't in your location yet."];
        }
    }
}

-(BOOL)keyboardInstalled{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleKeyboards"] containsObject:@"com.appsovereasy.speakeazy.keyboard"];
}
@end
