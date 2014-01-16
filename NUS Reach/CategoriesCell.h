/* This class is a subclass of the UICollectionViewCell and is used to customize the cell by adding an image and label to each cell
 */

#import <UIKit/UIKit.h>

@interface CategoriesCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel* label;
@property (nonatomic, strong) UIImage* image;

@end
