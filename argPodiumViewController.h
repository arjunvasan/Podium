//
//  argPodiumViewController.h
//  Podium
//
//  Created by Arjun Vasan on 2/27/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "argMessage.h"

@interface argPodiumViewController : UITableViewController
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) argMessage *selectedMessage;

- (IBAction)unwindPodium:(UIStoryboardSegue *)segue;

@end
