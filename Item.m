//
//  Item.m
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "Item.h"
#import "Location.h"

@import MobileCoreServices;

@implementation Item

@dynamic name,description,location,uses,image;

+(void)load{
    [self registerSubclass];
}

+(NSString *)parseClassName{
    return @"Item";
}

-(CGFloat)sortScore{
    // Uses divided by how long available
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self.createdAt toDate:[NSDate date] options:0];
    
    CGFloat days = [components day]+1;
    
    
    return (CGFloat)self.uses/days;
    
}

-(NSString *)fileType{
    NSString *retV = (NSString*)kUTTypePNG;
    
    if(self.image){
        if([[self.image.name pathExtension].uppercaseString isEqualToString:@"PNG"]){
            retV = (NSString*)kUTTypePNG;
        } else if([[self.image.name pathExtension].uppercaseString isEqualToString:@"JPG"]||
                  [[self.image.name pathExtension].uppercaseString isEqualToString:@"JPEG"]){
            retV = (NSString*)kUTTypeJPEG;
        } else if([[self.image.name pathExtension].uppercaseString isEqualToString:@"GIF"]){
            retV = (NSString*)kUTTypeGIF;
        }
    }
    
    return retV;
}

@end
