//
//  DatabaseHandler.m
//  NUS Reach
//
//  Created by Ishaan Singal on 31/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DatabaseHandler.h"

@implementation DatabaseHandler

+ (void)insertRow:(NSDictionary*)data inTable:(NSString*)tableName{
    PFObject *eventParseObject = [PFObject objectWithClassName:tableName];
    for (NSString* key in data) {
        [eventParseObject setObject:[data objectForKey:key] forKey:key];
    }
    [eventParseObject saveInBackground];
    return;
}

+ (NSArray*)getAllRowsFromTable:(NSString*)tableName {
    NSMutableArray *allRows = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:tableName];
    NSArray *allPFObjects = [query findObjects];
    
    for (PFObject *thisPFObject in allPFObjects) {
        NSMutableDictionary *tempRow = [[NSMutableDictionary alloc]init];
        for (NSString *thisKey in [thisPFObject allKeys]) {
             [tempRow setObject:[thisPFObject objectForKey:thisKey] forKey:thisKey];
        }
        [allRows addObject:tempRow];
    }
    return allRows;
}


+ (void)deleteRowWithData:(NSDictionary*)date FromTable:(NSString*)tableName {
    PFQuery *query = [PFQuery queryWithClassName:tableName];
    NSArray *allPFObjects = [query findObjects];
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc]init];
    for (PFObject *thisPFObject in allPFObjects) {
        BOOL isMatch = YES;
        for (NSString *key in date.allKeys) {
            if(![[date objectForKey:key] isKindOfClass:[NSString class]]) {
                NSDate *date1 = (NSDate*)[thisPFObject objectForKey:key];
                NSDate *date2 = (NSDate*)[date objectForKey:key];
                if([date1 compare:date2] != NSOrderedSame) {
                    isMatch = NO;
                    break;
                }
            } else if (![[thisPFObject objectForKey:key] isEqualToString:[date objectForKey:key]]){
                isMatch = NO;
                break;
            }
        }
        if (isMatch) {
            [objectsToDelete addObject: thisPFObject];
        }
    }
    for (PFObject *thisObject in objectsToDelete) {
        [thisObject deleteInBackground];
    }
}

@end
