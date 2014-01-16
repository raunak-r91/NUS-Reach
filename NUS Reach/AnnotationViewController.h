/*
 This class creates the table that is visible when each annotation pin is tapped
 It has an array (allElements) that has all the elements to be displayed
 It has a delegate to inform the relevant controller when a cell is selected
   and more details about that view is to be shown
 */

#import <UIKit/UIKit.h>
#import "MapAnnotationModel.h"

@protocol AnnotationViewDelegate
@optional
//informs which cell was tapped in the annotation to display the event detail accordingly
- (void)didTapAccessory:(MapAnnotationModel*)modelTapped;
@end

@interface AnnotationViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property NSArray *allElements;
@property (weak) id<AnnotationViewDelegate> delegate;
@end
