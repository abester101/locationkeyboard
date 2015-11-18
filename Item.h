//
//  Item.h
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class Location;

@interface Item : PFObject<PFSubclassing>

+(NSString*)parseClassName;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;

@property (strong, nonatomic) Location *location;

@property (assign, nonatomic) NSInteger uses;

@property (strong, nonatomic) PFFile *image;

@property (readonly) CGFloat sortScore;

-(NSString*)fileType;

@end
