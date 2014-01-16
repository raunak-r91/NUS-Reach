/*
 This class controls all the functionality related with the creation and editing
 of an event. 
 The view is linked with StoryBoard.
 It is also linked with other popover classes to display 2 dropdowns for Categories
 and Locations
 It displays a custom keyboard for the input of start & end date
 Also, a pre-defined venue can be set if the user has used long-press to create 
 an event at a particular location.
 
 It has a delegate to inform the relevant controllers when an action is taken on 
 the event:
 - new event created
 - event edited (only applies to those events that the user created)
 - event deleted (only applies to those events that the user created)
 - updateEventList (to update the list of events when a newevent is created)
 */

#import <UIKit/UIKit.h>
#import "EventViewController.h"
#import "KeyboardInputView.h"
#import "LocationPickerViewController.h"
#import "CategoryPickerViewController.h"

@protocol EventCreateViewDelegate <NSObject>
//provides the new EventViewController that was created
- (void)newEventCreated:(EventViewController*)newEventController;

//provides the largest event id as and when encountered (from the database)
- (void)largestId:(NSString*)currentID;

//asks for a list of EventViewControllers to be shown in the eventsListView
- (NSArray*)getEventControllers;

//asks for the target event set on which to perform certain action
- (EventViewController*)getTarget;

//provides the EventViewController that is currently being seen
- (void)setTarget:(EventViewController*)event;

//provides the eventcontroller that is being edited
- (void)editEvent:(EventViewController*)event;

//provides the eventcontroller that is being shared
- (void)shareEvent:(EventViewController*)event;

//provides the eventcontroller that is to be removed
- (void)removeEvent:(EventViewController*)event;

//provides the location of the event to which directions are require
- (void)showRouteForLocation:(NSString*)location;

//delegates when an event is modified and the list should be updated
- (void)updateEventList;
@end

@interface EventCreateViewController : UIViewController <LocationPickerDelegate, LocationSubCategoryDelegate, LocationSelectDelegate, CategoryPickerDelegate, EventViewDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (weak) id<EventCreateViewDelegate> delegate;
@property (nonatomic, readwrite) NSString *largestID;
@property (nonatomic, strong) EventViewController *targetEvent;
@property (strong, nonatomic) IBOutlet UISwitch *postIVLEBtn;
@property (strong, nonatomic) IBOutlet UIButton *eventCreateCancelBtn;
@property (strong, nonatomic) IBOutlet UIView *eventCreateView;
@property (strong, nonatomic) IBOutlet UIScrollView *eventCreateScrollView;
@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextField *priceField;
@property (strong, nonatomic) IBOutlet UIButton *categoryBtn;
@property (strong, nonatomic) IBOutlet UITextView *descriptionField;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UITextField *startTimeField;
@property (strong, nonatomic) IBOutlet UITextField *endTimeField;
@property (strong, nonatomic) IBOutlet UIButton *venueButton;

//EFFECTS: dismisses the modal view controller when the cancel button is pressed
- (IBAction)cancelEventCreate:(UIButton *)sender;

//EFFECTS: sends a delegate to inform the relevant controller to save the event
- (IBAction)saveEvent:(id)sender;

//EFFECTS: displays a dropdown of categories
- (IBAction)displayCategoriesList:(id)sender;

//EFFECTS: displays a dropdown of locations for events
- (IBAction)displayDropDown:(id)sender;


//a pre-defined venue can be set if the user has used long-press to create
//an event at a particular location
- (void)setPredefinedVenue:(NSString *)venue;
@end

