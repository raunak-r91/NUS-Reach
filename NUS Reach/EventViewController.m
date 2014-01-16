
#import "EventViewController.h"

@interface EventViewController ()
@property UIAlertView *loginRequired;
@property (nonatomic) EventManager *eventManager;
@end

@implementation EventViewController
@synthesize eventManager, model, detailView;

- (id)initWithModel:(EventModel*)m delegate:(id)delegate {
    if(self = [super init]) {
        model = m;
        eventManager = [[EventManager alloc] initWithIVLE:[[IVLEManager alloc] init]];
        //TODO: update view position and text
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm"];
        NSString *time = [dateFormatter stringFromDate:model.start];
        detailView = [[EventDetailView alloc] initWithWidth:EVENT_DETAIL_VIEW_WIDTH height:EVENT_DETAIL_VIEW_HEIGHT title:model.title venue:model.venue time:time price:model.price category:model.tag organizer:model.organizer contact:model.contact description:model.description];

        detailView.delegate = self;
        self.isUserAttending = NO;
        self.isUserCreated = NO;
        self.delegate = delegate;
    }
    return self;
}


- (id)initWithTitle:(NSString*)title eventid:(NSString*)eventID category:(int)c venue:(NSString*)v start:(NSDate*)s end:(NSDate*)e price:(NSString*)p description:(NSString*)d organizer:(NSString*)organizer contact:(NSString*)contact tag:(NSString*)tag delegate:(id)delegate {
    model = [[EventModel alloc] initWithTitle:title eventid:eventID category:c venue:v start:s end:e price:p description:d organizer:organizer contact:contact tag:tag];
    self = [self initWithModel:model delegate:delegate];
    _isUserAttending = NO;
    _isUserCreated = NO;
    self.delegate = delegate;
    return self;
}

- (void)setIsUserAttending:(BOOL)isUserAttending {
    _isUserAttending = isUserAttending;
    if (isUserAttending) {
        [self.detailView userAttending];
    }
}

- (void)setIsUserCreated:(BOOL)isUserCreated {
    _isUserCreated = isUserCreated;
}

- (void)save {
    // EFFECTS: save event to database
    [eventManager save:model];
}

- (void)postToIVLE {
    [eventManager postToIVLE:model];
}

#pragma mark - Detail View Delegate

- (void)attendEvent {
    NSString *attendBtnTitle = [self.detailView.attendBtn titleForState:UIControlStateNormal];
    IVLEManager *tempManager = [[IVLEManager alloc]init];
    if([attendBtnTitle isEqualToString:@"Attend"]) {
        if ([tempManager validate]) {
            [eventManager saveAttend:model id:[tempManager getUserId]];
            [self.detailView.attendBtn setTitle:@"Unattend" forState:UIControlStateNormal];
            [[CalendarManager defaultCalendar] addEventWithTitle:self.model.title startDate:self.model.start endDate:self.model.end location:self.model.venue description:self.model.description eventID:self.model.eventID];
            self.isUserAttending = YES;
        }
        else {
            self.loginRequired = [[UIAlertView alloc]initWithTitle:@"SORRY"
                                                           message:@"Please Log-in First"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
            [self.loginRequired show];
        }
    } else {
        [self.detailView.attendBtn setTitle:@"Attend" forState:UIControlStateNormal];
        self.isUserAttending = NO;
        [eventManager removeAttend:model id:[tempManager getUserId]];
        [[CalendarManager defaultCalendar] removeEventWithEventID:self.model.eventID];
    }
}


- (void)editEvent {
    [self.delegate editEvent:self];
}

- (void)showRoute {
    [self.delegate showRouteForLocation:self.model.venue];
}

- (void)shareEvent {
    [self.delegate shareEvent:self];
}

- (void)viewDidUnload {
    [self setDetailView:nil];
    [super viewDidUnload];
}
@end
