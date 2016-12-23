//
//  argMainViewController.h
//  Podium
//
//  Created by Arjun Vasan on 3/3/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface argMainViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *mainScroll;

@property (weak, nonatomic) IBOutlet MKMapView *podiumMap;

@end
