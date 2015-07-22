//
//  placesTableViewController.m
//  places
//
//  Created by Zordius Chen on 7/13/15.
//  Copyright (c) 2015 Zordius Chen. All rights reserved.
//

#import "placesTableViewController.h"
#import "placeDetailViewController.h"
#import "facebookPlaces.h"

@implementation placesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[facebookPlaces getInstance] addObserver:self
                  forKeyPath:@"places"
                     options:0
                     context:nil];
}

- (void)dealloc {
    [[facebookPlaces getInstance] removeObserver:self forKeyPath:@"places"];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if ([keyPath isEqualToString:@"places"]) {
        [self.tableView reloadData];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[facebookPlaces getInstance].places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    NSMutableDictionary *data = [facebookPlaces getInstance].places[indexPath.row];

    cell.textLabel.text = data[@"name"];
    cell.detailTextLabel.text = data[@"location"][@"street"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"tbl2dtl"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSMutableDictionary *data = [facebookPlaces getInstance].places[indexPath.row];
        placeDetailViewController *destinationVC = segue.destinationViewController;
        destinationVC.data = data;
    }
}

@end
