 //
//  argSplashController.m
//  Podium
//
//  Created by Arjun Vasan on 3/2/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import "argSplashController.h"

@interface argSplashController ()

@end

@implementation argSplashController

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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self performSelector:@selector(loadAuthenticateViewController)
               withObject:nil
               afterDelay:2.5];
    

	// Do any additional setup after loading the view.
}

-(void)loadAuthenticateViewController
{
    [self performSegueWithIdentifier:@"SplashLogin" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
