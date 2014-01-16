//
//  MapViewController.m
//  NUS Reach
//
//  Created by Raunak on 27/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <MQMapKit/MQUserLocationView.h>
#import "MapViewController.h"
#import "MapAnnotationModel.h"
#import "MainViewController.h"
#import "RouteViewController.h"
#import "BusRouter.h"

@interface MapViewController () {
    UIPopoverController *testPopover;
    CGFloat maxZoom;
    MQCoordinateRegion currentRegion;
    EventViewController *temp;
    EventDetailView *test;
    NSMutableArray *eventControllers;
    NSMutableArray *annotationTables;
    MapAnnotationHandler* mapAnnotations;
    CLLocationManager* userLocation;
    MQPointAnnotation* userLocationAnnotation;
    UIView *longpressView;
    
}
@end


@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Setup the map
    self.view = [[UIView alloc]initWithFrame:CGRectMake(MAPVIEW_ORIGIN_X, MAPVIEW_ORIGIN_Y, MAPVIEW_SIZE_WIDTH, MAPVIEW_SIZE_HEIGHT)];
    self.mapView = [[MQMapView alloc]initWithFrame:self.view.frame];
    [self.mapView setDelegate:self];

    //Set the default region to be displayed
    currentRegion = MQCoordinateRegionMakeWithCoordinates(CLLocationCoordinate2DMake(MAP_TOPLEFT_LATITUDE, MAP_TOPLEFT_LONGITUDE), CLLocationCoordinate2DMake(MAP_BOTTOMRIGHT_LATITUDE, MAP_BOTTOMRIGHT_LONGITUDE));
    [self.mapView setRegion:currentRegion animated:NO];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    maxZoom = self.mapView.zoomScale;
    self.mapView.scrollEnabled = NO;
    
    //Add custom gestures to map
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [longPress setDelegate:self];
    [longPress setMinimumPressDuration:0.5];
    [self.mapView addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(scrollMap:)];
    [panGesture setDelegate:self];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panGesture];
    
    mapAnnotations = [[MapAnnotationHandler alloc]init];
    //annotations for the table view
    annotationTables = [[NSMutableArray alloc]init];
    eventControllers = [[NSMutableArray alloc]init];
    self.mapView.showsUserLocation = YES;    
}


#pragma mark Map Display

//Check If map has zoomed out beyond the allowed limit. If yes, then reset map to default region
-(void)mapViewDidEndZooming:(MQMapView *)mapView {
    if (mapView.zoomScale < maxZoom) {
        MQCoordinateRegion region = MQCoordinateRegionMakeWithCoordinates(CLLocationCoordinate2DMake(MAP_TOPLEFT_LATITUDE, MAP_TOPLEFT_LONGITUDE), CLLocationCoordinate2DMake(MAP_BOTTOMRIGHT_LATITUDE, MAP_BOTTOMRIGHT_LONGITUDE));
        [self.mapView setRegion:region animated:NO];
    }
    else {
        MQCoordinateRegion region = self.mapView.region;
        
        CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2, region.center.longitude - region.span.longitudeDelta/2);
        CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2, region.center.longitude + region.span.longitudeDelta/2);
        if (topLeft.latitude > MAP_TOPLEFT_LATITUDE_LIMIT || topLeft.longitude < MAP_TOPLEFT_LONGITUDE_LIMIT) {
            [self.mapView setRegion:currentRegion animated:NO];
        }
        if (bottomRight.latitude < MAP_BOTTOMRIGHT_LATITUDE_LIMIT || bottomRight.longitude > MAP_BOTTOMRIGHT_LONGITUDE_LIMIT) {
            [self.mapView setRegion:currentRegion animated:NO];
        }
    }
    
}

//Handle custom panning of the map
- (void)scrollMap:(UIGestureRecognizer*)gesture {
    CGPoint translationDelta =  [(UIPanGestureRecognizer*)gesture translationInView:gesture.view.superview ];
    CGPoint beg = [(UIPanGestureRecognizer*)gesture locationInView:self.view];
    CGPoint endPoint = translationDelta;
    endPoint.x += beg.x;
    endPoint.y += beg.y;
    CLLocationCoordinate2D testFirst = [self.mapView convertPoint:beg toCoordinateFromView:self.view];
    CLLocationCoordinate2D testSecond = [self.mapView convertPoint:endPoint toCoordinateFromView:self.view];
    
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        CLLocationCoordinate2D newCenter = self.mapView.centerCoordinate;
        newCenter.latitude -= testSecond.latitude - testFirst.latitude;
        newCenter.longitude -= testSecond.longitude - testFirst.longitude;
        MQCoordinateRegion thisRegion = self.mapView.region;
        MQCoordinateSpan thisMapSpan = thisRegion.span;
        CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(newCenter.latitude + thisMapSpan.latitudeDelta/2, newCenter.longitude - thisMapSpan.longitudeDelta/2);
        CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(newCenter.latitude - thisMapSpan.latitudeDelta/2, newCenter.longitude + thisMapSpan.longitudeDelta/2);
        
        if (topLeft.latitude > MAP_TOPLEFT_LATITUDE_LIMIT || topLeft.longitude < MAP_TOPLEFT_LONGITUDE_LIMIT) {
            [((UIPanGestureRecognizer*)gesture) setTranslation:CGPointMake(0, 0) inView:gesture.view.superview];
            return;
        }
        if (bottomRight.latitude < MAP_BOTTOMRIGHT_LATITUDE_LIMIT || bottomRight.longitude > MAP_BOTTOMRIGHT_LONGITUDE_LIMIT) {
            [((UIPanGestureRecognizer*)gesture) setTranslation:CGPointMake(0, 0) inView:gesture.view.superview];
            return;
        }
        [self.mapView setCenterCoordinate:newCenter animated:NO];
    }
    if([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
    }
    
    [((UIPanGestureRecognizer*)gesture) setTranslation:CGPointMake(0, 0) inView:gesture.view.superview];
    currentRegion = self.mapView.region;
}


#pragma mark Long Press 
//Deal with long press gesture
- (void)longPressGesture:(UIGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translationDelta =  [(UILongPressGestureRecognizer*)gesture locationInView:gesture.view.superview ];
        CLLocationCoordinate2D testFirst = [self.mapView convertPoint:translationDelta toCoordinateFromView:self.view];
        
        NSString *nearest = [BusRouter findNearestBuilding:testFirst];
        UIActionSheet *popupSheet = [[UIActionSheet alloc] initWithTitle:nearest
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"Create Event",@"Directions", nil];
        
        popupSheet.actionSheetStyle = UIActionSheetStyleDefault;
        
        longpressView = [[UIView alloc]initWithFrame:CGRectMake(translationDelta.x, translationDelta.y, 5, 5)];
        longpressView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:longpressView];
        
        [popupSheet showFromRect:longpressView.frame inView:longpressView.superview animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([actionSheet.title isEqualToString:@"User Location"]) {
        if (buttonIndex == 0) {
            CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
            [self findNearestBusStop:location];
        }
    }
    else {
        if (buttonIndex == 0) {
            [self.delegate longpressCreateEvent:actionSheet.title];
        }
        else if (buttonIndex == 1) {
            CLLocationCoordinate2D location = [self.mapView convertPoint:longpressView.frame.origin toCoordinateFromView:self.view];
                [self.delegate longpressShowRouteDetails:location];
        }
    }
};

- (void)findNearestBusStop:(CLLocationCoordinate2D)location {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BusLocation" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSString* resultKey = [self getNearestBusStopKey:location fromDict:dict];
    NSArray* result = [dict objectForKey:resultKey];
    
    MQPointAnnotation* busStop = [[MQPointAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([[result objectAtIndex:1] doubleValue],[[result objectAtIndex:2] doubleValue]) title:[result objectAtIndex:0] subTitle:[self getBusServicesSubtitle:resultKey]];
    [self.mapView addAnnotation:busStop];
}

- (NSString*)getNearestBusStopKey:(CLLocationCoordinate2D)location fromDict:(NSDictionary*)dict {
    NSString* resultKey;
    double smallestdistance=10000000; //Threshold value
    
    for(NSString* busKey in [dict allKeys]){
        NSArray* busStopInfo = [dict objectForKey:busKey]; //Single mappoint
        CLLocationCoordinate2D newCoord = { [[busStopInfo objectAtIndex:1] doubleValue],[[busStopInfo objectAtIndex:2] doubleValue]};
        
        if(([BusRouter getDistance:newCoord To:location] <= smallestdistance) && ([BusRouter getDistance:newCoord To:location]!=0)){
            smallestdistance=[BusRouter getDistance:newCoord To:location];
            resultKey = busKey;
        }
    }
    return resultKey;
}

- (NSString*)getBusServicesSubtitle:(NSString*)busStop {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"BusStopServices" ofType:@"plist"];
    NSDictionary* tempDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray* busStopServices = [tempDict objectForKey:busStop];
    NSString* subtitle = @"Bus Services: ";
    
    for (int i = 0; i < [busStopServices count]; i++) {
        NSString* buses = [busStopServices objectAtIndex:i];
        subtitle = [subtitle stringByAppendingString:buses];
        if (i != ([busStopServices count] - 1)) {
            subtitle = [subtitle stringByAppendingString:@", "];
        }
    }
    return subtitle;
}

#pragma mark - annotation

//Load current annotations to be displayed
- (void)loadAnnotations:(NSArray *)annotationList {
    self.mapView.zoomEnabled = NO;
    [self resetAllAnnotations];

    for (EventViewController *thisController in annotationList) {
        if ([mapAnnotations addAnnotation:thisController.model]) {
            [eventControllers addObject:thisController];
        }
    }
    [self updateMapAnnotations: ^(id sender){
        self.mapView.zoomEnabled = YES;
    }];
}

- (void)addAnnotation:(EventViewController*)annotation {
    self.mapView.zoomEnabled = NO;
    if ([mapAnnotations addAnnotation:annotation.model]) {
        [eventControllers addObject:annotation];
    }
    [self updateMapAnnotations: ^(id sender){
        self.mapView.zoomEnabled = YES;
    }];
}


- (void)updateMapAnnotations:(void (^)(id)) block {
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (NSString *thisKey in mapAnnotations.locationAnnotationSet.allKeys) {
        MapAnnotationModel *firstModel = [[mapAnnotations.locationAnnotationSet objectForKey:thisKey] objectAtIndex:0];
        MapAnnotationModel *tempModel = [[MapAnnotationModel alloc] initWithCoordinate:firstModel.coordinate title:@" " subTitle:@" "];
        tempModel.event = firstModel.event;
        [self.mapView addAnnotation:tempModel];
    }
    block(self);
}

- (void)resetAllAnnotations {
    [annotationTables removeAllObjects];
    [mapAnnotations.locationAnnotationSet removeAllObjects];
    [eventControllers removeAllObjects];
}

-(MQAnnotationView*)mapView:(MQMapView *)aMapView viewForAnnotation:(id<MQAnnotation>)annotation {
    MQAnnotationView *pinView = nil;
    if ([annotation isKindOfClass:[MQUserLocation class]]) {
        ((MQUserLocation*)annotation).title = @"My Location";
        ((MQUserLocation*)annotation).subtitle = @"Test subtitle";
        ((MQUserLocation*)annotation).pulsingEnabled = YES;
        static NSString* identifier = @"UserlocationAnnotations";
        MQUserLocationView* customPinView = [[MQUserLocationView alloc]
                                             initWithAnnotation:annotation reuseIdentifier:identifier];
        UITapGestureRecognizer *testTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(testUserLocationTap:)];
        [testTap setNumberOfTapsRequired:1];
        [customPinView addGestureRecognizer:testTap];
        return customPinView;
    }
    else if ([annotation isKindOfClass:[MapAnnotationModel class]]) {
        static NSString* identifier = @"EventAnnotations";
        pinView = (MQAnnotationView *) [aMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!pinView) {
            // if an existing pin view was not available, create one
            MQPinAnnotationView* customPinView = [[MQPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:identifier];
            
            customPinView.pinColor = MQPinAnnotationColorRed;
            customPinView.animatesDrop = NO;
            customPinView.canShowCallout = NO;
            
            UIImage *pinImage = [UIImage imageNamed:@"just-pin2.png"];
            UIGraphicsBeginImageContext(CGSizeMake(28 ,40));
            [pinImage drawInRect:CGRectMake(0, 0, 28, 40)];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            customPinView.image = resizedImage;
            
            UITapGestureRecognizer *testTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(testAnnotationTap:)];
            [testTap setNumberOfTapsRequired:1];
            [customPinView addGestureRecognizer:testTap];
            
            pinView = customPinView;
        }
    }
    else {
        static NSString* identifier = @"Others";
        
        pinView = (MQAnnotationView *) [aMapView dequeueReusableAnnotationViewWithIdentifier:identifier];

        if (!pinView) {
            MQAnnotationView* customPinView = [[MQAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:identifier];

            customPinView.canShowCallout = YES;
            UIImage *busImage = [UIImage imageNamed:@"Bus"];
            UIGraphicsBeginImageContext(CGSizeMake(20 ,20));
            [busImage drawInRect:CGRectMake(0, 0, 20, 20)];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            customPinView.image = resizedImage;

            
            pinView = customPinView;
        }
        else {
            pinView.annotation = annotation;
        }
    }
    return pinView;
}

- (void)testUserLocationTap:(UIGestureRecognizer*)gesture {

    UIActionSheet *popupSheet = [[UIActionSheet alloc] initWithTitle:@"User Location"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Nearest Bus Stop", nil];
    
    popupSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [popupSheet showFromRect:gesture.view.frame inView:gesture.view.superview animated:YES];
}

- (void)testAnnotationTap:(UIGestureRecognizer*)gesture {
    MQPinAnnotationView *thisPoint = (MQPinAnnotationView*)gesture.view;
    MapAnnotationModel *thisPointModel = (MapAnnotationModel*)thisPoint.annotation;
    AnnotationViewController *tableAnnotations = [[AnnotationViewController alloc]init];
    tableAnnotations.allElements = [mapAnnotations getEventsForLocation:thisPointModel.event.venue];
    tableAnnotations.delegate = self;
    
    [annotationTables addObject:tableAnnotations];
    int numEvents = [tableAnnotations.allElements count];
    CGFloat height = numEvents * 40 + 5;
    tableAnnotations.contentSizeForViewInPopover = CGSizeMake(260, height + 10);
    testPopover = [[UIPopoverController alloc] initWithContentViewController:tableAnnotations];

    [testPopover presentPopoverFromRect:gesture.view.frame inView:gesture.view.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    NSLog(@"reached");
}


- (void)mapView:(MQMapView *)mapView annotationView:(MQAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([aView.annotation isKindOfClass:[MQUserLocation class]]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BusLocation" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];

        CLLocationCoordinate2D start = self.mapView.userLocation.coordinate;
        double smallestdistance=10000000;

        for(NSString* busKeym in [dict allKeys]){
            NSArray* busInfo=[dict objectForKey:busKeym]; //Single mappoint
            CLLocationCoordinate2D newCoord={ [[busInfo objectAtIndex:1] doubleValue],[[busInfo objectAtIndex:2] doubleValue]};
            
            NSString *busServices = [[NSBundle mainBundle] pathForResource:@"BusStopServices" ofType:@"plist"];
            NSDictionary *busStopServices = [[NSDictionary alloc] initWithContentsOfFile:busServices];
            NSArray* busLister=[busStopServices objectForKey:busKeym];
            NSMutableString* result=[[NSMutableString alloc]init];
            for(NSString* bus in busLister){
                [result appendString:bus];
                [result appendString:@","];
            }
            
            if(([BusRouter getDistance:newCoord To:start] <= smallestdistance) && ([BusRouter getDistance:newCoord To:start]!=0)){
                smallestdistance=[BusRouter getDistance:newCoord To:start];
                userLocationAnnotation = [[MQPointAnnotation alloc] initWithCoordinate:newCoord title:[busInfo objectAtIndex:0] subTitle:result];
            }
        }
        
        [self.mapView addAnnotation:userLocationAnnotation];
    }
    else {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
        [recognizer setNumberOfTapsRequired:1];
        recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
        [self.view.window addGestureRecognizer:recognizer];
        
        MQPointAnnotation *thisAnnotation = (MapAnnotationModel*)aView.annotation;
        [self showEventDetailView:((MapAnnotationModel*)thisAnnotation).event];
    }
}

- (void)didTapAccessory:(MapAnnotationModel*)modelTapped {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:recognizer];
    
    [self showEventDetailView: modelTapped.event];
}

- (void)showEventDetailView:(EventModel*)thisModel {
    for (EventViewController *thisController in eventControllers) {
        if ([thisController.model isEqual:thisModel]) {
            temp = thisController;
            break;
        }
    }
    
    [temp.view addSubview: temp.detailView];
    temp.detailView.attendBtn.hidden = NO;
    temp.detailView.fbBtn.hidden = NO;
    temp.detailView.routeBtn.hidden = NO;
    if (temp.isUserCreated) {
        temp.detailView.editBtn.hidden = NO;
    }
    temp.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentModalViewController:temp animated:YES];
}

- (void)dismissDetailController {
    [temp dismissModalViewControllerAnimated:YES];
    if ([testPopover isPopoverVisible]) {
        [testPopover dismissPopoverAnimated:NO];
    }
        
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:temp.view]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        if (![temp.view pointInside:location withEvent:nil]) {
            [self dismissModalViewControllerAnimated:YES];
            [self.view.window removeGestureRecognizer:sender];
        }
    }
}


#pragma mark - Overlays
- (MQOverlayView *)mapView:(MQMapView *)amapView viewForOverlay:(id <MQOverlay>)overlay {
    
    MQPolygon *polyOverlay = (MQPolygon *)overlay;
    MQPolygonView *polyView = [[MQPolygonView alloc] initWithPolygon:polyOverlay];
    MQCoordinateRegion r = MQCoordinateRegionForMapRect(polyOverlay.boundingMapRect);
    CGRect rect = [amapView convertRegion:r toRectToView:amapView];
    polyView.frame = rect;
    polyView.strokeColor = [UIColor redColor];
    polyView.fillColor = [UIColor clearColor];
    polyView.lineWidth = 2.0;
    [polyView setUserInteractionEnabled:YES];
    
    return polyView;
    
}

-(void)showList:(UITapGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
    }
}

- (void)goToUserLocation {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate];
    CLLocationCoordinate2D newCenter = self.mapView.centerCoordinate;
    MQCoordinateRegion thisRegion = self.mapView.region;
    MQCoordinateSpan thisMapSpan = thisRegion.span;
    CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(newCenter.latitude + thisMapSpan.latitudeDelta/2, newCenter.longitude - thisMapSpan.longitudeDelta/2);
    CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(newCenter.latitude - thisMapSpan.latitudeDelta/2, newCenter.longitude + thisMapSpan.longitudeDelta/2);
    if (topLeft.latitude > MAP_TOPLEFT_LATITUDE_LIMIT || topLeft.longitude < MAP_TOPLEFT_LONGITUDE_LIMIT) {
        [self.mapView setRegion:currentRegion animated:NO];
    }
    if (bottomRight.latitude < MAP_BOTTOMRIGHT_LATITUDE_LIMIT || bottomRight.longitude > MAP_BOTTOMRIGHT_LONGITUDE_LIMIT) {
        [self.mapView setRegion:currentRegion animated:NO];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
