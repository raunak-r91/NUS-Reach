//
//  AnnotationViewController.m
//  NUS Reach
//
//  Created by Ishaan Singal on 6/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "AnnotationViewController.h"

@implementation AnnotationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView setBackgroundView:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.tableView.allowsSelection = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allElements count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = ((MapAnnotationModel*)[self.allElements objectAtIndex:indexPath.row]).title;
    //convert the date from NSDate into a string
    NSDate *startDate = ((MapAnnotationModel*)[self.allElements objectAtIndex:indexPath.row]).event.start;
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc]init];
    [dFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm "];
    cell.detailTextLabel.text = [dFormatter stringFromDate:startDate];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate didTapAccessory: [self.allElements objectAtIndex:indexPath.row]];
}


@end
