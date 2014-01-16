/*
 This class handles all the backend requests to send to the database
 It handles insertion, retrieval and deleting of events.
 An edited event is first deleted and then readded in the database.
 */

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface DatabaseHandler : NSObject

//REQUIRES: a valid tablename and dictionary of data, where each key is the column name
//EFFECTS: if the tablename does not exist, it will create a new table in the database
//else add to the existing database
+ (void)insertRow:(NSDictionary*)data inTable:(NSString*)tableName;

//REQUIRES: a valid tablename
//EFFECTS: if the table exists, it will return all the rows data in a dictionary form,
//each key is the column name
+ (NSArray*)getAllRowsFromTable:(NSString*)tableName;

//REQUIRES: a valid tablename
//EFFECTS: if the table exists, it will delete the rows whose values correspond to that of
//the dictionary provided
+ (void)deleteRowWithData:(NSDictionary*)date FromTable:(NSString*)tableName;

@end
