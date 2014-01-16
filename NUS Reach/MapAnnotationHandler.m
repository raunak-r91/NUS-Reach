//
//  MapAnnotationHandler.m
//  NUS Reach
//
//  Created by Raunak on 11/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "MapAnnotationHandler.h"

@implementation MapAnnotationHandler

- (id)init {
    self = [super init];
    if (self) {
        _locationAnnotationSet = [[NSMutableDictionary alloc]init];
                
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Building_Cood" ofType:@"plist"];
        _locationCoordinates = [NSDictionary dictionaryWithContentsOfFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"Building_Fulllist" ofType:@"plist"];
        _fullList = [NSDictionary dictionaryWithContentsOfFile:filePath];

    }
    return self;
}

//adds the annotation to the dictionary of events and returns false if location of event is invalid
- (BOOL)addAnnotation:(EventModel*)model {
    return [self parseLocation:model];
}


//returns true if the locaiton was successfully parsed (and subsequently added)
//returns false if parse unsuccessful
- (BOOL)parseLocation:(EventModel*)currentModel {
    NSNumber* newLat, *newLong;
    MapAnnotationModel* newPoint;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];

    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"BuildingParser" ofType:@"plist"];
    NSDictionary* locationParserDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    //check for special types of location from a given plist
    for (NSString* key in [locationParserDict allKeys]) {
        if ([currentModel.venue rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound) {
            currentModel.venue = [locationParserDict objectForKey:key];
            break;
        }
    }
    
    BOOL found = NO;
    
    //check if the location can be directly found from the direct building list
    for (NSString* key in self.locationCoordinates) {
        if ([currentModel.venue rangeOfString:key].location != NSNotFound) {
            found = YES;
            newLat = [((NSArray*)[self.locationCoordinates objectForKey:key]) objectAtIndex:1];
            newLong = [((NSArray*)[self.locationCoordinates objectForKey:key]) objectAtIndex:2];
            CLLocationCoordinate2D newCoords = CLLocationCoordinate2DMake([newLat doubleValue], [newLong doubleValue]);
            newPoint = [[MapAnnotationModel alloc] initWithCoordinate:newCoords title:currentModel.title subTitle:[dateFormatter stringFromDate:currentModel.start] model:currentModel];
            if ([self.locationAnnotationSet objectForKey:key] == nil) {
                NSMutableArray *eventsHere = [[NSMutableArray alloc]initWithObjects:newPoint, nil];
                [self.locationAnnotationSet setObject:eventsHere forKey:key];
            }
            else {
                NSMutableArray *eventsHere = (NSMutableArray*)[self.locationAnnotationSet objectForKey:key];
                [eventsHere addObject:newPoint];
            }
            break;
        }
    }
    //if the location was not found in the direct building list, search for it from
    //the list of all possible buildings and add to the dictionary accordingly
    if (!found) {
        for (NSString* key in self.fullList) {
            if ([key rangeOfString:currentModel.venue].location != NSNotFound) {
                found = YES;
                NSString *venueText = [[self.fullList objectForKey:key]objectAtIndex:3];
                newLat = [((NSArray*)[self.locationCoordinates objectForKey:venueText]) objectAtIndex:1];
                newLong = [((NSArray*)[self.locationCoordinates objectForKey:venueText]) objectAtIndex:2];
                CLLocationCoordinate2D newCoords = CLLocationCoordinate2DMake([newLat doubleValue], [newLong doubleValue]);
                newPoint = [[MapAnnotationModel alloc] initWithCoordinate:newCoords title:currentModel.title subTitle:[dateFormatter stringFromDate:currentModel.start] model:currentModel];
                if ([self.locationAnnotationSet objectForKey:venueText] == nil) {
                    NSMutableArray *eventsHere = [[NSMutableArray alloc]initWithObjects:newPoint, nil];
                    [self.locationAnnotationSet setObject:eventsHere forKey:venueText];
                }
                else {
                    NSMutableArray *eventsHere = (NSMutableArray*)[self.locationAnnotationSet objectForKey:venueText];
                    [eventsHere addObject:newPoint];
                    
                }
                break;
            }
        }
    }
    //if no matching location was found in the existing coordinates, return NO
    if (!found) {
        return NO;
    }
    return YES;
}

//returns all the events for a given location from the stored dictionary
- (NSArray*)getEventsForLocation:(NSString*)location {
    NSString *parsedLocation = [[NSString alloc]init];
    parsedLocation = [self getCodeFromLocation:location];
    
    return [self.locationAnnotationSet objectForKey:parsedLocation];
}


- (NSString*)getCodeFromLocation:(NSString*)location {
    NSString *parsedLocation = @"";
    for (NSString* key in self.locationCoordinates) {
        if ([location rangeOfString:key].location != NSNotFound) {
            parsedLocation = key;
            break;
        }
    }

    if ([parsedLocation isEqualToString:@""]) {
        for (NSString* key in self.fullList) {
            if ([location rangeOfString:key].location != NSNotFound) {
                parsedLocation = [[self.fullList objectForKey:key]objectAtIndex:3];
                break;
            }
        }
    }
    return parsedLocation;
}


@end
