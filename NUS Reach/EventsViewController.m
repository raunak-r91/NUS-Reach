
#import "EventsViewController.h"

@interface EventsViewController ()
@property NSMutableArray *displayListControllers;
@property NSMutableArray *sectionExpand;
@property (nonatomic, readwrite) NSMutableArray *eventControllers;
@property (nonatomic, readonly) EventFilter *eventFilter;
@property (nonatomic, readonly) EventManager *eventManager;
@end

@implementation EventsViewController
@synthesize eventCreate, eventManager, eventControllers, sectionExpand, eventFilter, displayListControllers;

- (id)init {
    eventCreate = [[EventCreateViewController alloc] init]; self.eventCreate.delegate = self;
    eventManager = [[EventManager alloc] initWithIVLE:[[IVLEManager alloc] init]];
    eventFilter = [[EventFilter alloc] init];
    eventControllers = [[NSMutableArray alloc] init];
    displayListControllers = [[NSMutableArray alloc] init];
    sectionExpand = [[NSMutableArray alloc] initWithObjects:@"open", @"open", @"open", nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"AllEventsView" owner:self options:nil];
    self.view = [subviewArray objectAtIndex:0];
    self.eventsListView.layer.borderWidth = 0.5;
    self.eventsListView.delegate = self;
    self.eventsListView.dataSource = self;
    [self.eventsListView setBackgroundColor:[UIColor colorWithRed:EVENT_LISTVIEW_BACKGROUND_COLOR_GRAY green:EVENT_LISTVIEW_BACKGROUND_COLOR_GRAY blue:EVENT_LISTVIEW_BACKGROUND_COLOR_GRAY alpha:EVENT_LISTVIEW_BACKGROUND_ALPHA]];
    self.eventsListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self updateEventList];
}

- (NSArray*)getUserCreateEvents:(NSArray*)events {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(EventViewController* event in events) {
        if(event.isUserCreated) {
            [result addObject:event];
        }
    }
    return result;
}

- (NSArray*)getUserAttendEvents:(NSArray*)events {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(EventViewController* event in events) {
        if(event.isUserAttending) {
            [result addObject:event];
        }
    }
    return result;
}

#pragma mark EventCreateViewDelegate

- (void)newEventCreated:(EventViewController*)newEventController {
    [self.delegate newEventCreated:newEventController];
}

- (void)largestId:(NSString*)currentID {
    [self.delegate largestId:currentID];
}

- (void)setLargestID:(NSString*)ID {
    [self.delegate largestId:ID];
}

- (NSArray*)getEventControllers {
    return [self.delegate getEventControllers];
}

- (EventViewController*)getTarget {
    return [self.delegate getTarget];
}

- (void)setTarget:(EventViewController *)event {
    [self.delegate setTarget:event];
}

- (void)editEvent:(EventViewController *)event {
    [(UIViewController*)self.delegate performSegueWithIdentifier:@"createView" sender:self];
}

- (void)shareEvent:(EventViewController *)event {
    [self.delegate shareEvent:event];
}

- (void)showRouteForLocation:(NSString*)location {
    [self.delegate showRouteForEvent:(NSString*)location];
}

- (void)removeEvent:(EventViewController*)event {
    [self.eventControllers removeObject:event];
    [eventManager remove:self.targetEvent.model];
    [self updateEventList];
}

#pragma mark UITableViewDelegate

- (void)reloadData:(NSArray*)newEvents {
    displayListControllers = [NSMutableArray arrayWithArray:newEvents];
    [self.eventsListView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return EVENT_LISTVIEW_SECTION_ATTEND;
    else if(section == 1) return EVENT_LISTVIEW_SECTION_CREATE;
    else return EVENT_LISTVIEW_SECTION_ALL;
}

//Customize appearance of headers in List View
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, self.eventsListView.frame.size.width, 20.0f);
    
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.frame = headerView.frame;
    gradient.colors = @[
                        (id)[UIColor colorWithRed:EVENT_LISTVIEW_HEADER_GRAY1 green:EVENT_LISTVIEW_HEADER_GRAY1 blue:EVENT_LISTVIEW_HEADER_GRAY1 alpha:1.0f].CGColor,
                        (id)[UIColor colorWithRed:EVENT_LISTVIEW_HEADER_GRAY2 green:EVENT_LISTVIEW_HEADER_GRAY2 blue:EVENT_LISTVIEW_HEADER_GRAY2 alpha:1.0f].CGColor,
                        ];
    [headerView.layer insertSublayer:gradient atIndex:0];

    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, EVENT_LISTVIEW_HEADER_LABEL_WIDTH, EVENT_LISTVIEW_HEADER_LABEL_HEIGHT)];
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    label.text = sectionTitle;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.textColor = [UIColor colorWithRed:EVENT_LISTVIEW_LIGHTGRAY green:EVENT_LISTVIEW_LIGHTGRAY blue:EVENT_LISTVIEW_LIGHTGRAY alpha:1.0f];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize]*0.9f)];
    label.shadowColor = [UIColor clearColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.numberOfLines = 0;
    
    [headerView addSubview:label];
    
    if([sectionExpand[section] isEqualToString:@"closed"]) {
        UIImageView* rightView = [UIImageView imageViewWithImageNamed:@"header_expand.png"];
        rightView.frame = CGRectMake(EVENT_LISTVIEW_HEADER_IMAGE_X, 0.0f, rightView.frame.size.width, rightView.frame.size.height);
        [headerView addSubview:rightView];
    }
    else {
        UIImageView* bottomView = [UIImageView imageViewWithImageNamed:@"header_collapse.png"];
        bottomView.frame = CGRectMake(EVENT_LISTVIEW_HEADER_IMAGE_X, 0.0f, bottomView.frame.size.width, bottomView.frame.size.height);
        [headerView addSubview:bottomView];
    }
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventHeaderTap:)];
    headerView.tag = section;
    [tap setNumberOfTapsRequired:1];
    [headerView addGestureRecognizer:tap];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *userCreatedEvents = [self getUserCreateEvents:displayListControllers];
    NSArray *userAttendEvents = [self getUserAttendEvents:displayListControllers];
    if([sectionExpand[section] isEqualToString:@"closed"]) return 0;
    if(section == 0) return [userAttendEvents count];
    else if(section == 1) return [userCreatedEvents count];
    else {
        return displayListControllers.count;
    }
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger tag = indexPath.row*10+indexPath.section;
    [self eventCellTap:tag];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

//Customize appearance of cells in List View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EventTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell = [self formatCell:cell atIndexPath:indexPath];
    }
    EventViewController *eventController;
    switch (indexPath.section) {
        case 0:
            eventController = [[self getUserAttendEvents:displayListControllers] objectAtIndex:indexPath.row];
            break;
        case 1:
            eventController = [[self getUserCreateEvents:displayListControllers] objectAtIndex:indexPath.row];
            break;
        case 2:
            eventController = [displayListControllers objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    cell.textLabel.text = eventController.model.title;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@\n%@",eventController.model.venue, eventController.model.start];
    return cell;
}

//Helper method to format the appearance of the cell
- (UITableViewCell*)formatCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithRed:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY green:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY blue:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY alpha:1.0f];
    cell.selectedBackgroundView = bgView;
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont systemFontSize]];
    cell.textLabel.textColor = [UIColor colorWithRed:EVENT_LISTVIEW_CELL_TEXT_GRAY green:EVENT_LISTVIEW_CELL_TEXT_GRAY blue:EVENT_LISTVIEW_CELL_TEXT_GRAY alpha:1.0f];
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:([UIFont systemFontSize] * 0.8f)];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:EVENT_LISTVIEW_CELL_DETAIL_GRAY green:EVENT_LISTVIEW_CELL_DETAIL_GRAY blue:EVENT_LISTVIEW_CELL_DETAIL_GRAY alpha:1.0f];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.eventsListView.frame.size.width, 1.0f)];
    topLine.backgroundColor = [UIColor colorWithRed:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY green:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY blue:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY alpha:1.0f];
    [cell.textLabel.superview addSubview:topLine];

    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, self.eventsListView.frame.size.width, 1.0f)];
    bottomLine.backgroundColor = [UIColor colorWithRed:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY green:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY blue:EVENT_LISTVIEW_CELL_BACKGROUND_GRAY alpha:1.0f];
    [cell.textLabel.superview addSubview:bottomLine];

    
    return cell;
    
}

- (EventViewController*)getEventFromTag:(int)tag {
    EventViewController *eventController;
    int section = tag%10;
    int row = tag/10;
    if(section == 0) {
        eventController = [[self getUserAttendEvents:displayListControllers] objectAtIndex:row];
    } else if(section == 1) {
        eventController = [[self getUserCreateEvents:displayListControllers] objectAtIndex:row];
    } else {
        eventController = [displayListControllers objectAtIndex:row];
    }
    return eventController;
}

- (void)eventHeaderTap:(UITapGestureRecognizer *)sender {
    if([sectionExpand[sender.view.tag] isEqualToString:@"open"]) {
        sectionExpand[sender.view.tag] = @"closed";
    }
    else {
        sectionExpand[sender.view.tag] = @"open";
    }
    [self.eventsListView reloadData];
}

//Show Detail View when Cell is tapped
- (void)eventCellTap:(NSInteger)tag {
    self.eventListEditBtn.tag = tag;
    self.eventListAttendBtn.tag = tag;
    self.eventListFbBtn.tag = tag;
    EventViewController *eventController = [self getEventFromTag:tag];
    eventController.detailView.frame = CGRectMake(0, 0, EVENT_DETAIL_VIEW_WIDTH, EVENT_DETAIL_VIEW_HEIGHT);
    self.eventListEditBtn.enabled = eventController.isUserCreated;
    if(eventController.isUserAttending) {
        [self.eventListAttendBtn setTitle:@"Unattend"];
    } else {
        [self.eventListAttendBtn setTitle:@"Attend"];
    }
    if(eventController.isUserCreated) {
        [self.eventListAttendBtn setTitle:@"Delete"];
    }
    eventController.detailView.editBtn.hidden = YES;
    eventController.detailView.attendBtn.hidden = YES;
    eventController.detailView.routeBtn.hidden = YES;
    eventController.detailView.fbBtn.hidden = YES;
    for (UIView *view in self.eventDetailView.subviews) {
        if(![view isKindOfClass:[UIToolbar class]]) {
            [view removeFromSuperview];
        }
    }
    [self.eventDetailView addSubview: eventController.detailView];
    [self.eventDetailView bringSubviewToFront:eventController.detailView];
}

//Load all events from IVLE
- (void)loadFromIVLE:(NSArray*)attendingList :(NSArray*)createdList {
    NSMutableArray *ivleEvents = [[NSMutableArray alloc]initWithArray:[eventManager getEventsFromIVLE]];
    for(NSDictionary *event in ivleEvents) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss Z"];
        NSString *title = [event objectForKey:@"title"];
        NSString *eventID = [event objectForKey:@"eventid"];
        NSArray *tokens = [eventID componentsSeparatedByString:@"="];
		eventID = [tokens objectAtIndex:1];
        
        int category = OFFICIAL_EVENT;
        NSString *venue = [event objectForKey:@"venue"];
        NSDate *start = [dateFormatter dateFromString:[event objectForKey:@"eventdate"]];
        NSDate *end = [dateFormatter dateFromString:[event objectForKey:@"eventdate"]];
        
        NSString *price = @"-";
        NSString *description = [event objectForKey:@"description"];
        
        NSString *organizer = @"NUS IVLE";
        NSString *contact = @"NUS IVLE";
        NSString *tag = [event objectForKey:@"tag"]; // IVLE EVENT category
        EventViewController *eventController = [[EventViewController alloc] initWithTitle:title eventid:eventID category:category venue:venue start:start end:end price:price description:description organizer:organizer contact:contact tag:tag delegate:self];
        if ([attendingList containsObject:eventID]) {
            eventController.isUserAttending = YES;
            [eventController.detailView.attendBtn setTitle:@"Unattend" forState:UIControlStateNormal];
        } else if(![attendingList containsObject:eventID]) {
            eventController.isUserAttending = NO;
            [eventController.detailView.attendBtn setTitle:@"Attend" forState:UIControlStateNormal];
        }
        if ([createdList containsObject:eventID]) {
            eventController.isUserCreated = YES;
            eventController.detailView.editBtn.hidden = NO;
            eventController.detailView.attendBtn.hidden = YES;
        } else if(![createdList containsObject:eventID]) {
            eventController.isUserCreated = NO;
            eventController.detailView.editBtn.hidden = YES;
            eventController.detailView.attendBtn.hidden = NO;
        }
        [eventControllers addObject:eventController];
    }
}

//Load all events from the database
- (void)loadFromDatabase:(NSArray*)attendingList :(NSArray*)createdList {
    NSMutableArray *databaseEvents = [[NSMutableArray alloc]initWithArray:[eventManager getEventsFromDatabase]];
    for(NSDictionary *event in databaseEvents) {
        NSString *title = [event objectForKey:@"title"];
        NSString *eventID = [event objectForKey:@"eventid"];
        int category = PRIVATE_EVENT;
        NSString *venue = [event objectForKey:@"venue"];
        NSDate *start = (NSDate*)[event objectForKey:@"start"];
        NSDate *end = (NSDate*)[event objectForKey:@"end"];
        NSString *price = [event objectForKey:@"price"];
        NSString *description = [event objectForKey:@"description"];
        NSString *organizer = [event objectForKey:@"organizer"];
        NSString *contact = [event objectForKey:@"contact"];
        NSString *tag = [event objectForKey:@"tag"];
        EventViewController *eventController = [[EventViewController alloc] initWithTitle:title eventid:eventID category:category venue:venue start:start end:end price:price description:description organizer:organizer contact:contact tag:tag delegate:self];
        if ([attendingList containsObject:eventID]) {
            eventController.isUserAttending = YES;
            [eventController.detailView.attendBtn setTitle:@"Unattend" forState:UIControlStateNormal];
        } else if(![attendingList containsObject:eventID]) {
            eventController.isUserAttending = NO;
            [eventController.detailView.attendBtn setTitle:@"Attend" forState:UIControlStateNormal];
        }
        if ([createdList containsObject:eventID]) {
            eventController.isUserCreated = YES;
            eventController.detailView.editBtn.hidden = NO;
            eventController.detailView.attendBtn.hidden = YES;
        } else if(![createdList containsObject:eventID]) {
            eventController.isUserCreated = NO;
            eventController.detailView.editBtn.hidden = YES;
            eventController.detailView.attendBtn.hidden = NO;
        }
        [eventControllers addObject:eventController];
        [self.delegate largestId:eventID];
    }
}

- (void)loadAllEventsForUser:(NSArray*)attendingList :(NSArray*)createdList {
    [self loadFromIVLE:attendingList :createdList];
    [self loadFromDatabase:attendingList :createdList];
}

//Apply filters to the loaded events
- (NSArray*)loadEvents:(NSDictionary*)date withEventType:(eventCategory)eventType Categories:(NSArray*)categories {
    EventFilter *newFilter = [[EventFilter alloc]init];

    BOOL loadIVLEEvents = (eventType == kOfficialEvent || eventType == kBothEvent)? YES: NO;
    BOOL loadPrivateEvents = (eventType == kPrivateEvent || eventType == kBothEvent)? YES: NO;
    NSMutableArray *filteredEvents = [[NSMutableArray alloc]init];
    
    NSMutableArray *dates = [[NSMutableArray alloc]init];
    NSString *tempDate = [date objectForKey:@"Start Date"];
    if (tempDate != nil) {
        [dates addObject:tempDate];
    }
    tempDate = [date objectForKey:@"End Date"];
    if (tempDate != nil) {
        [dates addObject:tempDate];
    }
    
    if (loadIVLEEvents) {
        [newFilter setCategory:1 price:@"" date:dates tag:categories];
        [filteredEvents addObjectsFromArray:[newFilter filter:self.eventControllers]];
    }
    if (loadPrivateEvents) {
        [newFilter setCategory:0 price:@"" date:dates tag:categories];
        [filteredEvents addObjectsFromArray:[newFilter filter:self.eventControllers]];
    }
    return filteredEvents;
}

#pragma mark - Event View Delegate
- (void)updateEventList {
    [self.eventsListView reloadData];
}

- (IBAction)editEventList:(id)sender {
    NSArray *events = displayListControllers;
    if(events.count > 0) {
        EventViewController *eventController = [self getEventFromTag:self.eventListEditBtn.tag];
        [self setTarget:eventController];
        [(UIViewController*)self.delegate performSegueWithIdentifier:@"createView" sender:self];
    }
}

- (IBAction)attendEventList:(id)sender {
    NSArray *events = displayListControllers;
    if(events.count > 0) {
        if(![self.eventListAttendBtn.title isEqualToString:@"Delete"]) {
            EventViewController *eventController = [self getEventFromTag:self.eventListAttendBtn.tag];
            if(eventController != nil)
                [eventController attendEvent];
            if([self.eventListAttendBtn.title isEqualToString:@"Attend"]) {
                self.eventListAttendBtn.title = @"Unattend";
            }
            else {
                self.eventListAttendBtn.title = @"Attend";
            }
        }
        else {
            EventViewController *eventController = [self getEventFromTag:self.eventListAttendBtn.tag];
            if(eventController != nil) {
                [self removeEvent:eventController];
            }
        }
    }
    [self updateEventList];
}

- (IBAction)shareEventList:(id)sender {
    NSArray *events = displayListControllers;
    if(events.count > 0) {
        EventViewController *eventController = [self getEventFromTag:self.eventListFbBtn.tag];
        [self.delegate shareEvent:eventController];
    }
}

//Returns the Event models for all the displayed events
- (NSArray*)getEventAnnotationModels {
    NSMutableArray *allDisplayEventModels = [[NSMutableArray alloc]init];
    for (EventViewController *eventController in self.eventControllers){
        [allDisplayEventModels addObject:eventController.model];
    }
    
    return allDisplayEventModels;
}

- (void)viewDidUnload {
    [self setEventsListView:nil];
    [self setEventDetailView:nil];
    [self setEventListEditBtn:nil];
    [self setEventListAttendBtn:nil];
    [self setEventListFbBtn:nil];
    [super viewDidUnload];
}


@end
