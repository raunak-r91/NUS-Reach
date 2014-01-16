//
//  UserOptionsViewController.m
//  NUS Reach
//
//  Created by Ishaan Singal on 23/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "UserOptionsViewController.h"


@implementation UserOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.fbSession.isOpen) {
        [self.facebookLoginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    [self setContentSizeForViewInPopover:CGSizeMake(225, 86)];
}
- (void)setIvleButtonTitle:(NSString*)title {
    [self.ivleLoginButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)ivleLoginButtonPressed:(id)sender {
    if ([((UIButton*)sender).titleLabel.text isEqualToString:@"Login"]) {
        [self.delegate ivleLoginPressed];
    }
    else {
        [self.delegate ivleLogoutPressed];
    }
}
- (IBAction)facebookLoginButtonPressed:(id)sender {
    [self.delegate facebookLoginPressed];
}


-(void) setFacebookButtonTitle:(NSString *)title {
    [self.facebookLoginButton setTitle:title forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setFacebookBtn:nil];
    [self setIvleButton:nil];
    [self setIvleLoginButton:nil];
    [self setFacebookLoginButton:nil];
    [super viewDidUnload];
}

@end
