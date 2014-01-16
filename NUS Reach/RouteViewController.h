/*
 This class is responsible for the creation of the Directions view based on the 
 directions computed by another class. It takes in the directions and displays the
 details in a table form.
 It has a delegate to inform the relevant controller when the view was closed.
 
 */

#import <UIKit/UIKit.h>

@protocol RouterDelegate <NSObject>
//inform the relevant controller when the directions view was closed.
- (void)routeClosed;
@end

@interface RouteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak) id<RouterDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableViewCell *routeCell;
@property (strong, nonatomic) IBOutlet UITableView *routeTable;

//this route needs to be set when the view is being shown. The table cells are
//created based on this Dictionary route
@property NSDictionary *route;
@property CGFloat viewHeight;

//EFFECTS: closes the route view thats shown
- (IBAction)closeBtnPressed:(id)sender;

@end
