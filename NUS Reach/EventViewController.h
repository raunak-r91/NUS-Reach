/*
 This class controls the actions for each particular event.
 It stores the event details into the EventModel
 It maintains an EventDetailView object of the event (that is shown each time the 
 event is tapped)
 It has a delegate to inform the relevant controllers when an action is taken on the
 event (edit, shared, get directions)
 It also offers support for posting the event on ivle and saving an event to the database
 */

#import "EventManager.h"
#import "EventModel.h"
#import "EventDetailView.h"
#import "CalendarManager.h"

@protocol EventViewDelegate <NSObject>
//provides the eventcontroller that is being edited
- (void)editEvent:(id)eventController;

//provides the eventcontroller that is being shared
- (void)shareEvent:(id)eventController;

//provides the location of the event to which directions are require
- (void)showRouteForLocation:(NSString*)location;
@end

@interface EventViewController : UIViewController <DetailViewDelegate>

@property (weak) id<EventViewDelegate> delegate;
@property (nonatomic, readonly) EventModel *model;
@property (nonatomic) EventDetailView *detailView;
@property (nonatomic) BOOL isUserAttending;
@property (nonatomic) BOOL isUserCreated;

//REQUIRES: a valid EventModel
//EFFECTS: initializes the detailview and self.model with the model provided
- (id)initWithModel:(EventModel*)model delegate:(id)delegate;

//REQUIRES: valid strings for each of the section
//EFFECTS: initializes the detailview and self.model based on each of the parameteres
- (id)initWithTitle:(NSString*)title eventid:(NSString*)eventID category:(int)c venue:(NSString*)v start:(NSDate*)s end:(NSDate*)e price:(NSString*)p description:(NSString*)d organizer:(NSString*)organizer contact:(NSString*)contact tag:(NSString*)tag delegate:(id)delegate;

//EFFECTS: saves the created event to the database
- (void)save;

//EFFECTS: posts the event to IVLE based on the event details entered by the user
- (void)postToIVLE;

@end