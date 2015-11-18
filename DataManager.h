//
//  DataManager.h
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Item.h"
#import "Location.h"

#import <Parse/Parse.h>

@protocol DataManagerDelegate;

@interface DataManager : NSObject

@property (weak, nonatomic) id<DataManagerDelegate> delegate;

@property (strong, nonatomic) NSArray<Item*>* objects;

-(void)getData;

@end

@protocol DataManagerDelegate <NSObject>

@optional

-(void)updatedObjectsForDataManager:(DataManager*)dataManager;

@end
