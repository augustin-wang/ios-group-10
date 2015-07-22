//
//  placesMapViewController.m
//  places
//
//  Created by Zordius Chen on 7/13/15.
//  Copyright (c) 2015 Zordius Chen. All rights reserved.
//

#import "placesMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "facebookPlaces.h"

@implementation placesMapViewController

- (void)viewDidLoad {
    facebookPlaces *places = [facebookPlaces getInstance];
    [super viewDidLoad];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(places.currentCenter, 100, 100);
    [self.mapView setRegion:region animated:YES];
    self.mapView.delegate = self;
    [places addObserver:self
             forKeyPath:@"places"
                options:0
                context:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updatePlaces];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if ([keyPath isEqualToString:@"places"]) {
        [self updatePlaces];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"inside the stupid method");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"map moved....");
    [facebookPlaces getInstance].currentCenter = mapView.centerCoordinate;
}

- (void)updatePlaces {
    NSMutableArray *annotations = [[NSMutableArray alloc] init];

    for (id data in [facebookPlaces getInstance].places) {
        NSMutableDictionary *location = data[@"location"];
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake([location[@"latitude"] doubleValue], [location[@"longitude"] doubleValue]);
        myAnnotation.title = data[@"name"];
        myAnnotation.subtitle = data[@"id"];
        [annotations addObject:myAnnotation];
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotations];
}

- (void)dealloc {
    [[facebookPlaces getInstance] removeObserver:self forKeyPath:@"places"];
}

@end
