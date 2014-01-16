/*
 This class implemens a custom keyboard that can be used as an input view for the
 entering of Start/End Date Time of events
 It uses the Tapku library to show the calendar and uses its delegates to find the 
 selected dates.
 */

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@interface KeyboardInputView : UIView
@property TKCalendarMonthViewController *calendarView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *timePicked;
@property (strong, nonatomic) IBOutlet UIView *calendarHolder;

//EFFECTS: Returns the current selected date and time in the keyboard
- (NSString*)getDateAndTime;

@end
