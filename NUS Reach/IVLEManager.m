//
//  IVLEManager.m
//  NUS Reach
//
//  Created by Lu Xiaodi on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "IVLEManager.h"

@interface IVLEManager ()

@property(strong, nonatomic) NSXMLParser* rssParser;
@property(strong, nonatomic) IVLEUserParser *ivleUsrParser;
@end

@implementation IVLEManager
@synthesize usrToken, usrId;
@synthesize ivleUsrParser, rssParser, allEvents;

-(id) init {
    if(self = [super init]) {
        usrToken = @"";
        catDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Arts and Entertainment", @"1", @"Conferences and Seminars", @"3", @"Fairs and Exibitions", @"4", @"Health and Wellness", @"6", @"Lectures and Workshops", @"2", @"Others", @"8", @"Social Events", @"7", @"Sports and Recreation", @"5", nil];
        [self loadUsrToken];
        ivleUsrParser = [[IVLEUserParser alloc] init];
    }
    return self;
}

////////////////////////////////////////
//////Starting: public functions////////
////////////////////////////////////////

- (BOOL) validate {
    //EFFECT: validate user; return a new token if the old token will be expired in one day
    NSString *urlStringFormat = IVLE_LOGIN_URL;
    NSString *urlString = [NSString stringWithFormat:urlStringFormat, IVLE_API_KEY, usrToken];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // parse url
    BOOL validationSuccess = [ivleUsrParser parseValidationFromURL:url];
    
    // update user token
    NSString *newUsrToken = ivleUsrParser.usrToken;
    if (![newUsrToken isEqualToString:usrToken]){
        usrToken = newUsrToken;
        [self saveUsrToken];
    }
    
    return validationSuccess;
}

- (NSString*) getUserName {
    //EFFECT: return a string of the current IVLE user name
    NSString *urlStringFormat = IVLE_USERNAME_URL;
    NSString *urlString = [NSString stringWithFormat:urlStringFormat, IVLE_API_KEY, usrToken];
    NSURL *url = [NSURL URLWithString:urlString];
    return [ivleUsrParser parseUserNameFromURL:url];
}

- (NSString*) getUserId {
    //EFFECT: return a string of the current IVLE user name
    NSString *urlStringFormat = IVLE_USERID_URL;
    NSString *urlString = [NSString stringWithFormat:urlStringFormat, IVLE_API_KEY, usrToken];
    NSURL *url = [NSURL URLWithString:urlString];
    return [ivleUsrParser parseUserIdFromURL:url];
}


- (NSArray*) pullAllEvents {
    NSString * pathPrefix = IVLE_PULL_EVENTS_URL;
    NSArray * affixForCategories = [catDictionary allKeys];
    NSString * path;
    allEvents = [[NSMutableArray alloc] init];
    
    for (NSString* catAffix in affixForCategories){
        path = [NSString stringWithFormat:@"%@%@", pathPrefix, catAffix];
        currentCategory = [catDictionary valueForKey:catAffix];
        [self parseXMLFileAtURL:path];
    }
    return [allEvents copy];
}

//Here the parameters follows what we have in event creation window
- (BOOL) postNewEventUsingTitle:(NSString*)eventTitle Venue:(NSString*)eventVenue Price:(NSString*)eventPrice Category:(NSString*)categoryStr StartTime:(NSDate*)startTime EndTime: (NSDate*)endTime Description: (NSString*)description {
    
    NSString* catID = [[catDictionary allKeysForObject:categoryStr] objectAtIndex:0];
    NSDateFormatter *thisFormatter = [[NSDateFormatter alloc]init];
    [thisFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss Z"];
    NSString *eventStartStr = [thisFormatter stringFromDate:startTime];
    NSString *eventEndStr = [thisFormatter stringFromDate:endTime];
    NSString *eventStartEndStr = [NSString stringWithFormat:@"%@%@", eventStartStr, eventEndStr];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"dd-MMM-yyyy"];
    
    //default disp start date: 12 days prior to event
    NSString *dispStartDateStr = [formatter2 stringFromDate:[startTime dateByAddingTimeInterval:-3600*24*12]];
    //default disp end date: 1 day after event
    NSString *dispEndDateStr = [formatter2 stringFromDate:[startTime dateByAddingTimeInterval:3600*24]];
    
    NSString *post = [NSString stringWithFormat:IVLE_POST_EVENTS_DATA, IVLE_API_KEY, usrToken, catID, eventStartEndStr, description, eventPrice, eventTitle, eventVenue, dispStartDateStr, dispEndDateStr];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:IVLE_POST_EVENTS_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *error;
    
    /////WARNING: this sentence will post to IVLE.
    /////Comment it during test!
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSData *result = [@"{\"EventID\":\"c7eadff1-9634-4c1d-9f8a-394f6ab0a79a\",\"Success\":true,\"Info\":\"Event posted successfully\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL success = [ivleUsrParser parseEventPostResponseFromData:result];
    
    return success;
}

////////////////////////////////////////
////////Ending: public functions////////
////////////////////////////////////////

////////Testing functions////////

-(void) testPost {
    NSString* title = @"3217 NUS Reach Demo";
    NSString* venue = @"COM1";
    NSString* cat = @"Fairs and Exibitions";
    NSString* price = @"Not applicable";
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat: @"dd MMM yyyy HH:mm:ss"];
    
    NSDate * startTime = [formatter dateFromString:@"22 Apr 2013 14:00:00"];
    NSDate * endTime = [formatter dateFromString:@"22 Apr 2013 16:00:00"];
    
    NSString * description = @"This is a test event post from CS3217 project team";
    NSLog(@"post result:%d", [self postNewEventUsingTitle:title Venue:venue Price:price Category:cat StartTime:startTime EndTime:endTime Description:description]);
}

////////End: testing functions//////

////////////////////////////////////////
///////Starting: parse functions////////
////////////////////////////////////////

- (void)parserDidStartDocument:(NSXMLParser *)parser{
	NSLog(@"found file and started parsing");
	
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
	
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	
    [rssParser parse];
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
//    NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentDescription = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
        currentVenue = [[NSMutableString alloc] init];
        currentTime = [[NSMutableString alloc] init];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"eventid"];
		[item setObject:currentDescription forKey:@"description"];
		[item setObject:currentDate forKey:@"eventdate"];
        [item setObject:currentCategory forKey:@"tag"];
        [item setObject:currentVenue forKey:@"venue"];
		
		[allEvents addObject:[item copy]];
//		NSLog(@"adding story");
//        NSLog(@"--------------------");
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
//	NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
        [currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"]) {
		[currentDescription appendString:string];
	} else if ([currentElement isEqualToString:@"eventdate"]) {
		[currentDate appendString:string];
    } else if ([currentElement isEqualToString:@"venue"]){
        [currentVenue appendString:string];
    }

}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"all done!");
	NSLog(@"events array has %d items", [allEvents count]);
}

////////////////////////////////////////
////////Ending: parse functions/////////
////////////////////////////////////////



////////////////////////////////////////
///////Start: saving user token/////////
////////////////////////////////////////
- (void)saveUsrToken{
    // EFFECTS: save user token to ipad
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 1, YES) objectAtIndex:0];
    NSString *file = [path stringByAppendingString:@"/savedUsrToken"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:file]){
        NSError *error;
        BOOL oldFileDeletionSuccess = [fileManager removeItemAtPath:file error:&error];
        if (!oldFileDeletionSuccess){
            NSLog(@"Error:%@", [error localizedDescription]);
        }
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:usrToken forKey:@"usrToken"];
    [archiver finishEncoding];
    
    BOOL success = [data writeToFile:file atomically:YES];
    if(success){
        NSLog(@"Token saved successfully");
    }
}
- (void)loadUsrToken{
    // EFFECTS: load user token from ipad memory
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 1, YES) objectAtIndex:0];
    NSString *file = [path stringByAppendingString:@"/savedUsrToken"];
    NSMutableData *data = [NSMutableData dataWithContentsOfFile:file];
    NSKeyedUnarchiver *unachiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    usrToken = [unachiver decodeObjectForKey:@"usrToken"];
}

- (void)removeUsrToken{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 1, YES) objectAtIndex:0];
    NSString *file = [path stringByAppendingString:@"/savedUsrToken"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:file]){
        NSError *error;
        BOOL oldFileDeletionSuccess = [fileManager removeItemAtPath:file error:&error];
        if (!oldFileDeletionSuccess){
            NSLog(@"Error:%@", [error localizedDescription]);
        }
    }
}
////////////////////////////////////////
////////End: saving user token//////////
////////////////////////////////////////

@end
