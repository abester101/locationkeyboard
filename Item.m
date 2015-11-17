//
//  Item.m
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "Item.h"
#import "Location.h"

@implementation Item

@dynamic name,description,location,uses,image;

+(void)load{
    [self registerSubclass];
}

+(NSString *)parseClassName{
    return @"Item";
}

@end
