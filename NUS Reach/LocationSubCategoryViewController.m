//
//  LocationSubCategoryViewController.m
//  NUS Reach
//
//  Created by Raunak on 21/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "LocationSubCategoryViewController.h"

@implementation LocationSubCategoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _locationSubCategories = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.locationSubCategories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary* tempDict = [self.locationSubCategories objectAtIndex:indexPath.row];
    cell.textLabel.text = [tempDict objectForKey:@"Title"];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* tempDict = [self.locationSubCategories objectAtIndex:indexPath.row];
    NSArray* locations = [tempDict objectForKey:@"Locations"];
    if (locations != nil) {
        [self.delegate selectedSubCategoryWithLocations:locations];
    }
}

@end
