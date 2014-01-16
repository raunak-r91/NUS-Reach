/*
 This class is the main root controller of all the views and models. It handles the 
 delegates of all other controllers and takes the necessary actions. 
 It also handles the main user interaction and the actions to be taken
 This class integrates all the othe classes, as it implements the delegates from 
 the other classes.
 */


#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SideFilterViewController.h"
#import "DatabaseHandler.h"
#import "UserLoginViewController.h"
#import "EventsViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "UserModel.h"
#import "RouteViewController.h"
#import "UserOptionsViewController.h"
#import "UserInterestViewController.h"
#import "FBManager.h"

@interface MainViewController : UIViewController <UIGestureRecognizerDelegate,
EventsViewDelegate, FilterDelegate,MapViewUpdater, RouterDelegate, UserOptionsDelegate,
UserLoginDelegate, UserInterestDelegate, UINavigationControllerDelegate, FacebookLoginViewUpdater>

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UIView *sideView;
@property (strong, nonatomic) IBOutlet UIImageView *slideArrow;
@property MapViewController *mvController;

@property (strong, nonatomic) IBOutlet UIView *filterView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *userButton;

@property (strong, nonatomic) IBOutlet UIToolbar *controlToolbar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *displayTypeSegment;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *mapActivityView;

@property (strong,nonatomic) UserModel *userModel;

//REQUIRES: The user location to be present on the map
//EFFECTS: Sends an action to the MapViewController to center the map based on
//the user's current location
- (IBAction)myLocationButtonPressed:(id)sender;

//EFFECTS: Toggles the view type between the MapView and the Events List View
- (IBAction)displayTypeSegmentChanged:(id)sender;

//EFFECTS: Toggles the sidebar - slide in and out from the left
- (IBAction)sidebarPressed:(id)sender;

//EFFECTS: Shows the user login popover with the IVLE and Facebook login buttons
- (IBAction)userButtonPressed:(id)sender;

//EFFECTS: Modally load another viewcontroller that has a list of categories for
//the user to select, which will be stored in the database if the user is logged in
//MODIFIES: the UserModel - usermodel's userPreferences array will be modified
- (IBAction)settingsButtonPressed:(id)sender;

@end
