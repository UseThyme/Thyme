//
//  HYPAlarm.m
//  Thyme
//
//  Created by Elvis Nunez on 02/12/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPAlarm.h"

@implementation HYPAlarm

#define A_DEFAULT_TEXT @"------------------SWIPE CLOCKWISE TO SET TIMER------------------"
#define B_DEFAULT_TEXT @"------------------RELEASE TO SET TIMER------------------"
#define C_DEFAULT_TEXT @"------------------YOUR MEAL WILL BE READY IN------------------"

- (instancetype)initWithNotification:(UILocalNotification *)notification
{
    self = [super init];
    if (self) {

    }
    return self;
}

+ (NSString *)messageForSetAlarm
{
    return A_DEFAULT_TEXT;
}

+ (NSString *)messageForReleaseToSetAlarm
{
    return B_DEFAULT_TEXT;
}

+ (NSString *)messageForCurrentAlarm
{
    return C_DEFAULT_TEXT;
}

@end
