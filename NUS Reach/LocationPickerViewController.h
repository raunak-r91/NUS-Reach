/*
 This class is used to control the location dropdown, which is presented to the user when creating an event.
 It is a sub-class of UITableViewController and controls the display of the location category table.
 It informs the EventCreateViewController of the user's selection through delegates
 */

#import <UIKit/UIKit.h>
#import "LocationSubCategoryViewController.h"
#import "LocationSelectViewController.h"

@protocol LocationPickerDelegate <NSObject>
//informs which subcategories are to be displayed
- (void) selectedCategoryWithSubCategories:(NSArray*)subCategories;

//informs which locations are to be displayed
- (void) selectedCategoryWithLocations:(NSArray *)locations;
@end


@interface LocationPickerViewController : UITableViewController
@property NSArray* locationCategories;
@property (weak) id<LocationPickerDelegate> delegate;

@end
