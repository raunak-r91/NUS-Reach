#import "EventDetailView.h"

@interface EventDetailView()
@property UILabel *descriptionText;

@end

@implementation EventDetailView
@synthesize width, height, titleValue, venueValue, timeValue, priceValue, categoryValue, organizerValue, contactValue,  descriptionScroll, editBtn, attendBtn, fbBtn, routeBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


//initialies the view and modifies the UI of certain elements of the event details
- (id)initWithWidth:(CGFloat)w height:(CGFloat)h title:(NSString*)title venue:(NSString*)venue time:(NSString*)time price:(NSString*)price category:(NSString*)category organizer:(NSString*)organizer contact:(NSString*)contact description:(NSString*)description {

    self = [super initWithFrame:CGRectMake(0, 0, w, h)];
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"EventDetails" owner:self options:nil];
    UIView *mainView = [subviewArray objectAtIndex:0];
    [self addSubview:mainView];
    
    [titleValue setText:title]; 
    [venueValue setText:venue]; 
    [timeValue setText:time];
    [priceValue setText:price];
    [categoryValue setText:category];
    [organizerValue setText:organizer];
    [contactValue setText:contact];

    if ([description rangeOfString:@"Event Description: "].location != NSNotFound) {
        description = [description substringWithRange:NSMakeRange(20, [description length]-20)];
    }
    description = [description stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    
    int count = [description length]/70;
    CGRect descriptionFrame = CGRectMake(0, 0, 0, 0);
    descriptionFrame.size.width = descriptionScroll.frame.size.width;
    int thisHeight = (count + 2)*40;
    descriptionFrame.size.height = thisHeight;
    self.descriptionText =[[UILabel alloc]initWithFrame:descriptionFrame];
    [self.descriptionText setText:description];
    self.descriptionText.textAlignment = UITextAlignmentLeft;
    self.descriptionText.numberOfLines = 0;
    [self.descriptionText sizeToFit];

    [descriptionScroll addSubview:self.descriptionText];
    [descriptionScroll setContentSize:CGSizeMake(self.descriptionText.frame.size.width, thisHeight)];
    descriptionScroll.scrollEnabled = YES;
    
    titleValue.textColor = [UIColor blackColor]; titleValue.backgroundColor = [UIColor clearColor];
    venueValue.textColor = [UIColor blackColor]; venueValue.backgroundColor = [UIColor clearColor];
    timeValue.textColor = [UIColor blackColor]; timeValue.backgroundColor = [UIColor clearColor];
    priceValue.textColor = [UIColor blackColor]; priceValue.backgroundColor = [UIColor clearColor];
    categoryValue.textColor = [UIColor blackColor]; categoryValue.backgroundColor = [UIColor clearColor];
    organizerValue.textColor = [UIColor blackColor]; organizerValue.backgroundColor = [UIColor clearColor];
    contactValue.textColor = [UIColor blackColor]; contactValue.backgroundColor = [UIColor clearColor];

    self.venueValue.numberOfLines = 0;
    self.timeValue.numberOfLines = 0;
    self.priceValue.numberOfLines = 0;
    self.categoryValue.numberOfLines = 0;
    self.organizerValue.numberOfLines = 0;
    self.contactValue.numberOfLines = 0;
    return self;
}



- (void)userAttending {
    [attendBtn setTitle:@"Unattend" forState:UIControlStateNormal];
}

- (IBAction)editBtnPressed:(id)sender {
    [self.delegate editEvent];
}

- (IBAction)attendBtnPressed:(id)sender {
    [self.delegate attendEvent];
}

- (IBAction)routeBtnPressed:(id)sender {
    [self.delegate showRoute];
}

- (IBAction)facebookBtnPressed:(id)sender {
    [self.delegate shareEvent];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
