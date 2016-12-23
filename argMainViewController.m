//
//  argMainViewController.m
//  Podium
//
//  Created by Arjun Vasan on 3/3/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import "argMainViewController.h"
#import <Parse/Parse.h>

@interface argMainViewController ()

@property BOOL setInitialLocation;


@end

@implementation argMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

const double PIx = 3.141592653589793;
const double RADIO = 6371; // Mean radius of Earth in Km

double convertToRadians(double val) {
    
    return val * PIx / 180;
}

-(double)kilometresBetweenPlace1:(CLLocationCoordinate2D) place1 andPlace2:(CLLocationCoordinate2D) place2 {
    
    double dlon = convertToRadians(place2.longitude - place1.longitude);
    double dlat = convertToRadians(place2.latitude - place1.latitude);
    
    double a = ( pow(sin(dlat / 2), 2) + cos(convertToRadians(place1.latitude))) * cos(convertToRadians(place2.latitude)) * pow(sin(dlon / 2), 2);
    double angle = 2 * asin(sqrt(a));
    
    return angle * RADIO;
}



- (void)displayPosts {

    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.podiumMap.userLocation.coordinate.latitude longitude:self.podiumMap.userLocation.coordinate.longitude];
    
    
    CGFloat kilometers = 30.0f;
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"PodiumBetaObject"];
    [query setLimit:100];
    
    [query whereKey:@"location"
       nearGeoPoint:geoPoint withinKilometers:kilometers];
    
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            for (PFObject *object in objects) {
                NSLog(@"hello from success land");

                
                MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
                
                PFGeoPoint *nPoint = object[@"location"];
                
                myAnnotation.coordinate = CLLocationCoordinate2DMake(nPoint.latitude, nPoint.longitude);
                
                

                //CLLocation *location1 = [[CLLocation alloc] initWithLatitude:myAnnotation.coordinate.latitude longitude:myAnnotation.coordinate.longitude];
                //CLLocationDistance meters = [location1 distanceFromLocation:self.podiumMap.userLocation];
                
                //NSLog([@(meters) stringValue]);
                //NSLog([@(location1.coordinate.latitude) stringValue]);
                //NSLog([@(location1.coordinate.longitude) stringValue]);
                //NSLog([@(self.podiumMap.userLocation.coordinate.latitude) stringValue]);
                //NSLog([@(self.podiumMap.userLocation.coordinate.longitude) stringValue]);
                
                double km = [self kilometresBetweenPlace1:myAnnotation.coordinate andPlace2:self.podiumMap.userLocation.coordinate];
                
                myAnnotation.title = object[@"tagstring"];
                if (km > 0.25) {
                    
                    myAnnotation.subtitle = @"sorry, please get closer to view message";
                }else {
                    //myAnnotation.subtitle = object[@"tagstring"];
                    myAnnotation.subtitle = object[@"message"];
                    
                }
                
                
                
                
                [self.podiumMap addAnnotation:myAnnotation];
                
                //location1 = nil;
                nPoint = nil;
                //myAnnotation.subtitle = @"Best Pizza in Town";
                
                //argMessage *message = [[argMessage alloc] init];
                //message.messageContent = object[@"message"];
                //message.messageID = object.objectId;
                //[self.messageItems addObject:message];
                //[self.tableView reloadData];
                
            }
        }else {
            NSLog(@"hello from failure land");
        }
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.setInitialLocation == NO) {
        MKCoordinateRegion region;
        region.center = self.podiumMap.userLocation.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 0.01; // Change these values to change the zoom
        span.longitudeDelta = 0.01;
        region.span = span;
        
        [self.podiumMap setRegion:region animated:YES];
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.podiumMap.userLocation.coordinate radius:250];
        [self.podiumMap addOverlay:circle];
        
        /*
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(37.304838, -121.989805);
        myAnnotation.title = @"Matthews Pizza";
        myAnnotation.subtitle = @"Best Pizza in Town";
        
        MKPointAnnotation *myAnnotation2 = [[MKPointAnnotation alloc] init];
        myAnnotation2.coordinate = CLLocationCoordinate2DMake(37.363448, -122.066828);
        myAnnotation2.title = @"Arjun is the best";
        myAnnotation2.subtitle = @"of all time";
         */
        
        
        
        //[self.podiumMap addAnnotation:myAnnotation];
        //[self.podiumMap addAnnotation:myAnnotation2];
        
        
        self.setInitialLocation = YES;
        [self displayPosts];
        
        
    }
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    [circleView setFillColor:[UIColor greenColor]];
    //[circleView setStrokeColor:[UIColor blackColor]];
    
    
    
    [circleView setAlpha:0.2f];
    return circleView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.setInitialLocation = NO;
    self.podiumMap.delegate = self;
    [self.podiumMap.userLocation addObserver:self
                                forKeyPath:@"location"
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                   context:nil];
    
	// Do any additional setup after loading the view.
}

- (void)dealloc
{
    [self.podiumMap.userLocation removeObserver:self
                                     forKeyPath:@"location"];
    self.podiumMap.delegate = nil;
    self.podiumMap = nil;
    self.mainScroll = nil;
    
}

- (void)viewDidUnload {
    [self.podiumMap.userLocation removeObserver:self
                                    forKeyPath:@"location"];
    self.podiumMap.delegate = nil;
    self.podiumMap = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
