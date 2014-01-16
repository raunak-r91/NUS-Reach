/*
 The class handles the login/logout request for IVLE. It has a delegate to inform
 the respect controller that the user has been successfully logged in.
 Baseed on the login with IVLE, it sends the token to IVLEManager to be saved in
 a file
 */

#import "UserLoginViewController.h"

@interface UserLoginViewController ()
@property NSData *responseData;
@property UserModel *user;
@property IVLEManager* ivleManager;
@end

@implementation UserLoginViewController

@synthesize uidField, pwdField;
@synthesize ivleManager;

- (id)init {
    self = [super init];
    if (self) {
        ivleManager = [[IVLEManager alloc]init];
        _user = [[UserModel alloc]init];
    }
    return self;
}

- (id)initWithUser:(UserModel*)usermodel {
    self = [super init];
    if (self) {
        ivleManager = [[IVLEManager alloc]init];
        _user = usermodel;
    }
    return self;    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [[UserModel alloc]init];
    self.errorLabel.hidden = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(loginDetailsConfirmed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (BOOL)isValidLoginDetails {
    BOOL result = NO;
    if (![ivleManager.usrToken isEqual:@""]) {
        [ivleManager saveUsrToken];
        result = YES;
    }
    else {
        result = NO;
    }
    return result;
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
            success = [success stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
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

- (void)loginDetailsConfirmed:(id)sender {
    //send a delegate if the user is succsessfully logged in
    self.user.username = self.uidField.text;
    self.user.password = self.pwdField.text;
    if ([self runLoginRequest]) {
        self.errorLabel.hidden = YES;
        [self.delegate userLoggedIn];
    }
    else {
        self.errorLabel.text = @"Username or Password invalid!";
        self.errorLabel.hidden = NO;
    }
}

- (BOOL)runLoginRequest {
    NSString * encodedPassword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                       NULL,
                                                                                                       (CFStringRef)self.user.password,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                       kCFStringEncodingUTF8 ));
    
    NSString *urlString = [NSString stringWithFormat: IVLE_LOGIN_API_CALL, self.user.username, encodedPassword];
    NSLog(@"%@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSString *responseString = [[NSString alloc] initWithData:response1 encoding:NSASCIIStringEncoding];
    
    //if the response string (ie token) is not of the right length, return no
    if ([responseString length] != IVLE_LOGIN_API_RESPONSE_LENGTH) {
        return NO;
    }
    else { //otherwise save the token
        ivleManager.usrToken = responseString;
        [ivleManager saveUsrToken];
        return YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUidField:nil];
    [self setPwdField:nil];
    [self setErrorLabel:nil];
    [super viewDidUnload];
}
@end
