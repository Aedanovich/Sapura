//
//  RCRTimeLabel.m
//
//  Created by Rich Robinson on 29/08/2014.
//  Copyright (c) 2014 Rich Robinson. All rights reserved.
//

#import "RCRTimeLabel.h"

#import "RCRSecondChangeTimer.h"

@interface RCRTimeLabel ()

@property (nonatomic, strong) RCRSecondChangeTimer *secondChangeTimer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation RCRTimeLabel

// Cater for initialization via code
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

// Cater for initialization via a decoder (specifically, we're catering for use of RCRTimeLabel via Interface Builder)
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)dealloc {
    [_secondChangeTimer stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];    
}

- (void)awakeFromNib {
    // Clear any sample text that may have been set via Interface Builder
    self.text = @"";
}

- (void)setup {
    // Provide some default values for our dateStyle and timeStyle propeties
    _dateStyle = NSDateFormatterNoStyle;
    _timeStyle = NSDateFormatterShortStyle;
    
    // Setup our date formatter with our default styles
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateStyle = _dateStyle;
    _dateFormatter.timeStyle = _timeStyle;

    // Start the second change timer
    _secondChangeTimer = [RCRSecondChangeTimer timerWithBlock:^ (NSDate *firingDate) {
        [self timerFired];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)timerFired {
    [self updateTextInMainQueue];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // Fire the timer when we enter the foreground, too, to ensure the time updates immediately and there isn't a (albiet brief) period where the label is showing the time the app was last used instead of the current time
    [self updateTextInMainQueue];
}

- (void)updateTextInMainQueue {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateText];
    });
}

- (void)updateText {
    self.text = [self.dateFormatter stringFromDate:[NSDate date]];
}

// Custom setters that pass values down to the underlying dataFormatter in addition to setting the property:

- (void)setDateStyle:(NSDateFormatterStyle)dateStyle {
    _dateStyle = dateStyle;
    
    self.dateFormatter.dateStyle = _dateStyle;
    
    // Update the text immediately to reflect the change
    [self updateTextInMainQueue];
}

- (void)setTimeStyle:(NSDateFormatterStyle)timeStyle {
    _timeStyle = timeStyle;
    
    self.dateFormatter.timeStyle = _timeStyle;
    
    // Update the text immediately to reflect the change
    [self updateTextInMainQueue];
}

@end
