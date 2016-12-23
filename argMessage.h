//
//  argMessage.h
//  Podium
//
//  Created by Arjun Vasan on 2/27/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface argMessage : NSObject

@property NSString *messageContent;
@property BOOL completed;
@property NSString *messageID;
@property NSNumber *echoCount;
@property (readonly) NSDate *creationDate;

@end
