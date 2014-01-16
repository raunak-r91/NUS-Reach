/*This class is responsible for handling for all the event based functionalities
 It stores a list of all the individual events which have been pulled from IVLE/database
 It also controls the display of the list view in the app
 It is responsible for linking the event with their detail view, and related functionalities such as the event edit, attend buttons etc.
 It communicates with various other classes through delegates in the following cases:
  - new event created
  - share events to Facebook
  - show directions to event 
 */

#import "EventViewController.h"
#import "EventCreateViewController.h"
#import "EventFilter.h"
#import "EventManager.h"
#import <QuartzCore/QuartzCore.h>

@protocol EventsViewDelegate <NSObject>

//provides the new EventViewController that was created
- (void)newEventCreated:(EventViewController*)newEventController;

//provides the largest event id as and when encountered (from the database)
- (void)largestId:(NSString*)currentID;

//asks for a list of EventViewControllers to be shown in the eventsListView
- (NSArray*)getEventControllers;

//provides the EventViewController that is currently being seen
- (void)setTarget:(EventViewController*)event;

//provides the EventViewController and the event details that the user wants to share
- (void)shareEvent:(EventViewController*)event;

//asks for the target event set on which to perform certain action
- (EventViewController*)getTarget;

//provides the location of the event for which the user wants to see directions
- (void)showRouteForEvent:(NSString*)location;
@end

@interface EventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EventCreateViewDelegate>

@property (weak) id<EventsViewDelegate>delegate;
@property (nonatomic, readwrite) EventViewController *targetEvent;
@property (nonatomic, readonly) EventCreateViewController *eventCreate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *eventListEditBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *eventListAttendBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *eventListFbBtn;
@property (strong, nonatomic) IBOutlet UITableView *eventsListView;
@property (strong, nonatomic) IBOutlet UIView *eventDetailView;

- (id)init;

//REQUIRES: A selected Event
//EFFECTS: Opens the fields to edit the Event
//MODIFIES: The EventModel of the particular event is modified
- (IBAction)editEventList:(id)sender;

//REQUIRES: A selected Event
//EFFECTS: Stores the event in the iPad Calendar and sends the information to database
- (IBAction)attendEventList:(id)sender;

//REQUIRES: A selected Event
//EFFECTS: Sends a delegate to share the event details through facebook
- (IBAction)shareEventList:(id)sender;

//EFFECTS: Loads all the events and from the database
// based on the attendList and the createdList, marks the events at attending/unattending
// & Edit
//MODIFIES: self.eventControllers
- (void)loadAllEventsForUser:(NSArray*)attendingList :(NSArray*)createdList;

//REQUIRES: eventType - {ivle, usercreate, both}
//          date = {single date, date range or nil}
//EFFECTS: returns an array of EventViewControllers that contain that events based on the filteres applied
- (NSArray*)loadEvents:(NSDictionary*)date withEventType:(eventCategory)eventType Categories:(NSArray*)categories;

//REQUIRES: newEvents to be a list of EventViewControllers with valid EventModels
//EFFECTS: Reloads the eventlist table with the new list of events, usually after a filter is applied
//MODIFIES: the eventsListView displaying the list of events
- (void)reloadData:(NSArray*)newEvents;
@end
