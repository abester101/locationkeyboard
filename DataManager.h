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

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLLocation *coordinates;

@property (strong, nonatomic) Location *location;

@property (assign, nonatomic) BOOL authorized;

-(void)start;

@end

@protocol DataManagerDelegate <NSObject>

@optional

-(void)failedToGetLocationForDataManager:(DataManager*)dataManager;

-(void)updatedObjectsForDataManager:(DataManager*)dataManager;

-(void)startedUpdatingObjectsForDataManager:(DataManager*)dataManager;

@end
