//
//  ContentViewController.h
//  Speakeazy
//
//  Created by Andrew Milham on 12/2/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"

@protocol ContentViewControllerDelegate;

@interface ContentViewController : UIViewController

@property (assign, nonatomic) NSInteger pageIndex;

@property (weak, nonatomic) id<ContentViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *mainButton;
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *videoContainerView;
- (IBAction)tapMainButton:(id)sender;

-(void)setMovieFile:(NSString*)movieFileName;

@property (strong, nonatomic) NSString *movieFileName;

@end

@protocol ContentViewControllerDelegate <NSObject>

-(void)contentViewControllerDidTapMainButton:(ContentViewController*)contentViewController;

@end
