/*
 This class handles the settings page of the user. It displays the possible Preferences
 along with his selected preferences and send a delegate to the relevant controller 
 when the preferenes are selected and done is pressed
 */

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "UserModel.h"
#import "UserLoginViewController.h"
#import "FBManager.h"
#import "CategoriesCell.h"

@protocol UserInterestDelegate <NSObject>
//informs the updated preferences of the user through the UserModel
- (void)userInterestsChanged:(UserModel*)user;
@end

@interface UserInterestViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *interestCollection;
@property (weak) id<UserInterestDelegate> delegate;

//dismiss the view controller
- (IBAction)doneBtnPressed:(id)sender;

//dismisses the view controller wihout editing any preferences
- (IBAction)skipBtnPressed:(id)sender;


@end
