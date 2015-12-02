//
//  ContentViewController.m
//  Speakeazy
//
//  Created by Andrew Milham on 12/2/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapMainButton:(id)sender {
    if(self.delegate){
        [self.delegate contentViewControllerDidTapMainButton:self];
    }
}
@end
