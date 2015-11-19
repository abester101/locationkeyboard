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
    [self getData];
}

-(void)setObjects:(NSArray<Item *> *)objects{
    _objects = objects;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(updatedObjectsForDataManager:)]){
        [self.delegate updatedObjectsForDataManager:self];
    }
}

-(void)getData{
    
    if(self.delegate&&[self.delegate respondsToSelector:@selector(startedUpdatingObjectsForDataManager:)]){
        [self.delegate startedUpdatingObjectsForDataManager:self];
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
        if(foundLocation){
            
            PFQuery *objectQuery = [PFQuery queryWithClassName:@"Item"];
            [objectQuery whereKey:@"location" equalTo:foundLocation];
            [objectQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                
                
                NSArray *sortedArray = [objects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortScore" ascending:NO]]];
                
                self.objects = sortedArray;
            }];
            
        } else {
            self.objects = nil;
        }
        
    }];
    
    
    
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
            self.authorizationCompletionBlock = nil;
        }
    }
}

@end
