//
//  HYPTimerControl.h
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYPTimerControl : UIControl
@property (nonatomic) BOOL showSubtitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSTimeInterval minutesLeft;
@property (nonatomic) NSTimeInterval seconds;

- (id)initShowingSubtitleWithFrame:(CGRect)frame;
- (void)startTimer;
- (void)stopTimer;
@end
