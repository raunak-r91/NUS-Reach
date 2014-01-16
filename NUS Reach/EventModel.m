//
//  EventModel.m
//  NUS Reach
//
//  Created by biyan on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "EventModel.h"

@implementation EventModel
@synthesize title, category, venue, start, end, price, description, organizer, contact, tag, eventID;

- (id)initWithTitle:(NSString*)t eventid:(NSString*)eventId category:(int)c venue:(NSString*)v start:(NSDate*)s end:(NSDate*)e price:(NSString*)p description:(NSString*)d organizer:(NSString*)o contact:(NSString*)con tag:(NSString*)ta {
    if(self = [super init]) {
        title = t;
        eventID = eventId;
        category = c;
        venue = v;
        start = s;
        end = e;
        price = p;
        description = d;
        organizer = o;
        contact = con;
        tag = ta;
    }
    return self;
}

@end
