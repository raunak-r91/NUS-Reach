/*
 The class that shows the details of each event. This is usually called as a pagesheet
 and the view is initialized through the EventDetails.xib
 It has a delegate to inform the relevant controller when a button a pressed:
 - attend, edit, get directions, shareevent
 */

#import <UIKit/UIKit.h>

@protocol DetailViewDelegate
@optional

//delegate to inform when the attendbutton is pressed
- (void)attendEvent;

//delegate to inform when the editbutton is pressed
- (void)editEvent;

//delegate to inform when the directions button is pressed
- (void)showRoute;

//delegate to inform when the share button is pressed
- (void)shareEvent;
@end

@interface EventDetailView : UIView

@property (weak) id <DetailViewDelegate> delegate;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;
@property (strong, nonatomic) IBOutlet UILabel *titleValue;
@property (strong, nonatomic) IBOutlet UILabel *venueValue;
@property (strong, nonatomic) IBOutlet UILabel *timeValue;
@property (strong, nonatomic) IBOutlet UILabel *priceValue;
@property (strong, nonatomic) IBOutlet UILabel *categoryValue;
@property (strong, nonatomic) IBOutlet UILabel *organizerValue;
@property (strong, nonatomic) IBOutlet UILabel *contactValue;

@property (strong, nonatomic) IBOutlet UIScrollView *descriptionScroll;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;
@property (strong, nonatomic) IBOutlet UIButton *attendBtn;
@property (strong, nonatomic) IBOutlet UIButton *routeBtn;
@property (strong, nonatomic) IBOutlet UIButton *fbBtn;

//EFFECTS: initlizes the detail view with the details provided in the parameter
- (id)initWithWidth:(CGFloat)w height:(CGFloat)h title:(NSString*)title venue:(NSString*)venue time:(NSString*)time price:(NSString*)price category:(NSString*)category organizer:(NSString*)organizer contact:(NSString*)contact description:(NSString*)description;

//EFFECTS: modifies the button title from 'Attend' to 'Unattend'
//MODIFIES: attendBtn
- (void)userAttending;

//EFFECTS: sends a delegate when the edit button is pressed
- (IBAction)editBtnPressed:(id)sender;

//EFFECTS: sends a delegate when the attend button is pressed
- (IBAction)attendBtnPressed:(id)sender;

//EFFECTS: sends a delegate when the directions button is pressed
- (IBAction)routeBtnPressed:(id)sender;

//EFFECTS: sends a delegate when the share button is pressed
- (IBAction)facebookBtnPressed:(id)sender;

@end
