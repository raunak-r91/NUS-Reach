//
//  EventFilter.m
//  NUS Reach
//
//  Created by biyan on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "EventFilter.h"

@implementation EventFilter
@synthesize category, price, dates, tag, keyword;

- (id)init {
    if(self = [super init]) {
        
    }
    return self;
}

- (void)setCategory:(int)c price:(NSString*)p date:(NSArray*)d tag:(NSArray*)t {
    category = c;
    price = p;
    dates = d;
    tag = t;
}

- (NSArray*)filter:(NSArray *)events {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(EventViewController *event in events) {
        BOOL categoryCompare = (event.model.category == category);
        BOOL priceCompare = YES;//(!price || [event.model.price isEqualToString:price]);
        BOOL startDateCompare = NO;

        //check if the filter is a daily or weekly or all days
        
        //all days
        if ([self.dates count] == 0) {
            startDateCompare = YES;
        }
        //events for a day
        else if ([self.dates count] == 1) {
            NSDate *startDate = [dates objectAtIndex:0];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"dd MMM yyyy"];
            startDateCompare = ([[dateFormatter stringFromDate:event.model.start] isEqualToString:[dateFormatter stringFromDate:startDate]]);
        }
        //events for a date range
        else if ([self.dates count] == 2) {
            NSDate *startDate = [dates objectAtIndex:0];
            NSDate *endDate = [dates objectAtIndex:1];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"dd MMM yyyy"];
            if (([event.model.start compare:startDate] == NSOrderedDescending) &&
                ([event.model.start compare:endDate] == NSOrderedAscending)) {
                startDateCompare = YES;
            }
        }
        
        //if no preferene given for categories, no check kept, otherwise check
        //whether the event is of the selected criterea
        BOOL tagCompare = NO;
        if ([tag count] == 0) {
            tagCompare = YES;
        }
        else {
            for (NSString *preference in tag) {
                if ([preference rangeOfString:event.model.tag].location != NSNotFound ){
                    tagCompare = YES;
                    break;
                }
                else if ([event.model.tag rangeOfString:preference].location != NSNotFound ){
                    tagCompare = YES;
                    break;
                }
            }
        }
        
        //if all the critera match, add the event to the array
        if(categoryCompare && priceCompare && startDateCompare && tagCompare) {
            [result addObject:event];
        }
    }
    
    return result;
}

- (NSArray*)filterByCategory:(NSMutableArray*)events {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(EventViewController *event in events) {
        BOOL categoryCompare = (event.model.category == category);
        if(categoryCompare) {
            [result addObject:event];
        }
    }
    return result;
}

@end
