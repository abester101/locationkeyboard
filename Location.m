//
//  Location.m
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "Location.h"

@implementation Location

@dynamic name,locationDescription,coordinates,radius;

+(void)load{
    [self registerSubclass];
}

+(NSString *)parseClassName{
    return @"Location";
}

@end
