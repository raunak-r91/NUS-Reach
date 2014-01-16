/*
 This class contains the details about each particular event
 The details incorporate everything related to that event
 */

#import <Foundation/Foundation.h>

@interface EventModel : NSObject

@property (nonatomic, readwrite) NSString *eventID;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) int category;
@property (nonatomic, readwrite) NSString *venue;
@property (nonatomic, readwrite) NSDate *start;
@property (nonatomic, readwrite) NSDate *end;
@property (nonatomic, readwrite) NSString *price;
@property (nonatomic, readwrite) NSString *description;
@property (nonatomic, readwrite) NSString *organizer;
@property (nonatomic, readwrite) NSString *contact;
@property (nonatomic, readwrite) NSString *tag;


//EFFECTS: initializes all the properties of this event model
//MODIFIES: all the properties
- (id)initWithTitle:(NSString*)title eventid:(NSString*)eventId category:(int)c venue:(NSString*)v start:(NSDate*)s end:(NSDate*)e price:(NSString*)p description:(NSString*)d organizer:(NSString*)organizer contact:(NSString*)contact tag:(NSString*)tag;

@end
