//
//  BusRouter.m
//  NUS Reach
//
//  Created by Ishaan Singal on 22/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "BusRouter.h"
@interface BusRouter ()
@property NSDictionary *oppBusstops;
@property NSDictionary *busLocations;
@property NSDictionary *busStopServices;
@property NSDictionary *busRoutes;
@end

@implementation BusRouter

#pragma mark - Busroute

- (id)init {
    self = [super init];
    if (self) {
        //initialize all the ditionaries from the Plist
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BusOpposites" ofType:@"plist"];
        self.oppBusstops = [[NSDictionary alloc] initWithContentsOfFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"BusLocation" ofType:@"plist"];
        self.busLocations = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        
        NSString *pathbus = [[NSBundle mainBundle] pathForResource:@"BusStopServices" ofType:@"plist"];
        self.busStopServices = [[NSDictionary alloc] initWithContentsOfFile:pathbus];
        
        NSString *pathBusRoute = [[NSBundle mainBundle] pathForResource:@"BusRouter" ofType:@"plist"];
        self.busRoutes = [[NSDictionary alloc] initWithContentsOfFile:pathBusRoute];
    }
    return self;
}

- (NSDictionary*)routeBetweenPoints:(CLLocationCoordinate2D)start Venue:(NSString*)end {
    CLLocationCoordinate2D parsedLocation;

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Building_Cood" ofType:@"plist"];
    NSDictionary *locationCoordinates = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    for (NSString* key in locationCoordinates) {
        if ([end rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSArray *buildingDetails = [locationCoordinates objectForKey:key];
            parsedLocation = CLLocationCoordinate2DMake( [[buildingDetails objectAtIndex:1] doubleValue],[[buildingDetails objectAtIndex:2] doubleValue]);
            break;
        }
    }
    
    return [self routeBetweenPoints:start End:parsedLocation];
}

- (NSDictionary*)routeBetweenPoints:(CLLocationCoordinate2D)start End:(CLLocationCoordinate2D)end {
    NSString *nearestStartStop = [self getNearestBusstop:start];
    if([nearestStartStop isEqualToString:@"16199"]){
        nearestStartStop = @"16189";
    }
    NSString *nearestEndStop = [self getNearestBusstop:end];
    if([nearestEndStop isEqualToString:@"16199"]){
        nearestEndStop = @"16189";
    }
    
    NSString *startOppStop = [self busOppGenerator:nearestStartStop withOpp:YES];
    NSString *endOppStop = [self busOppGenerator:nearestEndStop withOpp:YES];
    
    //Generate combinations based on whether the start and end points have an opposite busstop
    int combination;
    if((startOppStop == nil) && (endOppStop != nil)) {
        combination=1;
    }
    else if((startOppStop != nil) && (endOppStop == nil)) {
        combination=2;
    }
    else if((startOppStop == nil) && (endOppStop == nil)) {
        combination=3;
    }
    else {
        combination=4;
    }
    
    NSMutableArray *resultArr = [[NSMutableArray alloc]init];
    int minRoute = 20;
    NSString *busNum = @"";
    NSString *startPoint = @"";
    NSString *endPoint = @"";
    NSString *changePoint = @"";
    NSString *routeStops = @"";

    //based on the combination, compute different routes and check the best route
    //from the list of routes generated
    switch (combination) {
        case 1:
            [resultArr addObject: [self computeBusRoute:nearestStartStop to:nearestEndStop backtrack:NO]];
            [resultArr addObject: [self computeBusRoute:nearestStartStop to:endOppStop backtrack:NO]];
            break;
            
        case 2:
            [resultArr addObject: [self computeBusRoute:nearestStartStop to:nearestEndStop backtrack:NO]];
            [resultArr addObject:  [self computeBusRoute:startOppStop to:nearestEndStop backtrack:NO]];
            break;
            
        case 3:
            [resultArr addObject:  [self computeBusRoute:nearestStartStop to:nearestEndStop backtrack:YES]];
            break;
            
        case 4:
            [resultArr addObject:  [self computeBusRoute:nearestStartStop to:nearestEndStop backtrack:NO]];
            [resultArr addObject: [self computeBusRoute:nearestStartStop to:endOppStop backtrack:NO]];
            [resultArr addObject: [self computeBusRoute:startOppStop to:nearestEndStop backtrack:NO]];
            [resultArr addObject: [self computeBusRoute:startOppStop to:endOppStop backtrack:NO]];
            break;
            
        default:
            break;
    }
    
    //from the list of routes generated, check the best route (based on changeovers & number of routes
    for (NSDictionary *thisRoute in resultArr) {
        NSString *thisChangePoint = [thisRoute objectForKey:@"changePoint"];
        
        int routeNum = 0;
        NSString *routeNumStr = [thisRoute objectForKey:@"stopNumbers"];
        NSArray *routeTokens = [routeNumStr componentsSeparatedByString:@","];
        for (NSString *thisRountNum in routeTokens) {
            routeNum += [thisRountNum intValue];
        }
        if (routeNum == 0) {
            continue;
        }
        BOOL routeNumAdvantage = (routeNum < minRoute) ? YES: NO;
        
        if (routeNumAdvantage) {
            minRoute = routeNum;
            startPoint = [thisRoute objectForKey:@"startPoint"];
            endPoint = [thisRoute objectForKey:@"endPoint"];
            changePoint = thisChangePoint;
            busNum = [thisRoute objectForKey:@"busNumber"];
            routeStops = routeNumStr;
        }
    }
    
    NSDictionary *routeDict = [[NSDictionary alloc]initWithObjectsAndKeys:startPoint,@"startPoint",endPoint, @"endPoint", busNum, @"busNumber", routeStops, @"stopNumbers", changePoint, @"changePoint", nil];
    
    return routeDict;
}

- (NSString*)getNearestBusstop:(CLLocationCoordinate2D)point {
    NSString *result = @"";
    
    double smallestdistance = 10000000;
    
    for(NSString* busKeym in [self.busLocations allKeys]){
        NSArray* busInfo = [self.busLocations objectForKey:busKeym]; //Single mappoint
        CLLocationCoordinate2D newCoord = { [[busInfo objectAtIndex:1] doubleValue],[[busInfo objectAtIndex:2] doubleValue]};
        
        if(([BusRouter getDistance:newCoord To:point] <= smallestdistance) && ([BusRouter getDistance:newCoord To:point]!=0)){
            smallestdistance=[BusRouter getDistance:newCoord To:point];
            result = busKeym;
        }
    }
    return result;
}

//generates the opposite busstop from the given busstop, and returns nil if no opposite busstop
-(NSString*)busOppGenerator:(NSString*)givenBus withOpp:(BOOL)oppBool{
    NSString *opp = [self.oppBusstops objectForKey:givenBus];
    if ([opp isEqualToString:@"None"]) {
        opp = nil;
    }
    return opp;
}

//the main function that computes the route between two given points
//it calls the backtrack function if needed for changeovers
- (NSDictionary*)computeBusRoute:(NSString*)pointA to:(NSString*)pointB backtrack:(BOOL)needToBackTrack {
    NSArray* aBusList = [self.busStopServices objectForKey:pointA];
    NSArray* bBusList = [self.busStopServices objectForKey:pointB];
    
    //Find Common Buses and Eliminate the number ones
    NSMutableArray* commonArr = [[NSMutableArray alloc]init];
    for(NSString* busa in aBusList){
        for(NSString* busb in bBusList){
            if([busa isEqualToString:busb])
                [commonArr addObject:busa];
        }
    }
    
    //Remove Rubbish and Non-NUS Bus Values
    NSMutableArray* commonArrCopy=[NSMutableArray arrayWithArray:commonArr];
    for(NSString* commonBus in commonArr){
        if ([commonBus isEqualToString:@""]) {
            [commonArrCopy removeObject:commonBus];
        }
        else if ([commonBus isEqualToString:@"BTC"]) {
            [commonArrCopy removeObject:commonBus];
        }
        else {
            NSString * newStrings = [commonBus substringWithRange:NSMakeRange(0, 1)];
            unichar a=[newStrings characterAtIndex:0];
            if(isdigit(a)) {
                [commonArrCopy removeObject:commonBus];
            }
        }
    }
    
    //if no common buses are found, need to backtrack to find changepoints
    BOOL shouldBackTrack = ([commonArrCopy count] == 0);
    
    NSMutableDictionary *routeDictionary = [[NSMutableDictionary alloc]init];
    if ([commonArrCopy count] != 0) {
        [routeDictionary setObject:pointA forKey:@"startPoint"];
        [routeDictionary setObject:pointB forKey:@"endPoint"];
        int maxStops = 20;
        for(NSString* bus in commonArrCopy){
            //            NSString* keyname=[NSString stringWithFormat:@"%d",counter];
            int numberOfStops = [self actualRouting:pointA To:pointB Bus:bus];
            if (numberOfStops == 0) {
                continue;
            }
            if (numberOfStops < maxStops) {
                maxStops = numberOfStops;
                [routeDictionary setObject:[NSString stringWithFormat:@"%d", numberOfStops] forKey:@"stopNumbers"];
                [routeDictionary setObject:bus forKey:@"busNumber"];
            }
        }
    }
    //even after having common buses, the bus direction might be opposite and we might
    //need to backtrack
    if (([routeDictionary objectForKey:@"busNumber"] == nil) && needToBackTrack) {
        shouldBackTrack = YES;
    }
    
    //backtracks from the destination to find a busstop that has a common bus as the startpoint
    if (shouldBackTrack) {
        NSString *changePointEnd = nil;
        NSString *bustoChangeToEnd = nil;
        NSMutableArray *finalRoute = [[NSMutableArray alloc]init];
        NSDictionary *testBackTrack = [self backtrackPointB:pointB withABusList:aBusList BBusList:bBusList];

        changePointEnd = [testBackTrack objectForKey:@"busstop"];
        bustoChangeToEnd = [testBackTrack objectForKey:@"bus"];
        if (changePointEnd!=nil) {
            [finalRoute addObject: [self simpleRouting:pointA to:changePointEnd]];//[self simpleRouting:pointA :changePointEnd];
            [finalRoute addObject: [self simpleRouting:changePointEnd to:pointB]];//[self simpleRouting:pointA :changePointEnd];
        }
        
        [routeDictionary setObject:pointA forKey:@"startPoint"];
        [routeDictionary setObject:pointB forKey:@"endPoint"];
        [routeDictionary setObject:changePointEnd forKey:@"changePoint"];
        if ([finalRoute count] != 0) {
            int firstBusStops = [[[finalRoute objectAtIndex:0]objectForKey:@"stopNumbers"]intValue];
            int secondBusStops = [[[finalRoute objectAtIndex:1]objectForKey:@"stopNumbers"]intValue];
            NSString *stops = [NSString stringWithFormat:@"%d,%d", firstBusStops, secondBusStops];
            
            NSString *firstBus = [[finalRoute objectAtIndex:0]objectForKey:@"busNumber"];
            NSString *secondBus = [[finalRoute objectAtIndex:1]objectForKey:@"busNumber"];
            NSString *buses = [NSString stringWithFormat:@"%@,%@", firstBus, secondBus];
            
            [routeDictionary setObject:stops forKey:@"stopNumbers"];
            [routeDictionary setObject:buses forKey:@"busNumber"];
        }
        else {
            return nil;
        }
    }
    
    return routeDictionary;
}

//the function that finds the changeover point and the buses
- (NSDictionary*)backtrackPointB:(NSString*)pointB withABusList:(NSArray*)aBusList BBusList:(NSArray*)bBusList {
    NSString *changeBus = @"";
    NSString *changeBusstop = @"";
    //array that will contain the back-tracked busstops
    NSMutableArray *backTrackArray = [[NSMutableArray alloc]init];
    
    NSMutableArray *busStartArray = [NSMutableArray arrayWithArray:aBusList];
    NSMutableArray *busEndArray = [NSMutableArray arrayWithArray:bBusList];
    
    //Backtrack point B till a matching bus found
    NSString* bus=[busEndArray objectAtIndex:0]; //choose random first bus to backtrack
    [backTrackArray addObject:pointB];//add first point
    
    //Get route of that random bus and get some values
    NSArray* routecheck = [self.busRoutes objectForKey:bus];
    NSInteger index = [routecheck indexOfObject:pointB];
    NSInteger backIndex;
    //the number of stops for each bus 
    if (!([bus isEqualToString:@"D1"] || [bus isEqualToString:@"D2"])) {//if not d1/d2
        NSLog(@"backtrack called");
        if ([bus isEqualToString:@"A1"]) {
            backIndex=15;
        }
        if ([bus isEqualToString:@"A2"]) {
            backIndex=17;
        }
        if ([bus isEqualToString:@"B"]) {
            backIndex=13;
        }
        if ([bus isEqualToString:@"C"]) {
            backIndex=9;
        }
        //backIndex++;
    }
    else {//Bus D1 D2, if 0 NO BUS CAN BACKTRACk
        if (index == 0) {
            //NSLog(@"BUS D CANNOT BACKTRACK FURTHER");
            return nil;
        }
    }
    
    int thisBusstopIndex;
    BOOL endloop = NO;
    if (index == 0) {
        thisBusstopIndex = backIndex;
    }
    else {
        thisBusstopIndex = index - 1;
    }
    while(1){
        NSString* thisBusstop = [routecheck objectAtIndex:thisBusstopIndex];
        NSArray* busStopsForThisBusstop = [self.busStopServices objectForKey:thisBusstop];
        
        for (NSString* startBus in busStartArray) {//Scan through buses at start while backtracking
            for (NSString* thisBusstopBus in busStopsForThisBusstop) {
                if ([startBus isEqualToString:thisBusstopBus]) {
                    changeBus = startBus;
                    endloop=YES;
                    changeBusstop = thisBusstop;
                    break;
                }
            }
            //break the loop
            if (endloop == YES) {
                break;
            }
        }
        //break the loop
        if (endloop == YES) {
            break;
        }
        
        //the changebus & busstop is found
        changeBus = bus;
        changeBusstop = thisBusstop;
        
        thisBusstopIndex -= 1;
        
        if (thisBusstopIndex < 0) {
            thisBusstopIndex = backIndex;
        }
    }
    
    //after backtrack, return the dictionary is a changepoint is found
    if (changeBus != nil) {
        return [NSDictionary dictionaryWithObjectsAndKeys:changeBusstop, @"busstop", changeBus, @"bus", nil];
    }
    else {
        return nil;
    }
}

//when two busstops have a common bus, find a direct shortest route between them
- (NSDictionary*)simpleRouting:(NSString*)pointA to:(NSString*)pointB {
    NSArray* aBusList=[self.busStopServices objectForKey:pointA];
    NSArray* bBusList=[self.busStopServices objectForKey:pointB];
    
    //Find Common Buses and Eliminate the number ones
    NSMutableArray* commonArr=[[NSMutableArray alloc]init];
    for(NSString* busa in aBusList){
        for(NSString* busb in bBusList){
            if([busa isEqualToString:busb])
                [commonArr addObject:busa];
        }
    }
    
    //Remove Rubbish and Non-NUS Bus Values
    NSMutableArray* commonArrCopy=[NSMutableArray arrayWithArray:commonArr];
    for(NSString* commonBus in commonArr){
        if ([commonBus isEqualToString:@""]) {
            [commonArrCopy removeObject:commonBus];
        }
        else if ([commonBus isEqualToString:@"BTC"]) {
            [commonArrCopy removeObject:commonBus];
        }
        else {
            NSString * newStrings = [commonBus substringWithRange:NSMakeRange(0, 1)];
            unichar a=[newStrings characterAtIndex:0];
            if(isdigit(a)) {
                [commonArrCopy removeObject:commonBus];
            }
        }
    }
    
    NSMutableDictionary *routeDictionary = [[NSMutableDictionary alloc]init];
    [routeDictionary setObject:pointA forKey:@"startPoint"];
    [routeDictionary setObject:pointB forKey:@"endPoint"];
    int maxStops = 20;
    for(NSString* bus in commonArrCopy){
        int numberOfStops = [self actualRouting:pointA To:pointB Bus:bus];
        //if no route found, skip these points
        if (numberOfStops == 0) {
            continue;
        }
        if (numberOfStops < maxStops) {
            //add these data to the return dictionary
            maxStops = numberOfStops;
            [routeDictionary setObject:[NSNumber numberWithInt:numberOfStops] forKey:@"stopNumbers"];
            [routeDictionary setObject:bus forKey:@"busNumber"];
        }
    }
    
    return routeDictionary;
}


//Perform the routing between two points
-(int)actualRouting:(NSString*)pointA To:(NSString*)pointB Bus:(NSString*)bus{    
    NSArray* routecheck=[self.busRoutes objectForKey:bus];//Actual route of bus
    
    //Get index of pointA and pointB
    NSInteger indexA = [routecheck indexOfObject:pointA];
    NSInteger indexB = [routecheck indexOfObject:pointB];
    
    //LOOP AND ADD POINTS
    if(indexA < indexB) {//Foward path
        return indexB - indexA;
    }
    else {//Loop out
        if ([bus isEqualToString:@"D1"] || [bus isEqualToString:@"D2"]) {
            NSLog(@"D1 and D2 cannot loop stops here");
            return 0;
        }
        else {
            NSInteger totalStops = [routecheck count]-1; //excluding itself
            return totalStops - indexA + indexB;
        }
    }
    return 0;
}


+ (double)getDistance:(CLLocationCoordinate2D)a To:(CLLocationCoordinate2D)b {
    CLLocation* apoint=[[CLLocation alloc]initWithLatitude:a.latitude longitude:a.longitude];
    CLLocation* bpoint=[[CLLocation alloc]initWithLatitude:b.latitude longitude:b.longitude];
    CLLocationDistance distance = [apoint distanceFromLocation:bpoint];
    return distance;
}

+ (NSString*)findNearestBuilding:(CLLocationCoordinate2D)location {
    NSString *result = @"";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Building_Cood" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    //threshold value
    double smallestdistance=10000000;
    
    for(NSString* busKeym in [dict allKeys]){
        NSArray* buildingInfo = [dict objectForKey:busKeym]; //Single mappoint
        CLLocationCoordinate2D newCoord = {[[buildingInfo objectAtIndex:1] doubleValue],[[buildingInfo objectAtIndex:2] doubleValue]};
        
        //check whether this distance is smaller than the existing threshold and non-zero
        if(([self getDistance:newCoord To:location] <= smallestdistance) && ([self getDistance:newCoord To:location]!=0)){
            smallestdistance=[self getDistance:newCoord To:location];
            result = [buildingInfo objectAtIndex:0] ;
        }
    }
    return result;
}



@end
