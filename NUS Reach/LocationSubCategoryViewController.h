/*
 This class is used to control the location dropdown, which is presented to the user when creating an event.
 It is a sub-class of UITableViewController and controls the display of the sub category table.
 It informs the EventCreateViewController of the user's selection through delegates
 */

#import <UIKit/UIKit.h>
#import "LocationSelectViewController.h"

@protocol LocationSubCategoryDelegate <NSObject>
//informs about the locations in the subcategory selected
- (void) selectedSubCategoryWithLocations:(NSArray *)locations;
@end

@interface LocationSubCategoryViewController : UITableViewController
@property NSArray* locationSubCategories;
@property (weak) id<LocationSubCategoryDelegate> delegate;
@end
