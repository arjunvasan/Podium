//
//  argComment.h
//  Podium
//
//  Created by Arjun Vasan on 3/2/14.
//  Copyright (c) 2014 Arjun Vasan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface argComment : NSObject

@property NSString *commentText;
@property NSString *messageID;
@property (readonly) NSDate *creationDate;

@end
