//
//  argPodiumViewController.m
//  Podium
//
//  Created by Arjun Vasan on 2/27/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import "argPodiumViewController.h"
#import "argMessage.h"
#import "argAddMessageViewController.h"
#import "argDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>


@interface argPodiumViewController ()

@property NSMutableArray *messageItems;
@property argDetailViewController *detailController;



@end

@implementation argPodiumViewController
@synthesize locationManager = locationManager;

- (void)loadInitialData {
    [self.messageItems removeAllObjects];
    argMessage *message1= [[argMessage alloc] init];
    message1.messageContent = @"Welcome to Podium";
    message1.messageID = @"defaultID";
    [self.messageItems addObject:message1];
    message1 = nil;

    
}

- (void)updatePosts {
    CLLocation *location = locationManager.location;
    CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    
    CGFloat kilometers = 0.25f;
    PFQuery *query = [PFQuery queryWithClassName:@"PodiumBetaObject"];
    [query setLimit:10];
    
    [query whereKey:@"location"
       nearGeoPoint:geoPoint withinKilometers:kilometers];
    
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self loadInitialData];
            for (PFObject *object in objects) {
                NSLog(@"hello from success land");
                NSLog(@"%@", object);
                
                argMessage *message = [[argMessage alloc] init];
                message.messageContent = object[@"message"];
                message.messageID = object.objectId;
                [self.messageItems addObject:message];
                [self.tableView reloadData];
                
            }
        }else {
            NSLog(@"hello from failure land");
        }
    }];
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        //NSLog(@"latitude %+.6f, longitude %+.6f\n",
        //      location.coordinate.latitude,
        //      location.coordinate.longitude);
        [self updatePosts];
    }
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 100; // meters
    
    [locationManager startUpdatingLocation];
}


- (IBAction)unwindPodium:(UIStoryboardSegue *)segue
{
    argAddMessageViewController *source = [segue sourceViewController];
    argMessage *message = source.messageItem;
    message.messageID = @"noneyet";
    if (message != nil) {
        [self.messageItems addObject:message];
        [self.tableView reloadData];
        
        CLLocation *location = locationManager.location;
        CLLocationCoordinate2D coordinate = [location coordinate];
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        
        PFObject *testObject = [PFObject objectWithClassName:@"PodiumBetaObject"];
        testObject[@"message"] = message.messageContent;
        testObject[@"location"] = geoPoint;
        [testObject saveInBackground];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageItems = [[NSMutableArray alloc] init];
    [self startStandardUpdates];
    [self loadInitialData];
    
    [self startTimer];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.messageItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...

    argMessage *messageItem = [self.messageItems objectAtIndex:indexPath.row];
    cell.textLabel.text = messageItem.messageContent;

    
    if (messageItem.completed) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    return cell;
}




#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    NSLog(@"hello from prepare for segue");
    self.detailController = [segue destinationViewController];

}


- (void) startTimer {
    [NSTimer scheduledTimerWithTimeInterval:15
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) tick:(NSTimer *) timer {
    NSLog(@"timer tick");
    [self updatePosts];
    
}
 



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    argMessage *tappedMessage = [self.messageItems objectAtIndex:indexPath.row];
    tappedMessage.completed = YES;
    //self.selectedMessage = tappedMessage;
    self.detailController.messageItem = tappedMessage;
    NSLog(@"hello from table click");
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}



- (void)dealloc
{
    self.messageItems = nil;
    self.detailController = nil;
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    self.selectedMessage = nil;
}

@end
