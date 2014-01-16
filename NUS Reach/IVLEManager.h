/*
 This class is responsible for all actions with IVLE.
 It pulls all the IVLE events (through the RSS events) and parsing them in the relevant forms.
 It also saves and loads the user IVLE token once he logs in, or if he has a valid session
 It retrieves the username & userid of the user that is currently signed in
 It has functions to post an event to IVLE
 */

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "IVLEUserParser.h"

@interface IVLEManager : NSObject <NSXMLParserDelegate> {
    
    // it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString * currentElement;
	NSMutableString *currentTitle, *currentDate, *currentDescription, *currentLink, *currentCategory, *currentVenue, *currentTime;
    
    // a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * item;
    
    // category list
    NSDictionary * catDictionary;
    // current category
    NSString * currCategory;
    id __unsafe_unretained ivleViewUpdaterDelegate;
}

@property(strong, nonatomic) NSString* usrToken;
@property(strong, nonatomic) NSString* usrId;
@property(strong, nonatomic) NSMutableArray* allEvents;

//EFFECTS: pulls all the events from IVLE through the RSS feeds and returns an array of the dictionary
- (NSArray*) pullAllEvents;

//EFFECTS: posts an event to IVLE based on the given parameters of the event provided
//NOTE: it might take upto 6 days for the event to show unser IVLE as it is verified 
- (BOOL) postNewEventUsingTitle:(NSString*)eventTitle Venue:(NSString*)eventVenue Price:(NSString*)eventPrice Category:(NSString*)categoryStr StartTime:(NSDate*)startTime EndTime: (NSDate*)endTime Description: (NSString*)description;

//EFFECTS: saves the usertoken currently present in self.userToken
- (void)saveUsrToken;

//EFFECTS: loads the usertoken currently present in the file in documents
- (void)loadUsrToken;

//EFFECTS: removes the usertoken currently present in the file in documents
- (void)removeUsrToken;

//EFFECTS: based on the session and token, checks whether the user is actually logged in
- (BOOL) validate;

//EFFECTS: based on the session and token, retrieves the username of user logged in and returns it
- (NSString*) getUserName;

//EFFECTS: based on the session and token, retrieves the userid of user logged in and returns it
- (NSString*) getUserId;

//EFFECTS: a test method to check whether IVLE post works or not
-(void) testPost;
    

@end
