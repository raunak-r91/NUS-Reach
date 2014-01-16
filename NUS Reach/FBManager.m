//
//  FBManager.m
//  NUS Reach
//
//  Created by Lu Xiaodi on 20/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "FBManager.h"

@interface FBManager ()
@property NSMutableDictionary *postParams;
@end

@implementation FBManager

@synthesize loginButtonUpdater;
// Return the current state of the session.

- (id) init {
    if (self = [super init]){
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        // if no active fb sessions, then create a new one
        // if there is active fb session, then do nothing
        if (!appDelegate.fbSession.isOpen) {
            // create a fresh session object
            appDelegate.fbSession = [[FBSession alloc] init];
            
            // if we don't have a cached token, a call to open here would cause UX for login to occur
            if (appDelegate.fbSession.state == FBSessionStateCreatedTokenLoaded) {
                // even though we had a cached token, we need to login to make the session usable
                [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session,
                                                                   FBSessionState status,
                                                                   NSError *error) {
                    [loginButtonUpdater updateFBLoginBtn];
                }];
            }
        }
    }
    return self;
}

+ (BOOL)isSessionOpen {
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.fbSession.isOpen) {
        // valid account UI is shown whenever the session is open
        return YES;
    } else {
        // login-needed account UI is shown whenever the session is closed
        return NO;
    }
}

// handler for button click, logs sessions in or out
- (void)buttonClickHandler:(void (^)(id)) block {

    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    // Log out
    if (appDelegate.fbSession.isOpen) {
        [appDelegate.fbSession closeAndClearTokenInformation];
    } else { //log in
        if (appDelegate.fbSession.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.fbSession = [[FBSession alloc] init];
        }

        [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // update ux
            [loginButtonUpdater updateFBLoginBtn];
        }];
    }
    block(self);
    
}


- (void)shareButtonAction:(NSDictionary*)shareData {
    self.postParams = [NSDictionary dictionaryWithDictionary:shareData];
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    // Hide keyboard if showing when button clickeds
    // Ask for publish_actions permissions in context
    if ([appDelegate.fbSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // No permissions found in session, ask for it
        [appDelegate.fbSession
         requestNewPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 [self publishStory];
             }
         }];
    } else {
        // If permissions present, publish the story
        [self publishStory];
    }
}

- (void)publishStory {
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    [FBWebDialogs presentFeedDialogModallyWithSession:appDelegate.fbSession
                                            parameters:self.postParams
                                               handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or publishing a story.
             NSLog(@"Error publishing story.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled story publishing.");
             }
             else {
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if ([urlParams valueForKey:@"post_id"]) {
                     NSString *msg = @"The Event has been posted on your timeline!";
                     // Show the result in an alert
                     [[[UIAlertView alloc] initWithTitle:@"Congrats!"
                                                 message:msg
                                                delegate:nil
                                       cancelButtonTitle:@"OK!"
                                       otherButtonTitles:nil]
                      show];
                 }
             }
             
         }
     }];
}


//Parse the query returned and splits the string according to certain punctuations
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

@end
