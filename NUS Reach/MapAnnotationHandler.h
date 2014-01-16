/*
 This class handles the adding of each event on the map annotation by parsing
 the venue of each event into the respective location coordinates and adding
 in a dictionary.
 This dictionary has the venue as its key, and all the associated events as the values
 */

#import <Foundation/Foundation.h>
#import "MapAnnotationModel.h"
#import "EventModel.h"

@interface MapAnnotationHandler : NSObject

@property (readonly) NSMutableDictionary* locationAnnotationSet;
@property (readonly) NSDictionary* locationCoordinates;
@property (readonly) NSDictionary* fullList;

//EFFECTS: adds the annotation to the dictionary of events and returns false if location of event is invalid
//MODIFIES: locationAnnotationSet - model is added, with the model venue as the key
- (BOOL)addAnnotation:(EventModel*)model;

//EFFECTS: returns all the events for a given location from the stored dictionary
// it parses the location provided into the key for the dictionary and returns accordingly
- (NSArray*)getEventsForLocation:(NSString*)location;

@end
