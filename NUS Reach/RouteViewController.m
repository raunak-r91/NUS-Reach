//
//  RouteViewController.m
//  NUS Reach
//
//  Created by Ishaan Singal on 20/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RouteViewController.h"

@interface RouteViewController ()
@property NSMutableArray *cellDetails;
@end

@implementation RouteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:@"RouteDetails" bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.viewHeight = 0;
    self.routeTable.delegate = self;
    self.routeTable.dataSource = self;
    self.cellDetails = [[NSMutableArray alloc]init];
    [self process];
    [self.routeTable reloadData];
}


//Based on the route provided, it parses the data in the array that can be
//used to display in the table (by using the table delegates)
- (void)process {
    NSLog(@"%d", [self.view.subviews count]);
    
    NSString *busstopPath = [[NSBundle mainBundle] pathForResource:@"BusLocation" ofType:@"plist"];
    NSDictionary *busStopNames = [[NSDictionary alloc] initWithContentsOfFile:busstopPath];
    
    NSString *busRouter = [[NSBundle mainBundle] pathForResource:@"BusRouter" ofType:@"plist"];
    NSDictionary *busRoutes = [[NSDictionary alloc] initWithContentsOfFile:busRouter];
    
    NSString *startPoint = [self.route objectForKey:@"startPoint"];
    NSString *endPoint = [self.route objectForKey:@"endPoint"];
    NSString *changePoint = [self.route objectForKey:@"changePoint"];
    NSString *buses = [self.route objectForKey:@"busNumber"];
    NSArray *busList = [buses componentsSeparatedByString:@","];
    NSString *stops = [self.route objectForKey:@"stopNumbers"];
    NSArray *stopList = [stops componentsSeparatedByString:@","];
    BOOL isChangeIndex = (changePoint == nil) ? NO: YES;
    
    NSMutableDictionary *startDict = [[NSMutableDictionary alloc]init];
    NSArray* stopInfo = [busStopNames objectForKey:startPoint]; //Single mappoint
    [startDict setObject:[stopInfo objectAtIndex:0]  forKey:@"stopName"];
    [startDict setObject:@"Start Bus" forKey:@"type"];
    [startDict setObject:[busList objectAtIndex:0] forKey:@"bus"];
    
    NSArray *busstopsForBus = [busRoutes objectForKey:[busList objectAtIndex:0]];
    int startIndex = [busstopsForBus indexOfObject:startPoint];
    int endIndex = [[busRoutes objectForKey:[busList lastObject]] indexOfObject:endPoint];
    endIndex = (endIndex == 0)? [[busRoutes objectForKey:[busList lastObject]]count] - 1: endIndex;
    int changeIndexA = (isChangeIndex)? [busstopsForBus indexOfObject:changePoint] : endIndex;
    int changeIndexB = (isChangeIndex)? [[busRoutes objectForKey:[busList lastObject]] indexOfObject:changePoint ]: 0;
    

    [startDict setObject:[NSNumber numberWithInt:[[stopList objectAtIndex:0]intValue]] forKey:@"stopNumber"];
    [self.cellDetails addObject:startDict];

    //the loop adds all the intermediate bus-stops
    for (int i = startIndex + 1; i < changeIndexA ; i++) {
        NSMutableDictionary *intermediateDict = [[NSMutableDictionary alloc]init];
        NSString *busstopCode = [busstopsForBus objectAtIndex:i];
        NSString *busstopName = [[busStopNames objectForKey:busstopCode]objectAtIndex:0];
        [intermediateDict setObject:busstopName forKey:@"stopName"];
        [intermediateDict setObject:@"Intermediate" forKey:@"type"];
        [self.cellDetails addObject:intermediateDict];
    }
    
    //if a bus changeover is involved, the relevant changeover busstops and buses are added
    if (isChangeIndex) {
        NSMutableDictionary *changeDict = [[NSMutableDictionary alloc]init];
        stopInfo = [busStopNames objectForKey:changePoint]; //Single mappoint
        [changeDict setObject:@"Change Bus" forKey:@"type"];
        [changeDict setObject:[stopInfo objectAtIndex:0] forKey:@"stopName"];
        [changeDict setObject:[busList objectAtIndex:1] forKey:@"bus"];
        [changeDict setObject:[NSNumber numberWithInt:[[stopList objectAtIndex:1]intValue]-1] forKey:@"stopNumber"];
        [self.cellDetails addObject:changeDict];
        
        busstopsForBus = [busRoutes objectForKey:[busList objectAtIndex:1]];
        for (int i = changeIndexB + 1; i < endIndex; i++) {
            NSMutableDictionary *intermediateDict = [[NSMutableDictionary alloc]init];
            NSString *busstopCode = [busstopsForBus objectAtIndex:i];
            NSString *busstopName = [[busStopNames objectForKey:busstopCode]objectAtIndex:0];
            [intermediateDict setObject:busstopName forKey:@"stopName"];
            [intermediateDict setObject:@"Intermediate" forKey:@"type"];
            [self.cellDetails addObject:intermediateDict];
        }
    }
    
    NSMutableDictionary *endDict = [[NSMutableDictionary alloc]init];
    stopInfo = [busStopNames objectForKey:endPoint]; //Single mappoint
    [endDict setObject:[stopInfo objectAtIndex:0]  forKey:@"stopName"];
    [endDict setObject:@"End Bus" forKey:@"type"];
    [endDict setObject:[busList lastObject] forKey:@"bus"];
    [endDict setObject:[NSNumber numberWithInt:[[stopList lastObject]intValue]] forKey:@"stopNumber"];
    [self.cellDetails addObject:endDict];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cellDetails count];
}

//different heights are returned based on the type of bus stops (start and
//destinations have larger cell heights)
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    NSUInteger row = [indexPath row];
    NSDictionary *thisCellDict = [self.cellDetails objectAtIndex:row];
    NSString *stopType = [thisCellDict objectForKey:@"type"];
    if ([stopType isEqualToString:@"Intermediate"]) {
        self.viewHeight += 40;
        return 40;
    }
    self.viewHeight += 80;
    return 80;
}

//A custom cell is created based on the type of bus stop
//the cell has images for the bus stop type and whether a changeover is involved or not
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSDictionary *thisCellDict = [self.cellDetails objectAtIndex:row];
    NSString *stopType = [thisCellDict objectForKey:@"type"];
    
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
							 SectionsTableIdentifier];

    if ([stopType isEqualToString:@"Intermediate"]) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RouteDetailIntermediate"
                                                     owner:self options:nil];
        if ([nib count] > 0) {
            cell = self.routeCell;
        }
        else {
            NSLog(@"failed to load CustomCell nib file!");
        }
        UILabel* stopNameLabel = (UILabel*)[cell viewWithTag:5];
        stopNameLabel.text = [thisCellDict objectForKey:@"stopName"];
        UIImageView* img=(UIImageView*)[cell viewWithTag:7];
        [img setImage:[UIImage imageNamed:@"HalfContinue"]];
    }
    else {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RouteDetailCell"
                                                     owner:self options:nil];
        if ([nib count] > 0) {
            cell = self.routeCell;
        } else {
            NSLog(@"failed to load CustomCell nib file!");
        }
        
        UILabel* busLabel=(UILabel*)[cell viewWithTag:1];
        UILabel* typeLabel=(UILabel*)[cell viewWithTag:2];
        UILabel* nameLabel=(UILabel*)[cell viewWithTag:3];
        UILabel* stopsNumLabel=(UILabel*)[cell viewWithTag:4];
        UILabel* alightLabel=(UILabel*)[cell viewWithTag:5];
        
        busLabel.text = [thisCellDict objectForKey:@"bus"];
        busLabel.lineBreakMode = 0;
        typeLabel.text = stopType;
        nameLabel.text = [thisCellDict objectForKey:@"stopName"];
        
        UIImageView* img=(UIImageView*)[cell viewWithTag:7];
        if([stopType isEqualToString:@"Start Bus"]) {
            int stopNumber = [[thisCellDict objectForKey:@"stopNumber"]intValue];
            stopsNumLabel.text = [NSString stringWithFormat:@"%d", stopNumber];
            [img setImage:[UIImage imageNamed:@"FullStartBus"]];
        }
        if([stopType isEqualToString:@"Change Bus"]) {
            int stopNumber = [[thisCellDict objectForKey:@"stopNumber"]intValue];
            stopsNumLabel.text = [NSString stringWithFormat:@"%d", stopNumber];
            [img setImage:[UIImage imageNamed:@"FullChange"]];
        }

        if([stopType isEqualToString:@"End Bus"]) {
            alightLabel.text = @"Alight here";
            [img setImage:[UIImage imageNamed:@"FullEndBus"]];
        }
    }
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRouteCell:nil];
    [self setRouteTable:nil];
    [super viewDidUnload];
}
- (IBAction)closeBtnPressed:(id)sender {
    [self.delegate routeClosed];
}
@end
