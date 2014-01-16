/*
 This model class maintains the information of the current user using the application.
 */

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
@property NSString *username;
@property NSString *password;
@property NSArray *userPreferences;
@property NSArray *eventsAttending;
@property NSArray *eventsCreated;
@property BOOL isLoggedin;
@end
