//
//  CalendarManager.m
//  NUS Reach
//
//  Created by Raunak on 13/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "CalendarManager.h"

@interface CalendarManager () {
    EKEventStore* store;
    NSString* calendarIdentifier;
    BOOL syncAllowed;
    NSMutableDictionary* eventsIdentifiers;
}

@end

@implementation CalendarManager

static CalendarManager* manager = nil;

+(CalendarManager*)defaultCalendar {
    
    @synchronized([CalendarManager class]) {
        if(!manager) {
            manager = [[self alloc] init];
        }
        return manager;
    }
    return nil;
}

+(id)alloc {
    
    @synchronized([CalendarManager class]) {
        NSAssert(manager == nil, @"Attempted to allocate a second instance of a singleton.");
        manager = [super alloc];
        return manager;
    }
    return nil;
}

-(id)init {
	self = [super init];
	if (self) {
		// initialize stuff here
        store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            /* This code will run when user has made his/her choice */
            if (granted) {
                syncAllowed = YES;
            }
            else {
                syncAllowed = NO;
            }
        }];
        
        //Check if a Calendar had been created earlier
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        calendarIdentifier = [pref objectForKey:@"Calendar Identifier"];
//        eventsIdentifiers = [NSMutableDictionary dictionary];
	}
	return self;
}

//Add event to iCal
-(void)addEventWithTitle:(NSString*)title startDate:(NSDate*)sDate endDate:(NSDate*)eDate location:(NSString*)location description:(NSString*)description eventID:(NSString*)eventID {
    if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
        EKEvent *newEvent = [EKEvent eventWithEventStore:store];
        newEvent.title = title;
        newEvent.startDate = sDate;
        newEvent.endDate = eDate;
        newEvent.location = location;
        newEvent.notes = description;
        [newEvent setCalendar:[self getCalendar]];
        [store saveEvent:newEvent span:EKSpanThisEvent error:nil];
        [self fileOperationForAddEventWithID:eventID andCalendarID:newEvent.eventIdentifier];
    }
}

//Store corresponding Calendar ID of events in file
-(void)fileOperationForAddEventWithID:(NSString*)eventID andCalendarID:(NSString*)calID {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Events Identifiers"];
    eventsIdentifiers = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    [eventsIdentifiers setValue:calID forKey:eventID];
    [eventsIdentifiers writeToFile:filePath atomically:YES];
}

//Remove events from iCal on unattend
-(void)removeEventWithEventID:(NSString*)eventID {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Events Identifiers"];
    eventsIdentifiers = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString* calID = [eventsIdentifiers objectForKey:eventID];
    EKEvent *event = [store eventWithIdentifier:calID];
    [store removeEvent:event span:EKSpanThisEvent error:nil];
    
    [eventsIdentifiers removeObjectForKey:eventID];
    [eventsIdentifiers writeToFile:filePath atomically:YES];
}

//Get the instance for the NUS Reach calendar in iCal
-(EKCalendar*)getCalendar {
    EKCalendar* cal;
    if (calendarIdentifier == nil) {
        cal = [self createNewCalendar];
    }
    else {
        cal = [store calendarWithIdentifier:calendarIdentifier];
        if (cal == nil) {
            NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
            [pref removeObjectForKey:@"Calendar Identifier"];
            calendarIdentifier = nil;
            cal = [self createNewCalendar];
        }
    }
    return cal;
}

//Create a new calendar for NUS Reach in iCal if it does not exist
-(EKCalendar*)createNewCalendar {
    EKCalendar* cal;
    EKSource *localSource = nil;
    for (EKSource *source in store.sources) {
        if (source.sourceType == EKSourceTypeLocal)
        {
            localSource = source;
            break;
        }
    }
        
    cal = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:store];
    cal.title = @"NUS Reach";
    cal.source = localSource;
    [store saveCalendar:cal commit:YES error:nil];
    calendarIdentifier = cal.calendarIdentifier;
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:calendarIdentifier forKey:@"Calendar Identifier"];
    
    return cal;
}


@end
