/* This class controls the display of the sidebar view in the app
 It also manages the behavior of the filters applied by the user.
 It communicates with the other classes through delegates when a filter is modified by the user
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import <TapkuLibrary/TapkuLibrary.h>


@protocol FilterDelegate <NSObject>
//filter applied on the event type - ivle events or student events
- (void)eventTypeAdded;

//filter applied on the event type - ivle events or student events, where one of them is removed
- (void)eventTypeRemovedWithSelectedEvent:(eventCategory)eventType;

//filter applied on the event categories, and the modified list is sent
- (void)filtersModified:(NSArray*)newFilters;

//filter applied on the data - new dates are sent (one date, date range or no date)
- (void)dateModified:(NSDictionary*)newDate;
@end

@interface SideFilterViewController : UITableViewController <UITableViewDelegate,
UITableViewDataSource, UITextViewDelegate, TKCalendarMonthViewDelegate>

@property (weak) id<FilterDelegate>delegate;
@property NSArray *selectedPreferences;
@property eventCategory eventType;

//EFFECTS: sets the frame of the tableview of this controller
//MODIFIES: the frame of the tableview
- (void)setTablesFrame: (CGRect)thisTableFrame;

//EFFECTS: changes the filters on the side view controller
//MODIFIES: self.selectedPreferences
- (void)userInterestsChanged:(NSArray*)interests;

@end
