/*
 This class has various filters to according to which the all the events are filtered
 The filtered events are returned as an array.
 */

#import <Foundation/Foundation.h>
#import "EventViewController.h"

@interface EventFilter : NSObject

@property (nonatomic, readonly) int category;
@property (nonatomic, readonly) NSString *price;
@property (nonatomic, readonly) NSString *keyword;
@property (nonatomic, readonly) NSArray *dates;
@property (nonatomic, readonly) NSArray *tag;
@property (nonatomic, readonly) NSString *userid;

//EFFECTS: it sets the filters fields based on the parameteres
//MODIFIES: the properties of this instance variable
- (void)setCategory:(int)category price:(NSString*)price date:(NSArray*)date tag:(NSArray*)tag;

//EFFECTs: returns an array of EventViewControllers based on the filter that is set
//  here it uses all the filters that are set in this instance
- (NSArray*)filter:(NSArray*)events;

//EFFECTs: returns an array of EventViewControllers based on the category filter that is set
- (NSArray*)filterByCategory:(NSArray*)events;

@end
