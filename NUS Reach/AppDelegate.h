//
//  AppDelegate.h
//  NUS Reach
//
//  Created by Ishaan Singal on 26/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *fbSession;

@end
