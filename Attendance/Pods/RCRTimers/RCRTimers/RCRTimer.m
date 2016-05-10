//
//  RCRTimer.m
//
//  Created by Rich Robinson on 07/09/2014.
//  Copyright (c) 2014 Rich Robinson. All rights reserved.
//

#import "RCRTimer.h"

@import UIKit;

static NSTimeInterval const IntervalOffset = 0.02;

@interface RCRTimer ()

@property (nonatomic, readwrite) RCRTimerState state;
@property (nonatomic, copy) void (^block) (NSDate *firingDate);

@end

@implementation RCRTimer

- (instancetype)initWithBlock:(void (^) (NSDate *firingDate))block {
    self = [super init];
    
    if (self) {
        _state = RCRTimerStateNotStarted;
        _block = block;
        
        // Only do anything if we actually have a block of code to run
        if (_block) {
            if ([self automaticallySuspendAndResumeWithAppBackgroundStateChanges]) {
                [self registerForNotifications];
            }
            
            _state = RCRTimerStateRunning;
            [self runTimer];
        }
    }
    
    return self;
}

+ (instancetype)timerWithBlock:(void (^) (NSDate *firingDate))block {
    return [[self alloc] initWithBlock:block];
}

- (void)dealloc {
    [self stop];
    
    if ([self automaticallySuspendAndResumeWithAppBackgroundStateChanges]) {
        [self deregisterForNotifications];
    }
}

- (void)suspend {
    self.state = RCRTimerStateSuspended;
}

- (void)resume {
    self.state = RCRTimerStateRunning;
}

- (void)stop {
    // We access the ivar directly as this method is called from dealloc
    _state = RCRTimerStateStopped;
}

#pragma mark - Abstract methods that must be overridden by subclasses

- (NSDate *)nextFireDate {
    // Abstract implementation
    return nil;
}

#pragma mark - Methods that may optionally overridden by subclasses

- (BOOL)applyOffset {
    // By default we apply the offset to each firing of the timer
    return YES;
}

- (BOOL)automaticallySuspendAndResumeWithAppBackgroundStateChanges {
    // By default we suspend and resume with app background state changes
    return YES;
}

#pragma mark - Private methods

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)deregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self resume];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self suspend];
}

- (void)runTimer {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self intervalUntilNextFireDate] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        if (self.state == RCRTimerStateRunning || self.state == RCRTimerStateSuspended) {

            // If we're running we call the block, if we're suspended we skip this (but continue to call runTimer)
            if (self.state == RCRTimerStateRunning) {
                self.block([NSDate date]);
            }
            
            // We keep the timer running by repeatedly calling runTimer (until we're no longer running or suspended)
            [self runTimer];
        }
        else {
            // We're not in a running or suspended state, so we terminate the timer by no longer calling runTimer
            self.block = nil;
        }
  
    });
}

- (NSTimeInterval)intervalUntilNextFireDate {
    NSTimeInterval interval = [[self nextFireDate] timeIntervalSinceDate:[NSDate date]];
    
    if ([self applyOffset]) {
        interval += IntervalOffset;
    }

    return interval;
}

@end
