/*
 This class is used to control the location dropdown, which is presented to the user when creating an event.
 It is a sub-class of UITableViewController and controls the display of the locations table.
 It informs the EventCreateViewController of the user's selection through delegates
 */

#import <UIKit/UIKit.h>

@protocol LocationSelectDelegate <NSObject>
//informs the location that was selected from the dropdown
- (void) selectedLocation:(NSString*)location;
@end

@interface LocationSelectViewController : UITableViewController
@property NSArray* locationList;
@property (weak) id<LocationSelectDelegate> delegate;
@end
