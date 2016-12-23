//
//  argFeedViewController.m
//  Podium
//
//  Created by Arjun Vasan on 3/12/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import "argFeedViewController.h"
#import <Parse/Parse.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define k_KEYBOARD_OFFSET 80.0

@interface argFeedViewController ()

@property NSUInteger totalOffset;
@property NSUInteger commentOffset;
@property UITapGestureRecognizer *singleFingerTap;
@property UIScrollView *detailScrollView;
@property double cachedY;
@property double cachedH;
@property CGPoint cachedOffset;
@property NSString *tappedID;
@property UITextView *addComment;
@property UIButton *doneButton;
@property UIButton *btnTwo;

@property BOOL shouldHideStatusBar;


@end

@implementation argFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)drawPosts {

    PFQuery *query = [PFQuery queryWithClassName:@"PodiumBetaObject"];
    [query setLimit:100];
    
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            for (PFObject *object in objects) {
                NSLog(@"hello from success land");
                NSLog(@"%@", object);
                
                CGSize size = [object[@"message"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:21.0] constrainedToSize:CGSizeMake(300, 99999) lineBreakMode:UILineBreakModeWordWrap];
                
                
                float scrollSize = 400;
                if ((float)self.totalOffset > 300) {
                    scrollSize = 100 + (float)self.totalOffset;
                }
                
                NSLog(@"row: %lu", (unsigned long)self.totalOffset);
                
                //CGRect viewRect = CGRectMake(0,260,312,305);
                
                //CGRect paddingRect = CGRectMake(0, (float)offsetTotal, 10, 40);
                
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleSingleTap:)];
                
                
                UILabel* myView = [[UILabel alloc] init];
                
                myView.numberOfLines=0;
                myView.textAlignment = UITextAlignmentCenter;
                
                myView.textColor = [UIColor whiteColor];
                myView.font=[UIFont fontWithName:@"Helvetica" size:21.0];
                
                myView.backgroundColor = [UIColor lightGrayColor];
                
                myView.layer.borderColor = [UIColor whiteColor].CGColor;

                myView.layer.borderWidth = 0.0;
                
                myView.shadowColor = [UIColor blackColor];
                myView.shadowOffset = CGSizeMake(1, 1);
                myView.layer.masksToBounds = NO;
                
                [myView.layer setValue: object.objectId forKey: @"messageID"];
                myView.userInteractionEnabled = YES;
                
                
                
                double minHeight = 200;
                if (size.height+10 > minHeight) {
                    minHeight = size.height+10;
                }
                
                
                myView.frame=CGRectMake(5, (float)self.totalOffset, 310, minHeight);  //set the frame according to your need
                

                myView.text=object[@"message"];
                
                [myView addGestureRecognizer:tapGesture];
                
                
                //[singleFingerTap release];
                
                
                
                [self.feedScroller addSubview:myView];
                
                self.totalOffset += (NSUInteger)minHeight + 5;
                
                
            }
            
            CGRect contentRect = CGRectZero;
            for (UIView *view in self.feedScroller.subviews)
                contentRect = CGRectUnion(contentRect, view.frame);
            self.feedScroller.contentSize = contentRect.size;
            //self.feedScroller.layer.zPosition = -1;
            
            
        }else {
            NSLog(@"hello from failure land");
        }
    }];
}


- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

- (void)addComment:(NSString *)textContent atOffset:(NSUInteger)offsetCount {
    
    CGSize size = [textContent sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0] constrainedToSize:CGSizeMake(300, 99999) lineBreakMode:UILineBreakModeWordWrap];
    
    
    
    float scrollSize = 400;
    if ((float)self.commentOffset > 300) {
        scrollSize = 100 + (float)self.commentOffset;
    }
    
    NSLog(@"row: %lu", (unsigned long)self.commentOffset);
    
    
    UILabel* myView = [[UILabel alloc] init];
    
    myView.numberOfLines=0;
    myView.textAlignment   = UITextAlignmentLeft;
    myView.font=[UIFont fontWithName:@"Helvetica" size:15.0];
    
    //myView.backgroundColor = [UIColor lightGrayColor];
    
    
    
    myView.frame=CGRectMake(40, (float)self.commentOffset, 270, size.height);  //set the frame according to your need
    myView.text=textContent;
    [self.detailScrollView addSubview:myView];
    self.commentOffset += (NSUInteger)size.height + 10;
    
}

- (void)commentQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"PodiumBetaComment"];
    
    [query whereKey:@"messageID" equalTo:self.tappedID];
    
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            
            for (PFObject *object in objects) {
                [self addComment:object[@"comment"] atOffset:[objects indexOfObject:object]];
                
                
            }
            
            CGRect contentRect = CGRectZero;
            for (UIView *view in self.detailScrollView.subviews)
                contentRect = CGRectUnion(contentRect, view.frame);
            self.detailScrollView.contentSize = contentRect.size;
            self.commentOffset = 220;
            //self.det.layer.zPosition = -1;
            
            
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
        testObject[@"messageID"] = self.tappedID;
        [testObject saveInBackground];
        
        [textField setText:@""];
        
    }
    [textField resignFirstResponder];
    
    [self commentQuery];
    
    
    
    return YES;
}

//The event handling method

- (void)buttonTap
{
    PFObject *testObject = [PFObject objectWithClassName:@"PodiumBetaComment"];
    if (self.addComment.text.length > 1) {
        testObject[@"comment"] = self.addComment.text;
        testObject[@"messageID"] = self.tappedID;
        [testObject saveInBackground];
        
        [self.addComment setText:@""];
        
    }
    [self.addComment resignFirstResponder];
    
    [self commentQuery];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    UILabel* labelview = recognizer.view;
    NSLog(labelview.text);
    NSLog([labelview.layer valueForKey:@"messageID"]);
    
    
    if (self.detailScrollView.alpha == 1.0) {
        self.detailScrollView.alpha = 0.0;
        [self.feedScroller addSubview:labelview];
        
        [labelview setFrame:CGRectMake(5, self.cachedY, 310, self.cachedH)];
        
        
        [UIView animateWithDuration:(0.2) animations:^{
            
            [self.feedScroller setContentOffset:self.cachedOffset];
        } completion:^(BOOL finished){
            if(finished) {
                [labelview setBackgroundColor:[UIColor lightGrayColor]];
                [self setPrefersStatusBarHidden:NO];
            }
        }];
    }else {
        if ([recognizer.view isKindOfClass:UILabel.class]) {
            //[[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            CGRect detailRect = CGRectMake(0, 5, 320, 800);
            self.detailScrollView = [[UIScrollView alloc] initWithFrame:detailRect];
            self.detailScrollView.layer.zPosition = 10;
            self.detailScrollView.backgroundColor = [UIColor whiteColor];
            
            self.tappedID = [labelview.layer valueForKey:@"messageID"];
            
            self.cachedY = labelview.frame.origin.y;
            self.cachedH = labelview.frame.size.height;
            self.cachedOffset = [self.feedScroller contentOffset];
            
            
            [UIView animateWithDuration:(0.40) animations:^{
                [self commentQuery];

                [labelview setBackgroundColor:UIColorFromRGB(0x067AB5)];
                
                double minHeight = 200;
                if (labelview.frame.size.height > minHeight) {
                    minHeight = labelview.frame.size.height;
                }

                [self.feedScroller setContentOffset:CGPointMake(0, self.cachedY-5)];
                self.detailScrollView.alpha = 1.0;
                [self setPrefersStatusBarHidden:YES];
                
                
            } completion:^(BOOL finished){
                double minHeight = 200;
                if (labelview.frame.size.height > minHeight) {
                    minHeight = labelview.frame.size.height;
                }
                if(finished) {

                    [self.detailScrollView addSubview:labelview];
                    [[self.feedScroller superview] addSubview:self.detailScrollView];
                    [labelview setFrame:CGRectMake(5, 0, 310, minHeight)];
                    [self.detailScrollView addSubview:self.addComment];
                    [self.detailScrollView addSubview:self.doneButton];
                    
                    self.btnTwo = [UIButton buttonWithType:UIButtonTypeCustom];
                    self.btnTwo.frame = CGRectMake(275, 3, 40, 40);
                    [self.btnTwo setTitle:@"vc2:v1" forState:UIControlStateNormal];
                    [self.btnTwo addTarget:self action:@selector(echoPost) forControlEvents:UIControlEventTouchUpInside];
                    UIImage *btnImage = [UIImage imageNamed:@"speaker2.png"];
                    [self.btnTwo setImage:btnImage forState:UIControlStateNormal];
                    [self.btnTwo setAlpha:0.4];
                    //btnTwo.backgroundColor = [UIColor greenColor];
                    [self.detailScrollView addSubview:self.btnTwo];


                    
                    
                }
            }];
            
            
        }
    }
    

    NSLog(@"hello from tapped view");
}

- (void)echoPost {
    [self.btnTwo setHighlighted:YES];
    
    if ([self.btnTwo alpha] == 1.0) {
        NSLog(@"alpha is one");
        [self.btnTwo setAlpha:0.4];
    }else {
        [self.btnTwo setAlpha:1.0];
    }
    
    

    
}

- (void)keyboardWillAppear {
    [self.detailScrollView setContentOffset:CGPointMake(0, 240)];
    
    NSLog(@"hello from keyboard");
}

- (void)keyboardWillDisappear {
    [self.detailScrollView setContentOffset:CGPointMake(0, 0)];
    
    NSLog(@"hello from keyboard");
}


- (void)setPrefersStatusBarHidden:(BOOL)hidden {
    self.shouldHideStatusBar = hidden;
    
    // Don't call this on iOS 6 or it will crash since the
    // `setNeedsStatusBarAppearanceUpdate` method doesn't exist
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    // [self setNeedsStatusBarAppearanceUpdate]; // (if Xcode 5, use this)
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
    
    
    CGRect commentRect = CGRectMake(0, 528, 280, 40);
    
    self.addComment = [[UITextView alloc] initWithFrame:commentRect];
    self.addComment.backgroundColor = [UIColor redColor];
    self.addComment.keyboardAppearance = UIKeyboardAppearanceDark;
    
    CGRect doneRect = CGRectMake(280, 528, 40, 40);
    self.doneButton = [[UIButton alloc] initWithFrame:doneRect];
    [self.doneButton setTitle:@"go" forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [UIColor grayColor];
    [self.doneButton addTarget:self action:@selector(buttonTap) forControlEvents:UIControlEventTouchDown];
    
    
    //self.addComment.delegate = self;
    //self.addComment.returnKeyType = UIReturnKeyDone;
    //[self.addComment setEnablesReturnKeyAutomatically:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldHideStatusBar = NO;
    self.feedScroller.contentSize = CGSizeMake(320,1000);
    self.detailScrollView.alpha = 0.0;
    self.detailScrollView.contentSize = CGSizeMake(320,1000);

    [self.feedScroller addSubview:self.detailScrollView];
    self.totalOffset = 30;
    self.commentOffset = 220;
    
    //[UIButton buttonWithType:UIButtonTypeSystem];
    
    
    
    
    [self drawPosts];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    self.addComment.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
