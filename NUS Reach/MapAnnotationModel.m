//
//  MapModel.m
//  NUS Reach
//
//  Created by Ishaan Singal on 10/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "MapAnnotationModel.h"
#import "Constants.h"

@implementation MapAnnotationModel

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle subTitle:(NSString *)aSubtitle model:(EventModel*)aModel {
    self = [super initWithCoordinate:coord title:aTitle subTitle:aSubtitle];
    if (self) {
        _event = aModel;
    }
    return self;
}

@end
