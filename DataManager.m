//
//  DataManager.m
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "DataManager.h"

@interface DataManager () <CLLocationManagerDelegate>

@property (copy, nonatomic) void (^authorizationCompletionBlock)(BOOL success);

@property (assign, nonatomic) BOOL started;

@property (strong, nonatomic) NSDate *lastQueryDate;

@end

@implementation DataManager

-(instancetype)init{
    if(self=[super init]){
        [Parse setApplicationId:@"zVOnlswOvRGVWkMEqtgTizETMlGUKbldMfIQ193v"
                      clientKey:@"mvy0GBXpYDoKStql8CHIMrsblMS6mVIR8dUEqjej"];
        
        
    }
    return self;
}

-(void)start{
    if(!_started){
    self.started = YES;
    [self getAuthorization:^(BOOL success) {
        if(success){
            
            [self.locationManager startUpdatingLocation];
            
        } else {
            if(self.delegate&&[self.delegate respondsToSelector:@selector(failedToGetLocationForDataManager:)]){
                [self.delegate failedToGetLocationForDataManager:self];
            }
        }
    }];
    }
}

-(void)setCoordinates:(CLLocation *)coordinates{
    _coordinates = coordinates;
    [self getLocation];
}

-(void)setObjects:(NSArray<Item *> *)objects{
    _objects = objects;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(updatedObjectsForDataManager:)]){
        [self.delegate updatedObjectsForDataManager:self];
    }
}

-(void)getLocation{
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"LastLocationObjectId"] length]){
        // Check to see if we're still within the radius of the last location
        
        CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:[[NSUserDefaults standardUserDefaults] floatForKey:@"LastLocationLatitude"] longitude:[[NSUserDefaults standardUserDefaults] floatForKey:@"LastLocationLongitude"]];
        CGFloat radius = [[NSUserDefaults standardUserDefaults] floatForKey:@"LastLocationRadius"];
        
        if(radius>0 && [lastLocation distanceFromLocation:self.coordinates]<=radius){
            
            // We're here!
            
            Location *foundLocation = [Location objectWithoutDataWithObjectId:[[NSUserDefaults standardUserDefaults] objectForKey:@"LastLocationObjectId"]];
            _location = foundLocation;
            
            if(self.delegate&&[self.delegate respondsToSelector:@selector(gotLocation:dataManager:)]){
                [self.delegate gotLocation:foundLocation dataManager:self];
            }
            
            NSLog(@"Found cached location");
            
            [_location fetchIfNeededInBackground];
            
            return;
            
        }
        
    }
    
    PFGeoPoint *queryCoordinates = [PFGeoPoint geoPointWithLocation:self.coordinates];
    
    PFQuery *locationsQuery = [PFQuery queryWithClassName:@"Location"];
    [locationsQuery whereKey:@"coordinates" nearGeoPoint:queryCoordinates];
    
    [locationsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        Location *foundLocation = nil;
        for(Location *location in objects){
            
            if([location.coordinates distanceInKilometersTo:queryCoordinates]*1000<=location.radius){
                foundLocation = location;
                break;
            }
            
        }
        self.location = foundLocation;
        
        if(self.delegate&&[self.delegate respondsToSelector:@selector(gotLocation:dataManager:)]){
            [self.delegate gotLocation:foundLocation dataManager:self];
        }
        
    }];
    
}

-(void)setLocation:(Location *)location{
    _location = location;
    
    [[NSUserDefaults standardUserDefaults] setObject:location.objectId forKey:@"LastLocationObjectId"];
    [[NSUserDefaults standardUserDefaults] setObject:@(location.coordinates.latitude) forKey:@"LastLocationLatitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@(location.coordinates.longitude) forKey:@"LastLocationLongitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@(location.radius) forKey:@"LastLocationRadius"];
    
    
}

-(void)fetchData{
    
    if(self.lastQueryDate&&[[NSDate date] timeIntervalSinceDate:self.lastQueryDate]<1*60.0f){
        return; // Queried less than a minute ago, so don't do it now.
    }
    
    if(self.delegate&&[self.delegate respondsToSelector:@selector(startedUpdatingObjectsForDataManager:)]){
        [self.delegate startedUpdatingObjectsForDataManager:self];
    }
    
    if(self.location){
        
        
        PFQuery *objectQuery = [PFQuery queryWithClassName:@"Item"];
        [objectQuery whereKey:@"location" equalTo:self.location];
        [objectQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [objectQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            
            NSArray *sortedArray = [objects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortScore" ascending:NO]]];
            
            //                NSMutableArray *obj = [NSMutableArray array];
            //                for(NSInteger idx = 0;idx<12;idx++){
            //                    for(PFObject *object in sortedArray){
            //                        [obj addObject:object];
            //                    }
            //                }
            
//            NSMutableArray *testArray = [NSMutableArray array];
//            for(int ix = 0;ix<40;ix++){
//                [testArray addObjectsFromArray:sortedArray];
//            }
            
            
            if(![self array:self.objects matchesArray:sortedArray]){
                self.objects = sortedArray;
            }
        }];
        
    }
    
    self.lastQueryDate = [NSDate date];
    
}

-(BOOL)array:(NSArray<PFObject*>*)array matchesArray:(NSArray<PFObject*>*)otherArray{
    if(array.count!=otherArray.count){
        return NO;
    }
    for(NSInteger ix=0;ix<array.count;ix++){
        if(![array[ix].objectId isEqualToString:otherArray[ix].objectId]){
            return NO;
        }
    }
    return YES;
}

-(void)getAuthorization:(void(^)(BOOL success))completionBlock{
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        self.authorizationCompletionBlock = completionBlock;
        [self.locationManager requestWhenInUseAuthorization];
    } else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted||
              [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
        self.authorized = NO;
        if(completionBlock){
            completionBlock(NO);
        }
    } else {
        self.authorized = YES;
        if(completionBlock){
            completionBlock(YES);
        }
    }
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location manager error");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    self.coordinates = locations.firstObject;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status==kCLAuthorizationStatusDenied||status==kCLAuthorizationStatusRestricted){
        if(self.authorizationCompletionBlock){
            self.authorizationCompletionBlock(NO);
            self.authorizationCompletionBlock = nil;
        }
    } else if(status==kCLAuthorizationStatusAuthorizedAlways||status==kCLAuthorizationStatusAuthorizedWhenInUse){
        if(self.authorizationCompletionBlock){
            self.authorizationCompletionBlock(YES);
            self.authorizationCompletionBlock = nil;
        }
    } else {
        if(self.authorizationCompletionBlock){
            self.authorizationCompletionBlock(NO);
            //self.authorizationCompletionBlock = nil;
        }
    }
}

@end
