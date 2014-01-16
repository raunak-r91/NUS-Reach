/*
 This class is a subclass of MQPointAnnotation (the annotation class of MapQuest SDK)
 The annotation will stores additional details like the actual event at the annotation
 */

#import <Foundation/Foundation.h>
#import <MQMapKit/MQMapKit.h>
#import "EventModel.h"

@interface MapAnnotationModel : MQPointAnnotation
@property EventModel *event; //the event that represents this annotation

//EFFECTS: a new initializer that also takes the EventModel as a parameter
//MODIFIES: the event model of this instance
- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle subTitle:(NSString *)aSubtitle model:(EventModel*)aModel;

@end
