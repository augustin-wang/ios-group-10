//
//  facebookPlaces.m
//  places
//
//  Created by Zordius Chen on 7/13/15.
//  Copyright (c) 2015 Zordius Chen. All rights reserved.
//

#import "facebookPlaces.h"
#import "AFHTTPRequestOperationManager.h"
#define CLCOORDINATE_EPSILON 0.0005f
#define CLCOORDINATES_EQUAL( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)

// For DEMO
NSString *fakeApiURL = @"https://dl.dropboxusercontent.com/u/46004762/sample.json";
NSString *fakeApiURL2 = @"https://dl.dropboxusercontent.com/u/46004762/sample2.json";
// Official API URL
NSString *apiURL = @"https://graph.facebook.com/%@";

@implementation facebookPlaces

+ (facebookPlaces *)getInstance {
    static facebookPlaces *p = nil;
    static CLLocationManager *locationManager = nil;

    @synchronized(self) {
        if (p == nil) {
            p = [[facebookPlaces alloc] init];
            p.currentCenter = CLLocationCoordinate2DMake(0.0, 0.0);
            p.autoGPSTracking = true;
            p.keyword = nil;
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = p;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.distanceFilter = 50;
            [locationManager requestWhenInUseAuthorization];
            [locationManager startUpdatingLocation];
        }
    }

    return p;
}

- (NSString *)getAccessToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    // go https://developers.facebook.com/tools/explorer to copy an access token then replace xxx
    // execute these 2 lines ONLY ONCE then the access token will be saved in your simulator
    // Do not git commit your access token here!
    // ------------------------------------------------------------------
    /*
    [userDefaults setValue:@"xxx" forKey:@"accessToken"];
    [userDefaults synchronize];
     */
    // ------------------------------------------------------------------

    return [userDefaults stringForKey:@"accessToken"];
}

- (void)queryPlaces {
    // https://graph.facebook.com/search?q=coffee&type=place&center=25.038448,121.548656&distance=5000&access_token=xxxx
    NSString *token = [self getAccessToken];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    // match with the application type returned from github.io or dropbox, useless to standard API
    if (!token) {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    }

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"place" forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f", self.currentCenter.latitude, self.currentCenter.longitude] forKey:@"center"];
    if ([self.keyword length]) {
        [parameters setObject:self.keyword forKey:@"q"];
    }

    if (token) {
        [parameters setObject:token forKey:@"access_token"];
    }

    [manager GET:token ? [NSString stringWithFormat:apiURL, @"search"] : fakeApiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"call place api success!");
        self.places = responseObject[@"data"];
//        NSLog(@"----API result: %@", self.places);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"call facebook api error! %@", error);
    }];
}

- (void)getPlaceMeta:(NSString *)placeid successCB:(void(^)(id response))successCallback failedCB:(void(^)(NSError *error))failedCallback {
    // https://graph.facebook.com/112295342181143?fields=photos{picture},description_html&access_token=xxxx
    NSString *token = [self getAccessToken];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    // match with the application type returned from github.io or dropbox, useless to standard API
    if (!token) {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    }

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"photos{picture},description" forKey:@"fields"];
    if (token) {
        [parameters setObject:token forKey:@"access_token"];
    }

    [manager GET:token ? [NSString stringWithFormat:apiURL, placeid] : fakeApiURL2 parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successCallback(responseObject);
        NSLog(@"----API result: %@", self.places);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"call facebook api error! %@", error);
        failedCallback(error);
    }];
}

-(void)setCurrentCenter:(CLLocationCoordinate2D)currentCenter {
    if (!CLCOORDINATES_EQUAL(currentCenter, _currentCenter)) {
        NSLog(@"query api! %f, %f", _currentCenter.latitude, _currentCenter.longitude);
        NSLog(@"query api! %f, %f", currentCenter.latitude, currentCenter.longitude);
        _currentCenter = currentCenter;
        [self queryPlaces];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.currentCenter = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

@end
