//
//  ModelController.h
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end

