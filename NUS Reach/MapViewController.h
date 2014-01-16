/*
 This class controls the main map view of the application.
 It interacts with the MapQuest API to display the campus map.
 This class also controls the annotations and gestures which have been added onto the map.
 It communicates with the other classes through delegates when the user long presses on 
 the map to create an event or get directions to a location
 */

#import <UIKit/UIKit.h>
#import <MQMapKit/MQMapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "EventViewController.h"
#import "AnnotationViewController.h"
#import "MapAnnotationHandler.h"

//a protocol to inform when user requests an action through gestures
@protocol MapViewUpdater <NSObject>
@optional
//sends a delegate to inform the relevant controller when directions to a particular
//spot on map is requested
- (void)longpressShowRouteDetails:(CLLocationCoordinate2D)location;

//sends a delegate to inform the relevant controller when an event is to be created
//directly from the map at a location
- (void)longpressCreateEvent:(NSString*)location;
@end


@interface MapViewController : UIViewController <UIGestureRecognizerDelegate, MQMapViewDelegate, AnnotationViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

@property MQMapView *mapView;
@property (weak) id<MapViewUpdater>delegate;

//REQUIRES: The array to have EventViewControllers with valid EventModels
//EFFECTS: Resets the annotations being shown on the map, and re-loads the annotions
//provided as a parameter in 'annotationList. Only those events with a valid 
//MODIFIES: the annotations on the map
- (void)loadAnnotations:(NSArray*)annotationList;

//REQUIRES: An EventVIewController with a valid EventModel
//EFFECTS: Adds an annotation to the map, it an annotation already existed at the location,
//it adds the event to the annotation table
- (void)addAnnotation:(EventViewController*)annotation;

//REQUIRES: The user location to be present on the map
//EFFECTS: Centers the map based on the user's current location
- (void)goToUserLocation;

//REQUIRES: Some EventDetailView to be modally shown on the screen
//EFFECTS: Dismisses the detail view controller
- (void)dismissDetailController;

@end
