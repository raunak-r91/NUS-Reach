//
//  IVLEUserParser.m
//  NUS Reach
//
//  Created by Lu Xiaodi on 14/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "IVLEUserParser.h"

@interface IVLEUserParser ()
@property(strong, nonatomic) NSXMLParser *parser;
@end

@implementation IVLEUserParser

@synthesize parser, usrToken;

-(id) init {
    if(self = [super init]){
    }
    return self;
}

-(id) initWithUserToken: (NSString*)aUsrToken {
    if(self = [super init]){
        usrToken = aUsrToken;
    }
    return self;
}

-(BOOL) parseValidationFromURL:(NSURL*)url{
    //EFFECT: update usrToken with the latest valid token
    //        update done with whether validation is successful
    
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    
    if(jsonData != nil){
        NSError *error = nil;
        usrToken = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error] objectForKey:@"Token"];
        NSLog(@"Token from user parser: %@", usrToken);
        NSNumber *success = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error] objectForKey:@"Success"];
        NSLog(@"Success value from user parser: %@", success);
        
        return success.boolValue;
    }

    return NO;
}

-(NSString*) parseUserNameFromURL:(NSURL*)url {
    //REQUIRE: api key and user token is correct
    //EFFECT: return user name
    
    NSError *error = nil;
    NSString *userName = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    userName = [userName substringWithRange:NSMakeRange(1, userName.length-2)];

    return userName;
}

-(NSString*) parseUserIdFromURL:(NSURL*)url {
    //REQUIRE: api key and user token is correct
    //EFFECT: return user name
    
    NSError *error = nil;
    NSString *userId = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    userId = [userId substringWithRange:NSMakeRange(1, userId.length-2)];
    
    return userId;
}

-(BOOL) parseEventPostResponseFromData:(NSData*)jsonData {
    //Response format:
    //{"EventID":"c7eadff1-9634-4c1d-9f8a-394f6ab0a79a","Success":true,"Info":"Event posted successfully"}
    if(jsonData != nil){
        NSError *error = nil;
        NSNumber *success = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error] objectForKey:@"Success"];
        NSLog(@"Success value from user parser: %@", success);
        
        return success.boolValue;
    }
    return NO;
}

@end
