/*
 This class handles the login/logout and posting events on facebook.
 It also has a delegate to inform the relevant controller that the user is logged in 
 and that the buttons should be updated accordingly (title login/logout)
 */

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@protocol FacebookLoginViewUpdater
-(void)updateFBLoginBtn;
@end

@interface FBManager : NSObject
@property (weak) id <FacebookLoginViewUpdater> loginButtonUpdater;

//EFFECTS: initalizes the session and sends a delegate based on whether the session is set
- (id)init;

//EFFECTS: returns whether logged in or not
+ (BOOL)isSessionOpen;

//EFFECTS: handles the login and sends the delegate accordingly
- (void)buttonClickHandler:(void (^)(id)) block;


//REQUIRES: user to be logged into facebook
//EFFECTS: shares the event on facebook by posting on the user wall
- (void)shareButtonAction:(NSDictionary*)shareData;

@end
