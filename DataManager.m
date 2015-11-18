//
//  DataManager.m
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

-(instancetype)init{
    if(self=[super init]){
        [Parse setApplicationId:@"zVOnlswOvRGVWkMEqtgTizETMlGUKbldMfIQ193v"
                      clientKey:@"mvy0GBXpYDoKStql8CHIMrsblMS6mVIR8dUEqjej"];
    }
    return self;
}

-(void)getData{
    PFQuery *objectQuery = [PFQuery queryWithClassName:@"Item"];
    [objectQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        
        NSArray *sortedArray = [objects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortScore" ascending:NO]]];
        
        self.objects = sortedArray;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(updatedObjectsForDataManager:)]){
            [self.delegate updatedObjectsForDataManager:self];
        }
    }];
}

@end
