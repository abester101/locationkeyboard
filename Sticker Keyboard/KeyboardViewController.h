//
//  KeyboardViewController.h
//  Sticker Keyboard
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchKeyboardView.h"

@interface KeyboardViewController : UIInputViewController

@property (strong, nonatomic) SearchKeyboardView *searchKeyboardView;

@end
