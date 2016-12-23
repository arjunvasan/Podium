//
//  argAddMessageViewController.m
//  Podium
//
//  Created by Arjun Vasan on 2/27/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import "argAddMessageViewController.h"


@interface argAddMessageViewController ()
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation argAddMessageViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.doneButton) return;
    if (self.textField.text.length > 0) {
        self.messageItem = [[argMessage alloc] init];
        self.messageItem.messageContent = self.textField.text;
        self.messageItem.completed = NO;
    }
}

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

    NSLog(@"hello from add message view controller");
    
    
    [self.textField becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.textField = nil;
    self.doneButton = nil;
    self.messageItem = nil;
}

@end
