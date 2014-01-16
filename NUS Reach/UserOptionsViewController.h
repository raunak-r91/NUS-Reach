/*
 This class shows the popover view for the User logins. The two logins shown 
 and controlled are facebook and ivle. Based on which login the user chooses, the 
 action is delegated accordingly.
 It has a delegate to inform the relevant controller when the user logs in/out of ivle 
 and facebook.
 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
@protocol UserOptionsDelegate <NSObject>
//informs when ivle login is pressed
- (void)ivleLoginPressed;

//informs when ivle logout button is pressed
- (void)ivleLogoutPressed;

//informs when facebook button is pressed
- (void)facebookLoginPressed;
@end

@interface UserOptionsViewController : UIViewController <FBLoginViewDelegate>

@property (weak) id<UserOptionsDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIButton *facebookBtn;
@property (strong, nonatomic) IBOutlet UIButton *ivleButton;
@property (strong, nonatomic) IBOutlet UIButton *ivleLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *facebookLoginButton;

//EFFECTS: sends a delegate to inform whether the ivle log in or logout action is to be taken
- (IBAction)ivleLoginButtonPressed:(id)sender;

//EFFECTS: sends a delegate to inform 
- (IBAction)facebookLoginButtonPressed:(id)sender;

//EFFECTS: functions to toggle the ivle title (between login and logout)
//MODIFIES: ivle button
- (void)setIvleButtonTitle:(NSString*)title;

//EFFECTS: functions to toggle the facebook title (between login and logout)
//MODIFIES: facebook button
- (void)setFacebookButtonTitle: (NSString*)title;

@end
