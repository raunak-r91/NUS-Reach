/* 
 This class is used to manage the interactions with the iPad Calendar and sync events with the calendar
 It implements a Singleton pattern as the default calendar controls all interactions with iCal.
 */

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface CalendarManager : NSObject

//EFFECTS: Returns the default calendar of the iPad, by checking for the singleton
//class and returning it
+ (CalendarManager*)defaultCalendar;

//EFFECTS: Adds an event in the iPad calendar of the device with the calendar name 'NUS Reach'
- (void)addEventWithTitle:(NSString*)title startDate:(NSDate*)sDate endDate:(NSDate*)eDate location:(NSString*)location description:(NSString*)description eventID:(NSString*)eventID;

//EFFECTS: Removes the given event from the calendar of the device based on the provided eventID
-(void)removeEventWithEventID:(NSString*)eventID;

@end
