//
//  argDetailViewController.m
//  Podium
//
//  Created by Arjun Vasan on 3/1/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import "argDetailViewController.h"
//#import "argCommentTableViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface argDetailViewController ()

//@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property NSMutableArray *commentItems;
@property NSString *commentOffset;
@property NSUInteger totalOffset;

@end

@implementation argDetailViewController

//@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //NSLog(@"hello from detail view controller");
    }
    return self;
}

- (IBAction)viewMessage:(UIStoryboardSegue *)segue
{

    NSLog(@"hello from segue");

}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self.scrollBox setContentSize:CGSizeMake(320, 400)];
    
    self.totalOffset = 10;
    self.messageBox.text = self.messageItem.messageContent;

    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
}

- (void)commentQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"PodiumBetaComment"];
    
    [query whereKey:@"messageID" equalTo:self.messageItem.messageID];
    
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            

            for (PFObject *object in objects) {
                [self addComment:object[@"comment"] atOffset:[objects indexOfObject:object]];
                
                //NSLog(@"hello from success land");
                //NSLog(@"%@", object);
                
                //argMessage *message = [[argMessage alloc] init];
                //message.messageContent = object[@"message"];
                //message.messageID = object[@"objectId"];
                //[self.messageItems addObject:message];
                //[self.tableView reloadData];
                
            }
            
            CGRect contentRect = CGRectZero;
            for (UIView *view in self.scrollBox.subviews)
                contentRect = CGRectUnion(contentRect, view.frame);
            self.scrollBox.contentSize = contentRect.size;
            self.scrollBox.layer.zPosition = -1;
            
            
        }else {
            NSLog(@"hello from failure land");
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn:");
    
    PFObject *testObject = [PFObject objectWithClassName:@"PodiumBetaComment"];
    if (textField.text.length > 1) {
        testObject[@"comment"] = textField.text;
        testObject[@"messageID"] = self.messageItem.messageID;
        [testObject saveInBackground];
        
        [textField setText:@""];
        
    }
    [textField resignFirstResponder];
    
    [self commentQuery];
    
    

    return YES;
}

- (void)addComment:(NSString *)textContent atOffset:(NSUInteger)offsetCount {
    
    CGSize size = [textContent sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0] constrainedToSize:CGSizeMake(300, 99999) lineBreakMode:UILineBreakModeWordWrap];
    
    
    
    
    
    

    
    
    
    //NSUInteger offsetTotal;
    
    
    //offsetTotal = (offsetCount) * 50;
    //offsetTotal += 10;
    
    float scrollSize = 400;
    if ((float)self.totalOffset > 300) {
        scrollSize = 100 + (float)self.totalOffset;
    }
    
    NSLog(@"row: %lu", (unsigned long)self.totalOffset);
    
    //CGRect viewRect = CGRectMake(0,260,312,305);
    
    //CGRect paddingRect = CGRectMake(0, (float)offsetTotal, 10, 40);
    
    
    
    UILabel* myView = [[UILabel alloc] init];
    
    myView.numberOfLines=0;
    myView.textAlignment   = UITextAlignmentLeft;
    myView.font=[UIFont fontWithName:@"Helvetica" size:15.0];
    
    

    myView.frame=CGRectMake(10, (float)self.totalOffset, 300, size.height);  //set the frame according to your need
    myView.text=textContent;
    [self.scrollBox addSubview:myView];
    self.totalOffset += (NSUInteger)size.height + 20;
    
    
    
    
    //[self.scrollBox setFrame:viewRect];
    
    //[self.scrollBox setContentSize:CGSizeMake(320, scrollSize)];
    
    
    //UIView* paddingView = [[UIView alloc] initWithFrame:paddingRect];
    //[paddingView setBackgroundColor:UIColorFromRGB(0x99CCFF)];
    //[myView setBackgroundColor:UIColorFromRGB(0xccffcc)];
    
    //[myView setText:textContent];
    //[myView setEnabled:NO];
    //[self.scrollBox addSubview:paddingView];
    //[self.scrollBox addSubview:myView];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    self.commentBox.delegate = self;
    [self commentQuery];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.scrollBox = nil;
    self.commentBox.delegate = nil;
    self.commentBox = nil;
    self.messageBox = nil;
    self.commentItems = nil;
    self.commentOffset = nil;
    
}

@end
