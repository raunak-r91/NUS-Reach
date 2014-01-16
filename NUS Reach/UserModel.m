//
//  UserModel.m
//  NUS Reach
//
//  Created by Ishaan Singal on 13/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (id) init {
    self = [super init];
    if (self) {
        _eventsAttending = [[NSArray alloc]init];
        _eventsCreated = [[NSArray alloc]init];
        _userPreferences = [[NSArray alloc]init];
        _username = [[NSString alloc]init];
        _password = [[NSString alloc]init];
        _isLoggedin = NO;
    }
    return self;
}

@end
