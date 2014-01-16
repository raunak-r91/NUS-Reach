//
//  UserInterestViewController.m
//  NUS Reach
//
//  Created by Ishaan Singal on 27/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "UserInterestViewController.h"
#import "MainViewController.h"

@interface UserInterestViewController ()
@property NSArray *interestCategories;
@property NSMutableArray *selectedInterests;
@property UserModel *thisUser;
@end

@implementation UserInterestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.thisUser = [[UserModel alloc]init];
    self.selectedInterests = [[NSMutableArray alloc]init];
    IVLEManager *ivle = [[IVLEManager alloc]init];
    if ([ivle validate]) {
        [self loadUserPreferencesFromDatabase:[ivle getUserId]];
    }

    self.interestCategories = [[NSArray alloc]initWithObjects:@"Arts and Entertainment", @"Conferences and Seminars", @"Fairs and Exhibitions", @"Health and Wellness", @"Lectures and Workshops", @"Social Events", @"Sports and Recreation", nil];
    self.interestCollection.delegate = self;
    self.interestCollection.dataSource = self;
    self.interestCollection.allowsMultipleSelection = YES;    
}

- (void)loadUserPreferencesFromDatabase:(NSString*)userid {
    NSArray *userRecords;
    NSArray *usersData = [DatabaseHandler getAllRowsFromTable:@"UserData"];
    for (NSDictionary *thisVal in usersData) {
        if ([[thisVal objectForKey:@"userid"] isEqualToString:userid]) {
            userRecords = [NSArray arrayWithArray:[thisVal objectForKey:@"preferences"]];
            break;
        }
    }
    self.selectedInterests = [NSMutableArray arrayWithArray:userRecords];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.interestCategories.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"InterestCell";
    CategoriesCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"PreferencesImages" ofType:@"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString* imageName = [dict objectForKey:[self.interestCategories objectAtIndex:indexPath.row]];
    
    cell.image = [UIImage imageNamed:imageName];
    NSString* text = [self.interestCategories objectAtIndex:indexPath.row];
    cell.label.text = text;
    [cell.label setFont:[UIFont fontWithName:@"Helvetica" size:[UIFont systemFontSize]*1.2f]];

    for (NSString *preference in self.selectedInterests) {
        if ([text rangeOfString:preference].location != NSNotFound) {
            cell.imageView.layer.borderWidth = 4.0f;
            [cell.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:[UIFont systemFontSize]*1.2f]];
            cell.imageView.layer.borderColor = [UIColor redColor].CGColor;
            [self.interestCollection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];

            break;
        }
    }
        
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoriesCell* cell = (CategoriesCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedInterests addObject:cell.label.text];
    cell.imageView.layer.borderWidth = 4.0f;
    [cell.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:[UIFont systemFontSize]*1.2f]];
    cell.imageView.layer.borderColor = [UIColor redColor].CGColor;    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoriesCell* cell = (CategoriesCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedInterests removeObject:cell.label.text];
    cell.imageView.layer.borderWidth = 0.0f;
    [cell.label setFont:[UIFont fontWithName:@"Helvetica" size:[UIFont systemFontSize]*1.2f]];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(250.0f, 185.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 100, 50);
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.thisUser.userPreferences = self.selectedInterests;
    if ([viewController isKindOfClass:[MainViewController class]]) {
        [(MainViewController*)viewController setUserModel:self.thisUser];
    }
}

- (IBAction)doneBtnPressed:(id)sender{
    self.thisUser.userPreferences = self.selectedInterests;
    IVLEManager *ivle = [[IVLEManager alloc]init];
    if ([ivle validate]) {
        [DatabaseHandler deleteRowWithData:[NSDictionary dictionaryWithObjectsAndKeys:[ivle getUserId], @"userid", nil]FromTable:@"UserData"];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.thisUser.userPreferences, @"preferences", [ivle getUserId], @"userid", nil];
        [DatabaseHandler insertRow:dict inTable:@"UserData"];
    }
    [self.delegate userInterestsChanged:self.thisUser];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)skipBtnPressed:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setInterestCollection:nil];
    [super viewDidUnload];
}

@end
