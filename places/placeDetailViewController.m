//
//  placeDetailViewController.m
//  places
//
//  Created by Zordius Chen on 7/13/15.
//  Copyright (c) 2015 Zordius Chen. All rights reserved.
//

#import "placeDetailViewController.h"
#import "placePhotosViewController.h"
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
            self.pictures = response[@"photos"][@"data"];
            [self.imageButton setTitle:[NSString stringWithFormat:@"view %lu photos", [self.pictures count]] forState:UIControlStateNormal];
            [self.imageButton setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:self.pictures[0][@"picture"]]];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    placePhotosViewController *destinationVC = segue.destinationViewController;
    destinationVC.pictures = self.pictures;
}

@end
