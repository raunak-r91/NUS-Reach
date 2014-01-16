//
//  UserLoginViewController.m
//  NUS Reach
//
//  Created by Lu Xiaodi on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "UserLoginViewController.h"

@interface UserLoginViewController ()

@end

@implementation UserLoginViewController

@synthesize webView, uidField, pwdField, signinBtn;
@synthesize ivleManager;
/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
<<<<<<< HEAD
//    webView.delegate = self;
=======
    isCssAttached = false;
    webView.delegate = self;
>>>>>>> Save ivle usrToken in ipad
    ivleManager = [[IVLEManager alloc] init];
    
    // if usrToken in ivleManager is not empty, then load webview
    // or else the web view will not be loaded
    NSString *apikey = @"fyc4UOPp9dyIv8JiBkzcN";
    
    if (ivleManager.usrToken==nil || [ivleManager.usrToken isEqualToString:@""]){

        NSString *redirectUrlString = @"http://ivle.nus.edu.sg/api/login/login_result.ashx";
        NSString *authFormatString = @"https://ivle.nus.edu.sg/api/login/?apikey=%@";
        
        NSString *urlString = [NSString stringWithFormat:authFormatString, apikey, redirectUrlString];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [webView loadRequest:request];
    } else {
        NSString *loadToken = ivleManager.usrToken;
        NSString *formatStr = @"https://ivle.nus.edu.sg/api/Lapi.svc/UserName_Get?APIKey=%@&Token=%@";
        NSString *urlString = [NSString stringWithFormat:formatStr, apikey, loadToken];
        NSLog(urlString);
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    NSString *urlString = request.URL.absoluteString;
	NSLog(@"urlString: %@", urlString);
	
    ivleManager.usrToken = [self getAccessToken:urlString];
    
    if (![ivleManager.usrToken isEqual:@""]){
        [self.webView removeFromSuperview];
        [ivleManager saveUsrToken];
    }
    return TRUE;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *css = @"body{ background-color:#b0c4de;}";
    NSString* js = [NSString stringWithFormat:
                    @"var styleNode = document.createElement('style');\n"
                    "styleNode.type = \"text/css\";\n"
                    "var styleText = document.createTextNode(%@);\n"
                    "styleNode.appendChild(styleText);\n"
                    "document.getElementsByTagName('head')[0].appendChild(styleNode);\n",css];
    NSLog(@"js:\n%@",js);
    [webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"webViewDidFinishLoad Executed");
}


-(NSString*)getAccessToken:(NSString *)urlString {
	
    
	NSError *error;
    
	NSLog(@"checkForAccessToken: %@", urlString);
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"r=(.*)"
								  options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *firstMatch =
		[regex firstMatchInString:urlString
						  options:0 range:NSMakeRange(0, [urlString length])];
        if (firstMatch) {
            NSRange accessTokenRange = [firstMatch rangeAtIndex:1];
            NSString *success = [urlString substringWithRange:accessTokenRange];
            success = [success
                       stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			//check for r=0
			NSLog(@"success: %@", success);
			
			if ([success isEqualToString:@"0"]) {
				NSURL *responseURL = [NSURL URLWithString:urlString];
                
				NSString *token = [NSString stringWithContentsOfURL:responseURL
														   encoding:NSASCIIStringEncoding
															  error:&error];
				
				//print out the token or save for next logon or to navigate to next API call.
				NSLog(@"token: %@", token);
                return token;
			}
        }
	}
    return @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    webView = nil;
    [self setUidField:nil];
    [self setPwdField:nil];
    [self setSigninBtn:nil];
    [super viewDidUnload];
}
@end
