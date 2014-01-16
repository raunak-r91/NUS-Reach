//
//

#import "MainViewController.h"
#import <MQMapKit/MQMapKit.h>
#import "EventsViewController.h"
#import "IVLEManager.h"
#import "BusRouter.h"
#import "FBManager.h"

@interface MainViewController ()
@property NSDictionary *displayDate;
@property eventCategory eventType;
@property NSString *largestEventId;
@property SideFilterViewController *sfController;
@property EventsViewController *evController;
@property EventViewController *targetEvent;
@property IVLEManager *ivleManager;
@property FBManager *fbManager;
@property BOOL isFirstLoad;
@property UIAlertView* loginRequired;
@property RouteViewController *rvController;
@property UIView *routerView;
@property BOOL isMapView;
@property UIPopoverController *userPopover;
@property UserOptionsViewController *userOptionsController;
@property UserLoginViewController *userLoginController;
@property UserInterestViewController* userInterestController;
@end

@implementation MainViewController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userModel = [[UserModel alloc] init];
    NSMutableArray* interestCategories = [[NSMutableArray alloc]initWithObjects:@"Arts and Entertainment", @"Conferences and Seminars", @"Fairs and Exhibitions", @"Health and Wellness", @"Lectures and Workshops", @"Social Events", @"Sports and Recreation", @"Others", nil];
    self.userModel.userPreferences = interestCategories;
        
    self.ivleManager = [[IVLEManager alloc]init];
    if ([self.ivleManager validate]) { //validate user
        self.userModel.username = [self.ivleManager getUserId];
        self.userModel.isLoggedin = YES;
        self.userButton.tintColor = [UIColor colorWithRed:0.0f green:(127.0/255.0f) blue:0.0f alpha:1.0f];
        [self performSelectorInBackground:@selector(loadUserPreferencesFromDatabase) withObject:nil];
    }
    else { //user logged in already
        self.userModel.isLoggedin = NO;
        self.userButton.tintColor = [UIColor colorWithRed:(127.0/255.0f) green:0.0f blue:0.0f alpha:1.0f];
        self.userModel.username = nil;
    }

    [self setupUserPopover];
    [self setupMap];
    [self.mapActivityView startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setupUserAttending];
        [self setupUserCreated];
      dispatch_sync(dispatch_get_main_queue(), ^{
//          [self setupEvents];
          [self performSelectorInBackground:@selector(setupEvents) withObject:nil];
        });
    });
    [self addGestureForSlide];
    [self setupSideFilters];
    
    self.isFirstLoad = YES;
    self.slideArrow.hidden = YES;
    self.sideView.hidden = YES;
    self.largestEventId = @"0";
    self.eventType = kOfficialEvent;
    self.routerView = [[UIView alloc]initWithFrame:CGRectMake(200, 100, 370, 420)];
    self.routerView.layer.borderWidth = 3;
    [self.mapView addSubview:self.routerView];
    self.routerView.hidden = YES;
    
    //facebook
    self.fbManager = [[FBManager alloc]init];
    self.fbManager.loginButtonUpdater = self;
    
}


- (void)viewDidAppear:(BOOL)animated {
    CGRect sideFrame = self.sideView.frame;
    CGRect slideArrowFrame = self.slideArrow.frame;
    sideFrame.origin.x = -sideFrame.size.width;
    slideArrowFrame.origin.x = 0;
    self.sideView.frame = sideFrame;
    self.slideArrow.frame = slideArrowFrame;
    if (!self.isFirstLoad) {
        self.sideView.hidden = NO;
        self.slideArrow.hidden = NO;
    }
    else {
        self.isFirstLoad = NO;
    }
    if (!self.isMapView) {
        [self adjustAllEventView];
    }
    
}

//check if the user if logged in, and load his interests from the database
- (void)loadUserPreferencesFromDatabase {
    NSArray *usersData = [DatabaseHandler getAllRowsFromTable:@"UserData"];
    NSArray *userRecords;
    
    for (NSDictionary *thisVal in usersData) {
        if ([[thisVal objectForKey:@"userid"] isEqualToString:self.userModel.username]) {
            userRecords = [NSArray arrayWithArray:[thisVal objectForKey:@"preferences"]];
            break;
        }
    }
    self.userModel.userPreferences = [NSArray arrayWithArray:userRecords];
    self.sfController.selectedPreferences = self.userModel.userPreferences;
    [self.sfController.tableView reloadData];
}

- (void)setupEvents {
    self.evController = [[EventsViewController alloc] init];
    self.evController.delegate = self;
    [self.evController loadAllEventsForUser:self.userModel.eventsAttending :self.userModel.eventsCreated];
    [self reloadAllEvents];
    [self.mapActivityView stopAnimating];
    self.sideView.hidden = NO;
    self.slideArrow.hidden = NO;
}

- (void)setupUserAttending {
    NSArray *allRecords = [DatabaseHandler getAllRowsFromTable:@"Attend"];
    NSMutableArray *userRecords = [[NSMutableArray alloc]init];
    
    for (NSDictionary *thisVal in allRecords) {
        if ([[thisVal objectForKey:@"user"] isEqualToString:self.userModel.username]) {
            [userRecords addObject:[thisVal objectForKey:@"eventid"]];
        }
    }
    self.userModel.eventsAttending = userRecords;
}

- (void)setupUserCreated {
    NSArray *allRecords = [DatabaseHandler getAllRowsFromTable:@"Create"];
    NSMutableArray *userRecords = [[NSMutableArray alloc]init];
    for (NSDictionary *thisVal in allRecords) {
        if ([[thisVal objectForKey:@"user"] isEqualToString:self.userModel.username]) {
            [userRecords addObject:[thisVal objectForKey:@"eventid"]];
        }
    }
    self.userModel.eventsCreated = userRecords;
}

- (void)setupMap {
    self.mvController = [[MapViewController alloc] init];
    [self.mvController setDelegate:self];
    [self.mapView addSubview:self.mvController.view];
    self.isMapView = YES;
}

//setup the side filters
- (void)setupSideFilters {
    self.sfController = [[SideFilterViewController alloc]initWithStyle:UITableViewStylePlain];
    self.sfController.selectedPreferences = self.userModel.userPreferences;
    self.sfController.delegate = self;
    CGRect toSetFrame = CGRectMake(0, 0, 0, 0);
    toSetFrame.size = self.filterView.frame.size;
    [self.sfController setTablesFrame: toSetFrame];
    [self.filterView addSubview:self.sfController.view];
    
}

//setup the userpopover
- (void)setupUserPopover {
    self.userOptionsController = [[UserOptionsViewController alloc]initWithNibName:@"UserOptions" bundle:[NSBundle mainBundle]];
    self.userOptionsController.delegate = self;
    [self.userOptionsController setContentSizeForViewInPopover:self.userOptionsController.view.bounds.size];

    self.userLoginController = [[UserLoginViewController alloc]initWithUser:self.userModel];
    self.userLoginController.delegate = self;
    [self.userLoginController setContentSizeForViewInPopover:self.userLoginController.view.bounds.size];
    
    if ([self.userModel isLoggedin]) {
        [self.userOptionsController setIvleButtonTitle:@"Logout"];
    }
    else {
        [self.userOptionsController setIvleButtonTitle:@"Login"];
    }

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.userOptionsController];
    navController.delegate = self;
    self.userPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
}

//setsup gestures
- (void)addGestureForSlide {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(slideSidebar:)];
    [panGesture setDelegate:self];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [self.slideArrow addGestureRecognizer:panGesture];
}

//the guesture on the slide arrow to drag the sidebar
- (void)slideSidebar:(UIGestureRecognizer*)gesture {
    CGPoint translationDelta =  [(UIPanGestureRecognizer*)gesture translationInView:gesture.view.superview ];
    CGRect sideFrame = self.sideView.frame;
    CGRect slideArrowFrame = self.slideArrow.frame;
    CGRect mapFrame = self.mapView.frame;
    
    if (sideFrame.origin.x >= 0 && translationDelta.x >= 0) {
        return;
    }
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        sideFrame.origin.x  = sideFrame.origin.x+translationDelta.x;
        sideFrame.origin.x = sideFrame.origin.x > 0? 0: sideFrame.origin.x;
        self.sideView.frame = sideFrame;
        
        slideArrowFrame.origin.x = sideFrame.origin.x + sideFrame.size.width;
        self.slideArrow.frame = slideArrowFrame;
        mapFrame.origin.x = slideArrowFrame.origin.x;
        mapFrame.size.width = 1024 - mapFrame.origin.x;
        self.mapView.frame = mapFrame;
        if (!self.isMapView) {
            [self adjustAllEventView];
        }
    }
    
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
        [self toggleSideview];
    }
    
    [((UIPanGestureRecognizer*)gesture) setTranslation:CGPointMake(0, 0) inView:gesture.view.superview];
}

//based on the current direction of pulling/pushing the sidebar, the sidebar is slided
- (void)toggleSideview {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect sideFrame = self.sideView.frame;
    CGRect slideArrowFrame = self.slideArrow.frame;
    CGRect mapFrame = self.mapView.frame;
    
    if (fabs(sideFrame.origin.x) > sideFrame.size.width * 0.5) {
        sideFrame.origin.x = -self.sideView.frame.size.width;
    }
    else {
        sideFrame.origin.x = 0;
    }
    self.sideView.frame = sideFrame;
    slideArrowFrame.origin.x = sideFrame.origin.x + sideFrame.size.width;
    self.slideArrow.frame = slideArrowFrame;
    
    mapFrame.origin.x = slideArrowFrame.origin.x;
    mapFrame.size.width = 1024 - mapFrame.origin.x;
    self.mapView.frame = mapFrame;
    if (!self.isMapView) {
        [self adjustAllEventView];
    }

    [UIView commitAnimations];
}

- (void)adjustAllEventView {
    CGRect allViewFrame = self.evController.view.frame;
    allViewFrame.size = self.mapView.frame.size;
    [self.evController.view setFrame:allViewFrame];
}

//initialize and display the route view on the map
- (void)displayRouteOnMap:(NSDictionary*)route {
    self.rvController = [[RouteViewController alloc]init];
    [self.rvController setDelegate:self];
    self.rvController.route = route;
    [self.mapView addSubview:self.routerView];
    self.routerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.routerView.opaque = NO;
    self.routerView.alpha = 0.8;
    self.routerView.hidden = NO;
    
    [self.routerView addSubview:self.rvController.view];
    CGFloat height = self.rvController.viewHeight;
    CGRect routerFrame = self.routerView.frame;
    routerFrame.size.height = height + 50;
    [self.routerView setFrame:routerFrame];
    CGRect routerTableFrame = self.rvController.view.frame;
    routerTableFrame.size.height = height + 50;
    [self.rvController.view setFrame:routerTableFrame];
    
    CGFloat viewCenterY = self.view.center.y;
    CGFloat viewCenterX = self.view.frame.size.width - self.slideArrow.frame.origin.x;
    self.routerView.center = CGPointMake(viewCenterX/2,viewCenterY);
    
}


//send data to the destination controllers based on their type
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createView"]) {
        [[segue destinationViewController] setDelegate:self.evController];
        if ([sender isKindOfClass:[NSString class]]) {
            [[segue destinationViewController] setPredefinedVenue:(NSString*)sender];
        }
    }
    
    if ([[segue destinationViewController] isKindOfClass:[EventsViewController class]]) {
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setLargestID:[NSString stringWithFormat:@"%d", ([self.largestEventId intValue] + 1)]];
    }
    else if ([[segue destinationViewController] isKindOfClass:[UserLoginViewController class]]) {
        [[segue destinationViewController] setIvleManager:self.ivleManager];
    }
    
}

//before performing a segue, check whether the user is logged in & show that log in view
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"createView"]) {
        IVLEManager *obj = [[IVLEManager alloc] init];
        if ([obj validate]) {
            return YES;
        }
        else {
            if (![self.userPopover isPopoverVisible]) {
                [self.userPopover presentPopoverFromBarButtonItem:self.userButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
                NSLog(@"Value: %@", self.userPopover.contentViewController.presentingViewController);
                
                if ([((UINavigationController*)self.userPopover.contentViewController).visibleViewController isKindOfClass:[UserOptionsViewController class]]) {
                    [self.userOptionsController.navigationController pushViewController:self.userLoginController animated:YES];
                }
            }
            return NO;
            
        }
    }
    else {
        return YES;
    }
}

#pragma mark - Events Delegate
//add the newly created event to the map
- (void)newEventCreated:(EventViewController*)newEventController {
    [self.mvController addAnnotation:newEventController];
}

//get directions button was tapped on the event detail view, and show directions
//from current location to that event's location
- (void)showRouteForEvent:(NSString *)location {
    BusRouter *busRoute = [[BusRouter alloc]init];
    [self displayRouteOnMap:[busRoute routeBetweenPoints:self.mvController.mapView.userLocation.coordinate Venue:location]];
    [self.mvController dismissDetailController];
}

//set the largenteventid in the database thats currently present
- (void)largestId:(NSString *)currentID {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:currentID];
    NSNumber *currentNumber = [f numberFromString:self.largestEventId];
    if ([myNumber intValue] > [currentNumber intValue]) {
        currentNumber = myNumber;
    }
    self.largestEventId = [currentNumber stringValue];
}

//the list of filtered controllers to be shown on the list view
//each time the EventListView is reloaded, this function is called to return the new filtered eventControllers
- (NSArray*)getEventControllers {
    return [self.evController loadEvents:self.displayDate withEventType:self.eventType Categories:self.userModel.userPreferences];
}


- (void)setTarget:(EventViewController*)event {
    self.targetEvent = event;
}

- (EventViewController*)getTarget {
    return self.targetEvent;
}

//converts the current event data into a dictionary that can be shared with facebook
- (void)shareEvent:(EventViewController *)event {
    if ([FBManager isSessionOpen]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm"];
        NSString *time = [dateFormatter stringFromDate:event.model.start];
        NSString *link = [NSString stringWithFormat:@"%@%@", @"https://aces01.nus.edu.sg/CoE/CoEEvents?eventID=", event.model.eventID];
        
        NSMutableDictionary *shareDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                          @"333490756754557", @"app_id",
                                          event.model.title, @"name",
                                          time, @"caption",
                                          event.model.description, @"description",
                                          link, @"link",
                                          nil
                                          ];
        [self.fbManager shareButtonAction:shareDict];
    }
    else {
        [self.userPopover presentPopoverFromBarButtonItem:self.userButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}


//apply the various filers each time the user changes the filers
//perform the filters in background as they might take time, and shouldn't affect UI
#pragma mark - Sideview Filters Delegate
- (void)filtersModified:(NSArray*)newFilters {
        self.userModel.userPreferences = newFilters;
    [self performSelectorInBackground:@selector(reloadAllEvents) withObject:nil];
}

- (void)dateModified:(NSDictionary*)newDate {
    self.displayDate = newDate;
    [self performSelectorInBackground:@selector(reloadAllEvents) withObject:nil];
}

- (void)eventTypeAdded {
    self.eventType = kBothEvent;
    [self performSelectorInBackground:@selector(reloadAllEvents) withObject:nil];
}

- (void)eventTypeRemovedWithSelectedEvent:(eventCategory)eventType {
    self.eventType = eventType;
    [self performSelectorInBackground:@selector(reloadAllEvents) withObject:nil];
}

//depending on the type of view, its loads with the view by checking whether each
//view fulfills the criterea
- (void)reloadAllEvents {
    if (self.isMapView) {
        [self.mvController loadAnnotations:[self.evController loadEvents:self.displayDate withEventType:self.eventType Categories:self.userModel.userPreferences]];
    }
    else {
        [self.evController reloadData:[self.evController loadEvents:self.displayDate withEventType:self.eventType Categories:self.userModel.userPreferences]];
    }
}


#pragma mark - MapDelegates
//loads the create screen by pre-loading the location segment based on the long-press location
- (void)longpressCreateEvent:(NSString*)location {
    [self performSegueWithIdentifier:@"createView" sender:location];
}

//displays the directions from current location to the long-pressed location 
- (void)longpressShowRouteDetails:(CLLocationCoordinate2D)location {
    BusRouter *busRoute = [[BusRouter alloc]init];
    [self displayRouteOnMap:[busRoute routeBetweenPoints:self.mvController.mapView.userLocation.coordinate End:location]];
}

#pragma mark - Router Delegate
//directions are currently shown on screen and tapping close brngs it here
- (void)routeClosed {
    for (UIView *thisView in self.routerView.subviews) {
        [thisView removeFromSuperview];
    }
    self.routerView.hidden = YES;
    self.rvController = nil;
}


#pragma mark - Toolbar Controls
//centre the map to the user location
- (IBAction)myLocationButtonPressed:(id)sender {
    [self.mvController goToUserLocation];
}

//toggle the view from mapview to listview
//reload the data in the respective view thats shown
- (IBAction)displayTypeSegmentChanged:(id)sender {
    if (self.displayTypeSegment.selectedSegmentIndex == 0) {
        [self.evController.view removeFromSuperview];
        [self.mapView addSubview:self.mvController.view];
        self.isMapView = YES;
    }
    else {
        [self.mvController.view removeFromSuperview];
        [self.evController setDelegate:self];
        [self.mapView addSubview:self.evController.view];
        [self adjustAllEventView];
        self.isMapView = NO;
    }
    [self reloadAllEvents];
}

//toggle the sidebar - hide when its shown and slide it to screen if it is hidden
//also adjust the map or event lists along with it and animate them all
- (IBAction)sidebarPressed:(id)sender {
    if (self.sideView.hidden == NO) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect sideFrame = self.sideView.frame;
        CGRect slideArrowFrame = self.slideArrow.frame;
        CGRect mapFrame = self.mapView.frame;
        
        if (sideFrame.origin.x >= 0) {
            sideFrame.origin.x = -self.sideView.frame.size.width;
        }
        else {
            sideFrame.origin.x = 0;
        }
        self.sideView.frame = sideFrame;
        slideArrowFrame.origin.x = sideFrame.origin.x + sideFrame.size.width;
        self.slideArrow.frame = slideArrowFrame;
        
        mapFrame.origin.x = slideArrowFrame.origin.x;
        mapFrame.size.width = 1024 - mapFrame.origin.x;
        self.mapView.frame = mapFrame;
        if (!self.isMapView) {
            [self adjustAllEventView];
        }
        
        [UIView commitAnimations];
    }
}

//loads the user popover as soon as the button is pressed or dismisses it if it is already open
- (IBAction)userButtonPressed:(id)sender {
    if ([self.userPopover isPopoverVisible]) {
        [self.userPopover dismissPopoverAnimated:YES];
    }
    else if (self.userPopover != nil) {
        [self.userOptionsController.navigationController popToRootViewControllerAnimated:NO];
        UIBarButtonItem* item = (UIBarButtonItem*)sender;
        self.userPopover.popoverContentSize = self.userOptionsController.navigationController.contentSizeForViewInPopover;
        [self.userPopover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

//push a view controller displaying the interests of the particular user
- (IBAction)settingsButtonPressed:(id)sender {
    self.slideArrow.hidden = YES;
    self.sideView.hidden = YES;
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.userInterestController = [sb instantiateViewControllerWithIdentifier:@"UserInterestView"];
    [self.userInterestController setDelegate:self];
    [self.navigationController pushViewController:self.userInterestController animated:YES];
}

#pragma mark - UserLoginDelegates
//show the login form when the login button is pressed
- (void)ivleLoginPressed {
    self.userLoginController.errorLabel.hidden = YES;
    [self.userOptionsController.navigationController pushViewController:self.userLoginController animated:YES];
}

//change the button titles to Login once the user logs out
- (void)ivleLogoutPressed {
    self.userButton.tintColor = [UIColor colorWithRed:(127.0/255.0f) green:0.0f blue:0.0f alpha:1.0f];
    [self.ivleManager removeUsrToken];
    self.userModel.isLoggedin = NO;
    self.userModel.username = NULL;
    [self.userOptionsController setIvleButtonTitle:@"Login"];
}

//change the button titles to Logout once the user logs in
- (void)userLoggedIn {
    self.userButton.tintColor = [UIColor colorWithRed:0.0f green:(127.0/255.0f) blue:0.0f alpha:1.0f];
    self.userModel.isLoggedin = YES;
    self.userModel.username = [self.ivleManager getUserId];
    [self.userOptionsController setIvleButtonTitle:@"Logout"];
    [self.userLoginController.navigationController popToRootViewControllerAnimated:YES];
}

//set the popover size of the User logins popover whenever a controller is pushed or popped
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController setContentSizeForViewInPopover:viewController.view.frame.size];
}

- (void)userInterestsChanged:(UserModel *)user {
    [self.sfController userInterestsChanged:user.userPreferences];
}

//after the login button has been handled, handle whether its logged-in or logged out
- (void) facebookLoginPressed {
    [self.fbManager buttonClickHandler: ^(id sender){
        [self updateFBLoginBtn];
    }];
}

- (void) updateFBLoginBtn {
    if ([FBManager isSessionOpen]) {
        // valid account UI is shown whenever the session is open
        [self.userOptionsController setFacebookButtonTitle:@"Logout"];
    } else {
        // login-needed account UI is shown whenever the session is closed
        [self.userOptionsController setFacebookButtonTitle:@"Login"];
    }
}


- (void)viewDidUnload {
    [self setMapView:nil];
    [self setSideView:nil];
    [self setSlideArrow:nil];
    [self setFilterView:nil];
    [self setControlToolbar:nil];
    [self setDisplayTypeSegment:nil];
    [self setUserButton:nil];
    [self setMapActivityView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
