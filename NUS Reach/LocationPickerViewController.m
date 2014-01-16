//
//  LocationPickerViewController.m
//  NUS Reach
//
//  Created by Raunak on 14/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "LocationPickerViewController.h"

@implementation LocationPickerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"LocationHierarchy" ofType:@"plist"];
        _locationCategories = [NSArray arrayWithContentsOfFile:filePath];
        self.clearsSelectionOnViewWillAppear = NO;
        
        //Calculate the size of the table to be displayed in the popover
        NSInteger rowsCount = [_locationCategories count];
        NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView
                                               heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSInteger totalRowsHeight = rowsCount * singleRowHeight;
        
        //Calculate how wide the view should be by finding how
        //wide each string is expected to be
        CGFloat largestLabelWidth = 0;
        for (NSDictionary *categories in _locationCategories) {
            //Checks size of text using the default font for UITableViewCell's textLabel.
            NSString* locations = [categories objectForKey:@"Title"];
            CGSize labelSize = [locations sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]];
            if (labelSize.width > largestLabelWidth) {
                largestLabelWidth = labelSize.width;
            }
        }
        
        //Add a little padding to the width
        CGFloat popoverWidth = largestLabelWidth + 100;
        
        //Set the property to tell the popover container how big this view will be.
        self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, totalRowsHeight);

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
    return [self.locationCategories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* tempDict = [self.locationCategories objectAtIndex:indexPath.row];
    cell.textLabel.text = [tempDict objectForKey:@"Title"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* tempDict = [self.locationCategories objectAtIndex:indexPath.row];
    NSArray* subcategories = [tempDict objectForKey:@"Subcategory"];
    NSArray* locations = [tempDict objectForKey:@"Locations"];
    if (subcategories != nil) {
        [self.delegate selectedCategoryWithSubCategories:subcategories];
    }
    if (locations != nil) {
        [self.delegate selectedCategoryWithLocations:locations];
    }
}

@end
