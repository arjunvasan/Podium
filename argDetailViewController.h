//
//  argDetailViewController.h
//  Podium
//
//  Created by Arjun Vasan on 3/1/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "argMessage.h"

@interface argDetailViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextView *messageBox;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollBox;
@property (strong, nonatomic) IBOutlet UITextField *commentBox;


@property argMessage *messageItem;

@end
