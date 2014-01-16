//
//  EventManager.m
//  NUS Reach
//
//  Created by biyan on 28/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "EventManager.h"

@interface EventManager ()
@property (nonatomic, readwrite) NSMutableArray *models;
@property (nonatomic, readonly) IVLEManager* ivle;
@end

@implementation EventManager
@synthesize  models, ivle;

- (id)init {
    if(self = [super init]) {
        models = [[NSMutableArray alloc] init];
        ivle = [[IVLEManager alloc]init];
    }
    return self;
}

- (id)initWithIVLE:(IVLEManager*)i {
    if(self = [super init]) {
        ivle = i;
        models = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSDictionary*)toNSDictionary:(EventModel*)model {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:model.title forKey:@"title"];
    [dictionary setValue:[NSNumber numberWithUnsignedInteger:model.category] forKey:@"category"];
    [dictionary setValue:model.eventID forKey:@"eventid"];
    [dictionary setValue:model.venue forKey:@"venue"];
    [dictionary setValue:model.price forKey:@"price"];
    [dictionary setValue:model.start forKey:@"start"];
    [dictionary setValue:model.end forKey:@"end"];
    [dictionary setValue:model.description forKey:@"description"];
    [dictionary setValue:model.organizer forKey:@"organizer"];
    [dictionary setValue:model.contact forKey:@"contact"];
    [dictionary setValue:model.tag forKey:@"tag"];
    
    return dictionary;
}

- (void)save:(EventModel*)model {
    [DatabaseHandler insertRow:[self toNSDictionary:model] inTable:@"Event"];
}

- (void)remove:(EventModel*)model {
    [DatabaseHandler deleteRowWithData:[self toNSDictionary:model] FromTable:@"Event"];
}

- (void)postToIVLE:(EventModel *)model {
    [ivle postNewEventUsingTitle:model.title Venue:model.venue Price:model.price Category:model.tag StartTime:model.start EndTime:model.end Description:model.description];
}

- (void)saveAttend:(EventModel*)model id:(NSString*)user {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:model.eventID forKey:@"eventid"];
    [dictionary setValue:user forKey:@"user"];
    [DatabaseHandler insertRow:dictionary inTable:@"Attend"];
}

- (void)removeAttend:(EventModel*)model id:(NSString*)user {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:model.eventID forKey:@"eventid"];
    [dictionary setValue:user forKey:@"user"];
    [DatabaseHandler deleteRowWithData:dictionary FromTable:@"Attend"];
    return;
}

- (void)saveCreate:(EventModel*)model id:(NSString*)user {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:model.eventID forKey:@"eventid"];
    [dictionary setValue:user forKey:@"user"];
    [DatabaseHandler insertRow:dictionary inTable:@"Create"];
}

- (void)removeCreate:(EventModel*)model id:(NSString*)user {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:model.eventID forKey:@"eventid"];
    [dictionary setValue:user forKey:@"user"];
    [DatabaseHandler deleteRowWithData:dictionary FromTable:@"Create"];
    return;
}

- (NSArray*)getEventsFromIVLE {
    return [ivle pullAllEvents];
}


- (NSArray*)getEventsFromDatabase {
    return [DatabaseHandler getAllRowsFromTable:@"Event"];
}

@end
