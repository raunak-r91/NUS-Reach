/*
 This class computes the route between two given points.
 One point needs to be the user location and the other point can be either a building name
 or the location destination coordinate
 It has a class method that computes the distance between two given location
 coordinates as the coordinates are in longitude & latitude using CLLocation.
 It has a class metho to find the nearest builidng from a given location coordinate.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BusRouter : NSObject

//EFFECTS: initializes the internal dictionaries by reading all the plist files
- (id)init;

//EFFECTS: computes the route between the two points and returns in the form of a dictionary
//  Keys in the dictionary: "startPoint", "endPoint", "changePoint", "busNumber", "stopNumbers"
- (NSDictionary*)routeBetweenPoints:(CLLocationCoordinate2D)start Venue:(NSString*)end;

//EFFECTS: computes the route between the two points and returns in the form of a dictionary
//  Keys in the dictionary: "startPoint", "endPoint", "changePoint", "busNumber", "stopNumbers"
- (NSDictionary*)routeBetweenPoints:(CLLocationCoordinate2D)start End:(CLLocationCoordinate2D)end;

//EFFECTS: returns the nearest building string based on the location coordinates provided
+ (NSString*)findNearestBuilding:(CLLocationCoordinate2D)location;

//EFFECTS: returns the double distance between two given coordinates
+ (double)getDistance:(CLLocationCoordinate2D)a To:(CLLocationCoordinate2D)b;

@end
