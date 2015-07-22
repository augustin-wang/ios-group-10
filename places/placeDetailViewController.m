//
//  placeDetailViewController.m
//  places
//
//  Created by Zordius Chen on 7/13/15.
//  Copyright (c) 2015 Zordius Chen. All rights reserved.
//

#import "placeDetailViewController.h"
#import "facebookPlaces.h"
#import "UIButton+AFNetworking.h"

@implementation placeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.data[@"name"];
    self.streetLabel.text = self.data[@"location"][@"street"];
    self.cityLabel.text = self.data[@"location"][@"city"];
    self.countryLabel.text = self.data[@"location"][@"country"];
    self.zipLabel.text = self.data[@"location"][@"zip"];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake([self.data[@"location"][@"latitude"] floatValue], [self.data[@"location"][@"longitude"] floatValue]);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, 1000, 1000);
    [self.mapView setRegion:viewRegion animated:YES];

    [[facebookPlaces getInstance] getPlaceMeta:self.data[@"id"] successCB:^(id response) {
        self.descriptionText.text = response[@"description"];
        if (response[@"photos"][@"data"][0][@"picture"]) {
            [self.imageButton setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:response[@"photos"][@"data"][0][@"picture"]]];
        }
        NSLog(@"call api ok! %@", response);
    } failedCB:^(NSError *error) {
        NSLog(@"Call api error! %@", error);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = self.mapView.centerCoordinate;
    myAnnotation.title = self.data[@"name"];
    [self.mapView addAnnotation:myAnnotation];
}

@end
