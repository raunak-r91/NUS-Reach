
#import "EventCreateViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface EventCreateViewController ()
@property NSString *preVenue;
@property NSArray *inputAccessoryToolbars;
@property LocationPickerViewController* locationPicker;
@property UIPopoverController* locationPickerPopover;
@property CategoryPickerViewController* categoryPicker;
@property UIPopoverController* categoryPickerPopover;
@property KeyboardInputView *customInputView;
@property UITextView *activeView;
@property UITextField *activeField;

@end

@implementation EventCreateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.largestID = [[NSString alloc]init];
        self.view = self.eventCreateView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //load the inputview for textfield and createviews
    [self setupInputviewsForDate];

    self.activeField = [[UITextField alloc]init];
    self.activeView = [[UITextView alloc]init];
    [self loadCreateView];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.preVenue != nil) {
        [self.venueButton setTitle:self.preVenue forState:UIControlStateNormal];
    }
    
}

//Customize the inputview as a keyboard and inputAccessories are a 'Done' & 'Cancel' button
- (void)setupInputviewsForDate {
    self.customInputView = [[KeyboardInputView alloc] initWithFrame:CGRectMake(0, 0, CUSTOM_KEYBOARD_WIDTH, CUSTOM_KEYBOARD_HEIGHT)];
    self.startTimeField.inputView = self.customInputView;
    self.endTimeField.inputView = self.customInputView;
    
    
    UIToolbar *toolBar1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, CUSTOM_KEYBOARD_TOOLBAR_WIDTH, CUSTOM_KEYBOARD_TOOLBAR_HEIGHT)];
    toolBar1.barStyle = UIBarStyleBlack;
    toolBar1.translucent = YES;
    
    UIBarButtonItem *doneButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardConfirm:)];
    UIBarButtonItem *cancelButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(keyboardCancel:)];
    
    [toolBar1 setItems:[NSArray arrayWithObjects:doneButton1,cancelButton1, nil]];
    
    
    UIToolbar *toolBar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CUSTOM_KEYBOARD_TOOLBAR_WIDTH, CUSTOM_KEYBOARD_TOOLBAR_HEIGHT)];
    toolBar2.barStyle = UIBarStyleBlack;
    toolBar2.translucent = YES;
    
    UIBarButtonItem *doneButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardConfirm:)];
    UIBarButtonItem *cancelButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(keyboardCancel:)];
    [toolBar2 setItems:[NSArray arrayWithObjects:doneButton2,cancelButton2, nil]];
    
    self.inputAccessoryToolbars = [[NSArray alloc]initWithObjects:toolBar1, toolBar2, nil];

    self.startTimeField.inputAccessoryView = toolBar1;
    self.endTimeField.inputAccessoryView = toolBar2;
}

- (void)loadCreateView {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss Z"];
    self.targetEvent = [self.delegate getTarget];
    for (UIView *thisSubview in self.eventCreateScrollView.subviews) {
        if([thisSubview.restorationIdentifier isEqualToString:@"nameField"]) {
            ((UITextField*)thisSubview).delegate = self;
            [((UITextField*)thisSubview) setText:self.targetEvent.model.title];
        }
        if([thisSubview.restorationIdentifier isEqualToString:@"venueField"]) {
            //((UIButton*)thisSubview).delegate = self;
            [((UIButton*)thisSubview) setTitle:self.targetEvent.model.venue forState:UIControlStateNormal];
        }
        if([thisSubview.restorationIdentifier isEqualToString:@"categoryField"]) {
            //((UIButton*)thisSubview).delegate = self;
            [((UIButton*)thisSubview) setTitle:self.targetEvent.model.tag forState:UIControlStateNormal];
        }
        if([thisSubview.restorationIdentifier isEqualToString:@"priceField"]) {
            ((UITextField*)thisSubview).delegate = self;
            ((UITextField*)thisSubview).text = self.targetEvent.model.price;
        }
        if([thisSubview.restorationIdentifier isEqualToString:@"startField"]) {
            ((UITextField*)thisSubview).delegate = self;
            ((UITextField*)thisSubview).text = [dateFormatter stringFromDate:self.targetEvent.model.start];
        }
        if([thisSubview.restorationIdentifier isEqualToString:@"endField"]) {
            ((UITextField*)thisSubview).delegate = self;
            ((UITextField*)thisSubview).text = [dateFormatter stringFromDate:self.targetEvent.model.end];
        }
        if([thisSubview.restorationIdentifier isEqualToString:@"descriptionField"]) {
            ((UITextView*)thisSubview).delegate = self;
            ((UITextView*)thisSubview).text = self.targetEvent.model.description;
        }
    }
    if(self.targetEvent != nil && self.targetEvent.model.eventID != nil) {
        [self.saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    }

}

//if the user is not logged in, show a message
- (void)userCreateEvent:(EventViewController*)event {
    IVLEManager *ivleManager = [[IVLEManager alloc]init];
    EventManager *eventManager = [[EventManager alloc] init];
    if ([ivleManager validate]) {
        [eventManager saveCreate:event.model id:[ivleManager getUserId]];
        event.isUserCreated = YES;
        [self.delegate updateEventList];
    } else {
        UIAlertView *loginRequired = [[UIAlertView alloc]initWithTitle:@"SORRY"
                                                       message:@"Please Log-in First"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
        [loginRequired show];
    }
}

- (void)setPredefinedVenue:(NSString *)venue {
    self.preVenue = venue;
}


//These EventViewDelegates are only called for the events created in real at the time
//Once these events are reloaded, these delegates are no longer called and EventViewController
//directly sends a delegate to EventsViewController
#pragma mark - Events View delegates
- (void)editEvent:(EventViewController*)eventController {
    [self.delegate setTarget:eventController];
    [self.delegate editEvent:eventController];
    [self.delegate updateEventList];
}

- (void)shareEvent:(EventViewController*)eventController {
    [self.delegate shareEvent:eventController];
}

- (void)showRouteForLocation:(NSString *)location {
    [self.delegate showRouteForLocation:(NSString*)location];
}

- (IBAction)cancelEventCreate:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
}

//saves the event just created to database by converting each data into a dictionary
//and calling the Database functions
- (IBAction)saveEvent:(id)sender {
    NSString *title = self.titleField.text;
    NSString *venue = self.venueButton.titleLabel.text;
    NSString *price = self.priceField.text;
    int category = PRIVATE_EVENT;
    NSString *tag = self.categoryBtn.titleLabel.text;
    NSDateFormatter *thisDF = [[NSDateFormatter alloc]init];
    [thisDF setDateFormat:@"dd MMM yyyy, hh:mm aa"];
    NSString *startstring = self.startTimeField.text;
    NSString *endString = self.endTimeField.text;
    NSDate *start = [thisDF dateFromString:startstring];
    NSDate *end = [thisDF dateFromString:endString];
    NSString *description = self.descriptionField.text;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:self.largestID];
    myNumber = [NSNumber numberWithInt:[myNumber integerValue] + 1];
    [self.delegate largestId:[myNumber stringValue]];
    EventViewController *eventController = [[EventViewController alloc] initWithTitle:title eventid:[myNumber stringValue] category:category venue:venue start:start end:end price:price description:description organizer:@"" contact:@"" tag:tag delegate:self];
    [eventController save];
    [(NSMutableArray*)[self.delegate getEventControllers] addObject:eventController];
    [self.delegate newEventCreated:eventController];
    [self userCreateEvent:eventController];
    if(self.postIVLEBtn.on) [eventController postToIVLE];
    
    [self dismissModalViewControllerAnimated:YES];
    
    if(self.targetEvent != nil) {
        [self.delegate removeEvent:self.targetEvent];
    }
}

//displays a popover dropdown for the various locations
- (IBAction)displayDropDown:(id)sender {
    if (self.locationPicker == nil) {
        self.locationPicker = [[LocationPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        self.locationPicker.delegate = self;
    }
    
    if (self.locationPickerPopover == nil) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.locationPicker];
        self.locationPickerPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
        UIView* button = (UIView*)sender;
        [self.locationPickerPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self.locationPicker.navigationController popToRootViewControllerAnimated:YES];
        UIView* button = (UIView*)sender;
        [self.locationPickerPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

//displays a popover dropdown for the categories section
- (IBAction)displayCategoriesList:(id)sender {
    if (self.categoryPicker == nil) {
        self.categoryPicker = [[CategoryPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        self.categoryPicker.delegate = self;
    }
    
    if (self.categoryPickerPopover == nil) {
        self.categoryPickerPopover = [[UIPopoverController alloc] initWithContentViewController:self.categoryPicker];
        UIView* button = (UIView*)sender;
        [self.categoryPickerPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        UIView* button = (UIView*)sender;
        [self.categoryPickerPopover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) selectedCategoryWithSubCategories:(NSArray *)subCategories {
    LocationSubCategoryViewController* subCategoryVC = [[LocationSubCategoryViewController alloc] init];
    subCategoryVC.locationSubCategories = subCategories;
    subCategoryVC.delegate = self;
    [self.locationPicker.navigationController pushViewController:subCategoryVC animated:YES];
}

- (void) selectedCategoryWithLocations:(NSArray *)locations {
    LocationSelectViewController* locationsVC = [[LocationSelectViewController alloc] init];
    locationsVC.locationList = locations;
    locationsVC.delegate = self;
    [self.locationPicker.navigationController pushViewController:locationsVC animated:YES];

}

- (void) selectedSubCategoryWithLocations:(NSArray *)locations {
    LocationSelectViewController* locationsVC = [[LocationSelectViewController alloc] init];
    locationsVC.locationList = locations;
    locationsVC.delegate = self;
    [self.locationPicker.navigationController pushViewController:locationsVC animated:YES];
}

- (void)selectedLocation:(NSString *)location {
    [self.venueButton setTitle:location forState:UIControlStateNormal];
    [self.locationPickerPopover dismissPopoverAnimated:YES];
}

-(void)selectedCategory:(NSString *)category {
    [self.categoryBtn setTitle:category forState:UIControlStateNormal];
    [self.categoryPickerPopover dismissPopoverAnimated:YES];
}

//returns the largest event currently in the database
- (NSString*)getLargestEventId {
    NSMutableArray *databaseEvents = [[NSMutableArray alloc]initWithArray:[[[EventManager alloc] init] getEventsFromDatabase]];
    NSNumber *result = 0;
    for(NSDictionary *event in databaseEvents) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * myNumber = [f numberFromString:[event objectForKey:@"eventid"]];
        if ([myNumber intValue] > [result intValue]) {
            result = myNumber;
        }
    }
    result = [NSNumber numberWithInt:[result integerValue] + 1];
    return [result stringValue];
}


//NOTE: these are functions to scroll the view up when a keyboard is popped up
#pragma mark - Custom Keyboard delegates
- (void)keyboardConfirm:(id)sender {
    NSString *text = [self.customInputView getDateAndTime];
    if ([self.activeField isEqual:self.startTimeField]) {
        self.startTimeField.text = text;
    }
    else {
        self.endTimeField.text = text;
    }
    [self hideKeyboard];
}

- (void)keyboardCancel:(id)sender {
    [self hideKeyboard];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)hideKeyboard {
    [[self.view window] endEditing:YES];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    //if the user tapped description textfield, otherwise dont scroll
    if (self.activeView != nil) {
        //scroll the view up by 350 units (especially when description is edited
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.activeView.frame.origin.y, 0.0);
        self.eventCreateScrollView.contentInset = contentInsets;
        self.eventCreateScrollView.scrollIndicatorInsets = contentInsets;
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.eventCreateScrollView.contentInset = contentInsets;
    self.eventCreateScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.activeView = textView;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.activeView.frame.origin.y, 0.0);
    self.eventCreateScrollView.contentInset = contentInsets;
    self.eventCreateScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.activeView = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.eventCreateScrollView.contentInset = contentInsets;
    self.eventCreateScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
