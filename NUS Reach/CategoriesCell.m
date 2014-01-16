//
//  CategoriesCell.m
//  NUS Reach
//
//  Created by Raunak on 23/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "CategoriesCell.h"

@implementation CategoriesCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    
    _image = image;
    self.imageView.image = _image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
