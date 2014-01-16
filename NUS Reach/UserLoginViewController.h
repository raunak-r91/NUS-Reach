/*
 The class handles the login/logout request for IVLE. It has a delegate to inform
 the respective controller that the user has been successfully logged in. 
 Baseed on the login with IVLE, it sends the token to IVLEManager to be saved in
 a file
 */

#import "IVLEManager.h"
#import "UserModel.h"

@protocol UserLoginDelegate <NSObject>
@optional
//sends a delegate when the user is successfully logged in
- (void)userLoggedIn;
@end

@interface UserLoginViewController : UIViewController <UIWebViewDelegate>

@property (weak) id<UserLoginDelegate>delegate;
@property (strong, nonatomic) IBOutlet UITextField *uidField;
@property (strong, nonatomic) IBOutlet UITextField *pwdField;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

//EFFECTS: initialises the login with the given usermodel
- (id)initWithUser:(UserModel*)usermodel;

//EFFECTS: tries to log the user in and returns whether successful
- (BOOL)runLoginRequest;

@end
