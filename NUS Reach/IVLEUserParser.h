/*
 This class is a helper class for IVLE manager to parse the user data and check for
 various functions. It uses the usertoken to check whether the user is logged in and
 to parse its username & userid
 */

#import <Foundation/Foundation.h>

@interface IVLEUserParser : NSObject<NSXMLParserDelegate>{
    NSString* usrToken;
}
@property(strong, nonatomic) NSString* usrToken;


//EFFECTS: initialises the parser with the usertoken to validate
-(id) initWithUserToken: (NSString*)aUsrToken;

//EFFECTS: based on the url provided, checks whether the usertoken is valid
-(BOOL) parseValidationFromURL:(NSURL*)url;

//EFFECTS: based on the url provided, parses the username and returns it
-(NSString*) parseUserNameFromURL:(NSURL*)url;

//EFFECTS: based on the url provided, parses the userid and returns it
-(NSString*) parseUserIdFromURL:(NSURL*)url;

//EFFECTS: parses the data that is provided and checks whether post was successful
-(BOOL) parseEventPostResponseFromData:(NSData*)data;

@end
