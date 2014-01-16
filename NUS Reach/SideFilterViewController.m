
#import "SideFilterViewController.h"

@interface SideFilterViewController ()
@property NSArray *allFilters;
@property NSArray *eventTypes;
@property CGRect tableFrame;
@property DateFilterType dateFilterApplied;
@property NSMutableDictionary* selectedDate;
@property TKCalendarMonthViewController *tkController;
@property UIPopoverController *calendarPopover;
@property UISegmentedControl* dateFilter;
@end

@implementation SideFilterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView setBackgroundView:nil];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        self.tableView.allowsMultipleSelection = YES;
        self.tableView.scrollEnabled = NO;
        self.eventType = kOfficialEvent;
        self.dateFilterApplied = kAllFilter;
        self.selectedDate = [NSMutableDictionary dictionary];

    }
    return self;
}

- (void)setTablesFrame: (CGRect)thisTableFrame {
    self.tableFrame = thisTableFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allFilters = [[NSArray alloc]initWithObjects:@"Arts", @"Conferences", @"Exhibitions", @"Health", @"Workshops", @"Social Events", @"Sports", @"Others", nil];
    self.eventTypes = [[NSArray alloc]initWithObjects:@"Official Events", @"Private Events", nil];
    self.tableView.frame = self.tableFrame;
    self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // There are three sections, for date, type, and tags, in that order.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 2;
            break;
        case 1:
            // For genre and date there is just one row.
            rows = [self.eventTypes count];
            break;
        case 2:
            // For the characters section, there are as many rows as there are characters.
            rows = [self.allFilters count];
            break;
        default:
            break;
    }
    return rows;
}

//Control the appearance and behavior of individual cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [self formatCell:cell atIndexPath:(NSIndexPath*)indexPath];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *cellText = nil;

    switch (indexPath.section) {
        case 0:
            if(indexPath.row == 0) {
                //Add Segment control for date filters
                self.dateFilter = [[UISegmentedControl alloc] initWithItems:@[SIDEVIEW_SEGMENT_ITEM_0, SIDEVIEW_SEGMENT_ITEM_1, SIDEVIEW_SEGMENT_ITEM_2]];
                self.dateFilter.segmentedControlStyle = UISegmentedControlStyleBar;
                self.dateFilter.selectedSegmentIndex = 2;
                [self.dateFilter addTarget:self action:@selector(dateFilterChanged:) forControlEvents:UIControlEventValueChanged];
                [self.dateFilter setFrame:CGRectMake(SIDEVIEW_SEGMENT_X, SIDEVIEW_SEGMENT_Y, self.dateFilter.frame.size.width, self.dateFilter.frame.size.height)];
                [cell addSubview:self.dateFilter];
            }
            else {
                cellText = SIDEVIEW_SEGMENT_ITEM_2;
            }
            break;
        case 1:
            cellText = [self.eventTypes objectAtIndex:indexPath.row];
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
            break;
        case 2:
            cellText = [self.allFilters objectAtIndex:indexPath.row];
            for (NSString *thisPreference in self.selectedPreferences) {
                if ([thisPreference rangeOfString:cellText].location != NSNotFound) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
            }
            if ([self.selectedPreferences count] == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
            break;
        default:
            break;
    }
    if (cellText != nil) {
        cell.textLabel.text = cellText;
    }
    return cell;
}

//Controls user interaction with the date filters
- (void)dateFilterChanged:(id)sender {
    UITableViewCell* thisCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    [self removeSubviewsFromCell:thisCell];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    int type = [self.dateFilter selectedSegmentIndex];
    switch (type) {
        case kDateFilter:
            [dateFormatter setDateFormat:@"dd MMM yyyy"];
            thisCell.textLabel.text = [dateFormatter stringFromDate:[NSDate date]];
            self.dateFilterApplied = kDateFilter;
            [self.selectedDate setObject:[NSDate date] forKey:@"Start Date"];
            [self.selectedDate removeObjectForKey:@"End Date"];
            break;
        case kWeekFilter:
            thisCell.textLabel.text = [self getWeekLabelFromDate:[NSDate date]];
            self.dateFilterApplied = kWeekFilter;
            [self addSubviewForWeekFilter:thisCell];
            break;
        case kAllFilter:
            thisCell.textLabel.text = @"All Events";
            self.dateFilterApplied = kAllFilter;
            [self.selectedDate removeObjectForKey:@"Start Date"];
            [self.selectedDate removeObjectForKey:@"End Date"];
            break;
        default:
            break;
    }
    [self.delegate dateModified:self.selectedDate];

}

//Helper method to format the cells in the sidebar
- (UITableViewCell*)formatCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithRed:SIDEVIEW_SELECTED_BACKGROUND_GRAY green:SIDEVIEW_SELECTED_BACKGROUND_GRAY blue:SIDEVIEW_SELECTED_BACKGROUND_GRAY alpha:1.0f];
    cell.selectedBackgroundView = bgView;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:([UIFont systemFontSize] * 1.2f)];
    cell.textLabel.textColor = [UIColor colorWithRed:SIDEVIEW_SELECTED_TEXT_GRAY green:SIDEVIEW_SELECTED_TEXT_GRAY blue:SIDEVIEW_SELECTED_TEXT_GRAY alpha:1.0f];
    if (indexPath.section == 0) {
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (!(indexPath.section == 0 && indexPath.row == 1)) {
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 1.0f)];
        topLine.backgroundColor = [UIColor colorWithRed:SIDEVIEW_CELL_BORDER_GRAY green:SIDEVIEW_CELL_BORDER_GRAY blue:SIDEVIEW_CELL_BORDER_GRAY alpha:0.9f];
        [cell.textLabel.superview addSubview:topLine];
    }
        
    if (!(indexPath.section == 0 && indexPath.row == 0)) {
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, self.tableView.frame.size.width, 1.0f)];
        bottomLine.backgroundColor = [UIColor colorWithRed:SIDEVIEW_CELL_BORDER_GRAY green:SIDEVIEW_CELL_BORDER_GRAY blue:SIDEVIEW_CELL_BORDER_GRAY alpha:0.9f];
        [cell.textLabel.superview addSubview:bottomLine];

    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"official.png"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"student.png"];
        }
    }
    else if (indexPath.section == 2) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Categories_Images" ofType:@"plist"];
        NSDictionary* images = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSString* imageName = [images objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        cell.imageView.image = [UIImage imageNamed:imageName];
    }
    return cell;
}

#pragma mark TableView Header Delegates

//Set Title for sections
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    switch (section) {
        case 0:
            title = NSLocalizedString(SIDEVIEW_DATEFILTER_TITLE, @"Date section title");
            break;
        case 1:
            title = NSLocalizedString(SIDEVIEW_TYPEFILTER_TITLE, @"Event Type section title");
            break;
        case 2:
            title = NSLocalizedString(SIDEVIEW_CATEGORYFILTER_TITLE ,@"Filters section title");
            break;
        default:
            break;
    }
    return title;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.superview.frame.size.width, 21.0f)];
    
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.frame = headerView.bounds;
    gradient.colors = @[
                        (id)[UIColor colorWithRed:SIDEVIEW_HEADER_GRAY1 green:SIDEVIEW_HEADER_GRAY1 blue:SIDEVIEW_HEADER_GRAY1 alpha:1.0f].CGColor,
                        (id)[UIColor colorWithRed:SIDEVIEW_HEADER_GRAY2 green:SIDEVIEW_HEADER_GRAY2 blue:SIDEVIEW_HEADER_GRAY2 alpha:1.0f].CGColor,
                        ];
    [headerView.layer insertSublayer:gradient atIndex:0];
    
    
    // Add the label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, SIDEVIEW_HEADER_LABEL_WIDTH, SIDEVIEW_HEADER_LABEL_HEIGHT)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.text = sectionTitle;
    headerLabel.textColor = [UIColor colorWithRed:SIDEVIEW_HEADER_LABEL_GRAY green:SIDEVIEW_HEADER_LABEL_GRAY blue:SIDEVIEW_HEADER_LABEL_GRAY alpha:1.0f];
    
    //custom font
    headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize]*0.9f)];
    
    headerLabel.shadowColor = [UIColor clearColor];
    headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    headerLabel.numberOfLines = 0;
    [headerView addSubview: headerLabel];
    
    // Return the headerView
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 21.0f;
}

#pragma mark TableView Selection

//Control cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    if (indexPath.section == 0 && indexPath.row == 1 && self.dateFilterApplied == kDateFilter) {
        if (![self.calendarPopover isPopoverVisible]) {
            [self showCalendarPopover:cell];
        }
        else {
            [self.calendarPopover dismissPopoverAnimated:YES];
        }
    }
    else if (indexPath.section == 1) {
        [self toggleEventType:cell ForRow:indexPath.row];
    }
    else if (indexPath.section == 2) {
        [self togglePreferences:cell];
    }
}

//Control cell deselection
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    if (indexPath.section == 0 && indexPath.row == 1 && self.dateFilterApplied == kDateFilter) {
        if (![self.calendarPopover isPopoverVisible]) {
            [self showCalendarPopover:cell];
        }
        else {
            [self.calendarPopover dismissPopoverAnimated:YES];
        }
    }
    else if (indexPath.section == 1) {
        [self toggleEventType:cell ForRow:indexPath.row];
    }
    else if (indexPath.section == 2) {
        [self togglePreferences:cell];
    }
    
}

//Handle category filter modifications
- (void)togglePreferences:(UITableViewCell*)cell {
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        //If cell is not selected, add it
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSMutableArray* tempCopy = [NSMutableArray arrayWithArray:self.selectedPreferences];
        [tempCopy addObject:cell.textLabel.text];
        self.selectedPreferences = [NSArray arrayWithArray:tempCopy];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSString *objectToRemove = [[NSString alloc]init];
        for (NSString *thisPreference in self.selectedPreferences) {
            if ([thisPreference rangeOfString:cell.textLabel.text].location != NSNotFound) {
                objectToRemove = thisPreference;
                break;
            }
        }
        NSMutableArray* tempCopy = [NSMutableArray arrayWithArray:self.selectedPreferences];
        [tempCopy removeObject:objectToRemove];
        self.selectedPreferences = [NSArray arrayWithArray:tempCopy];
    }
    
    //If the user removes all filters then readd them
    if ([self.selectedPreferences count] == 0) {
        for (int i = 0; i < [self.allFilters count]; i ++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:2]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:2] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        self.selectedPreferences = [NSArray arrayWithArray: self.allFilters];
    }
    
    [self.delegate filtersModified:self.selectedPreferences];
}

//Handle Type filter modifications
- (void)toggleEventType:(UITableViewCell*)cell ForRow:(int)row {
    if (cell.selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.eventType = kBothEvent;
        [self.delegate eventTypeAdded];
    }
    else {
        if (self.eventType != kBothEvent) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (row == 0) {
                self.eventType = kPrivateEvent;
                [self.delegate eventTypeRemovedWithSelectedEvent:self.eventType];
            }
            else if (row == 1) {
                self.eventType = kOfficialEvent;
                [self.delegate eventTypeRemovedWithSelectedEvent:self.eventType];
            }
        }
    }
    return;
}

#pragma mark Week Filters
//Handle change of week
- (void)rightArrowPressed:(id)sender {
    UITableViewCell *thisCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM"];
    
    NSDate *fromDate = [self.selectedDate objectForKey:@"End Date"];
    NSDate *endDate = [NSDate dateWithTimeInterval:(7*24*60*60) sinceDate:fromDate]; //Get date of 7 days laer
    NSString* cellText = [dateFormatter stringFromDate:fromDate];
    cellText = [cellText stringByAppendingString:@" - "];
    cellText = [cellText stringByAppendingString:[dateFormatter stringFromDate:endDate]];
    thisCell.textLabel.text = cellText;
    [self.selectedDate setObject:fromDate forKey:@"Start Date"];
    [self.selectedDate setObject:endDate forKey:@"End Date"];
    [self.delegate dateModified:self.selectedDate];
}

- (void)leftArrowPressed:(id)sender {
    UITableViewCell *thisCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM"];
    
    NSDate *endDate = [self.selectedDate objectForKey:@"Start Date"];
    if ([endDate compare:[NSDate date]] == NSOrderedDescending) {
        NSDate* fromDate = [NSDate dateWithTimeInterval:(-7*24*60*60) sinceDate: endDate];
        NSString* cellText = [dateFormatter stringFromDate:fromDate];
        cellText = [cellText stringByAppendingString:@" - "];
        cellText = [cellText stringByAppendingString:[dateFormatter stringFromDate:endDate]];
        thisCell.textLabel.text = cellText;
        [self.selectedDate setObject:fromDate forKey:@"Start Date"];
        [self.selectedDate setObject:endDate forKey:@"End Date"];
        [self.delegate dateModified:self.selectedDate];
    }
}

- (NSString*)getWeekLabelFromDate:(NSDate*)startDate {
    NSDate* endDate = [NSDate dateWithTimeInterval:(7*24*60*60) sinceDate:startDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM"];
    NSString* cellText = [dateFormatter stringFromDate:startDate];
    cellText = [cellText stringByAppendingString:@" - "];
    cellText = [cellText stringByAppendingString:[dateFormatter stringFromDate:endDate]];
    [self.selectedDate setObject:startDate forKey:@"Start Date"];
    [self.selectedDate setObject:endDate forKey:@"End Date"];
    return cellText;
}

- (void)addSubviewForWeekFilter:(UITableViewCell*)thisCell {
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* rightArrowImage = [UIImage imageNamed:@"arrow_right.png"];
    [rightButton setImage:rightArrowImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightArrowPressed:) forControlEvents:UIControlEventTouchDown];
    rightButton.frame = CGRectMake(SIDEVIEW_WEEKFILTER_RIGHTARROW_X, SIDEVIEW_WEEKFILTER_RIGHTARROW_Y, SIDEVIEW_WEEKFILTER_ARROW_SIZE, SIDEVIEW_WEEKFILTER_ARROW_SIZE);
    rightButton.tag = 2;
    [thisCell addSubview:rightButton];
    
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* leftArrowImage = [UIImage imageNamed:@"arrow_left.png"];
    [leftButton setImage:leftArrowImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftArrowPressed:) forControlEvents:UIControlEventTouchDown];
    leftButton.frame = CGRectMake(SIDEVIEW_WEEKFILTER_LEFTARROW_X, SIDEVIEW_WEEKFILTER_LEFTARROW_Y, SIDEVIEW_WEEKFILTER_ARROW_SIZE, SIDEVIEW_WEEKFILTER_ARROW_SIZE);
    leftButton.tag = 3;
    [thisCell addSubview:leftButton];
}

#pragma mark TapkuCalendar 

//Display Tapku Calendar when user chooses to edit date
- (void)showCalendarPopover:(UITableViewCell*)cell {
    self.tkController = [[TKCalendarMonthViewController alloc]initWithSunday:YES];
    [self.tkController loadView];
    self.tkController.monthView.delegate = self;
    [self.tkController.monthView selectDate:[self.selectedDate objectForKey:@"Start Date"]];
    self.calendarPopover = [[UIPopoverController alloc]initWithContentViewController:self.tkController];
    [self.calendarPopover presentPopoverFromRect:cell.frame inView:self.tableView.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [self adjustPopoverSize:[NSDate date]];
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date {
    UITableViewCell *thisCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    NSString *text = [dateFormatter stringFromDate:date];
    
    if (![thisCell.textLabel.text isEqualToString:text]) {
        thisCell.textLabel.text = text;
        [self.selectedDate setObject:date forKey:@"Start Date"];
        [self.delegate dateModified:self.selectedDate];
    }
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthWillChange:(NSDate *)month animated:(BOOL)animated {
    [self adjustPopoverSize:month];
}

- (void)adjustPopoverSize:(NSDate*)date {
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSRange weekRange = [calender rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSInteger weeksCount=weekRange.length;
    CGFloat height = 0;
    BOOL animated = NO;
    if (weeksCount == 5) {
        height = 265;
    }
    else if (weeksCount == 6) {
        height = 305;
        animated = YES;
    }
    [self.calendarPopover setPopoverContentSize:CGSizeMake(320, height) animated:animated];
}

- (void)removeSubviewsFromCell:(UITableViewCell*)thisCell {
    UIView* uv = [thisCell viewWithTag:1];
    [uv removeFromSuperview];
    uv = [thisCell viewWithTag:2];
    [uv removeFromSuperview];
    uv = [thisCell viewWithTag:3];
    [uv removeFromSuperview];
}

- (void)userInterestsChanged:(NSArray*)interests {
    self.selectedPreferences = interests;
    [self.tableView reloadData];
    [self.delegate filtersModified:interests];
}

@end
