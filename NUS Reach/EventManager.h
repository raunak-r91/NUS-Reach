/*
 The is the facade that links with the backend for the events.
 It does the pulling of events from ivle and database
 It does the pushing of events from ivle and database
 It also pushes and pulls user created + user attended events to/from database
 */

#import <Foundation/Foundation.h>
#import "DatabaseHandler.h"
#import "IVLEManager.h"
#import "EventModel.h"
#import "Constants.h"

@interface EventManager : NSObject

//EFFECTS: initalizes the internal data
- (id)init;

//EFFECTS: initializes the internal data based on the ivle object provided
- (id)initWithIVLE:(IVLEManager*)ivle;

//EFFECTS: returns all the events pulled from IVLE
- (NSArray*)getEventsFromIVLE;

//EFFECTS: returns all the events pulled from database
- (NSArray*)getEventsFromDatabase;

//EFFECTS: saves the given event model by linking with the database
//MODIFIES: event table in database
- (void)save:(EventModel*)model;

//EFFECTS: removes the given event model from the database
//MODIFIES: event table in database
- (void)remove:(EventModel*)model;

//EFFECTS: sends a post request to ivle for the given event model by linking with IVLE manager
- (void)postToIVLE:(EventModel*)model;

//EFFECTS: adds a row in the "Attending" table for which user is attending which event
//MODIFIES: attending table in database
- (void)saveAttend:(EventModel*)model id:(NSString*)user;

//EFFECTS: removes a row in the "Attending" table for the given user
//MODIFIES: attending table in database
- (void)removeAttend:(EventModel*)model id:(NSString*)user;

//EFFECTS: adds a row in the create table to know which user created which events
//MODIFIES: "create" table in database
- (void)saveCreate:(EventModel*)model id:(NSString*)user;

//EFFECTS: removes a row from the create table based on the event and the user
//MODIFIES: "create" table in database
- (void)removeCreate:(EventModel*)model id:(NSString*)user;

@end
