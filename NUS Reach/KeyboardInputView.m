//
//  KeyboardInputView.m
//  Test
//
//  Created by Ishaan Singal on 3/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "KeyboardInputView.h"

@implementation KeyboardInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"KeyboardInputView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
        
        //Add the Tapku calendar to the keyboard
        self.calendarView = [[TKCalendarMonthViewController alloc]initWithSunday:YES];
        [self.calendarView loadView];
        [self.calendarHolder addSubview: self.calendarView.monthView];
        
    }
    return self;
}

//returns the currently selected data and time in the keboard
- (NSString*)getDateAndTime {
    NSDate *tempDate = [NSDate date];
    if (self.calendarView.monthView.dateSelected != nil){
        tempDate = self.calendarView.monthView.dateSelected;
    }
    
    //concatenate both the date and time, and return it as a string
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMM yyyy"];
    NSString *resultDate = [dateFormat stringFromDate:tempDate];
    
    [dateFormat setDateFormat:@", hh:mm aa"];
    resultDate = [resultDate stringByAppendingString:[dateFormat stringFromDate:self.timePicked.date]];
    return resultDate;
}

@end
