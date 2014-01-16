/*
 This class is used to control the category dropdown, which is presented to the user when creating an event.
 It is a sub-class of UITableViewController and controls the display of the main category table.
 It informs the EventCreateViewController of the user's selection through delegates
 */

#import <UIKit/UIKit.h>

@protocol CategoryPickerDelegate <NSObject>
//informs the category that was selected from the dropdown
- (void) selectedCategory:(NSString*)category;
@end

@interface CategoryPickerViewController : UITableViewController

@property NSMutableArray* categoryList;
@property (weak) id<CategoryPickerDelegate> delegate;
@end
