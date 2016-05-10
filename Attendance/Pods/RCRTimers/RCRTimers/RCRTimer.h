//
//  RCRTimer.h
//
//  Created by Rich Robinson on 07/09/2014.
//  Copyright (c) 2014 Rich Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @typedef RCRTimerState
 @brief The possible states of an <tt>RCRTimer</tt> instance.
 @constant RCRTimerStateNotStarted The timer has not yet been started.
 @constant RCRTimerStateRunning The timer is currently running (having been started, or resumed after being suspended).
 @constant RCRTimerStateSuspended The timer is currently suspended (and may be resumed).
 @constant RCRTimerStateStopped The timer is stopped and can no longer be resumed.
 */
typedef NS_ENUM(NSInteger, RCRTimerState) {
    /// The timer has not yet been started.
    RCRTimerStateNotStarted,
    
    /// The timer is currently running (having been started, or resumed after being suspended).
    RCRTimerStateRunning,
    
    /// The timer is currently suspended (and may be resumed).
    RCRTimerStateSuspended,
    
    /// The timer is stopped and can no longer be resumed.
    RCRTimerStateStopped
};

/**
 Abstract superclass of all timers.

 This class is abstract and should not be instantiated directly - instead, concrete subclasses such as <tt>RCRSecondChangeTimer</tt> and <tt>RCRMinuteChangeTimer</tt> should be used. Refer to these classes for examples of subclassing <tt>RCRTimer</tt>.

 Subclasses must override all methods listed as abstract below.
 */
@interface RCRTimer : NSObject

/**
 Initializes a new timer.
 
 @param block The block to execute when the timer fires. The exact date/time the timer fired is passed into the block via the <tt>firingDate</tt> parameter.
 */
- (instancetype)initWithBlock:(void (^) (NSDate *firingDate))block NS_DESIGNATED_INITIALIZER;

/**
 Returns a newly-initialized timer. See <tt>initWithBlock:</tt> for details.
 */
+ (instancetype)timerWithBlock:(void (^) (NSDate *firingDate))block;

/**
 The current state of the timer. Refer to <tt>RCRTimerState</tt> for the list of possible states.
 */
@property (nonatomic, readonly) RCRTimerState state;

/**
 Suspends the timer, preventing it from firing again until <tt>resume</tt> is called.
 */
- (void)suspend;

/**
 Resumes a suspended timer.
 */
- (void)resume;

/**
 Stops the timer, preventing it from firing any more.

 Note that there is no way to restart a stopped timer - a new timer should be created instead to achieve the same effect.
 */
- (void)stop;

#pragma mark - Abstract methods that must be overridden by subclasses

/**
 Abstract. Must be overridden by subclasses in order provide the date/time at which the timer should next fire (relative to 'now').
 */
- (NSDate *)nextFireDate;

#pragma mark - Methods that may optionally overridden by subclasses

/**
 May optionally be overridden by subclasses in order to specify whether a small offset should be applied to date/time at which the timer fires. For example, this may be used by a timer that fires at the start of each second to help ensure it is definitely into the second in question, and is not firing at the end of the previous one. The default implementation in this class returns <tt><YES/tt>.
 */
- (BOOL)applyOffset;

/**
 May optionally be overridden by subclasses in order to specify whether the timer should suspend and resume automatically as the running app goes to the background and comes to the foreground. This can be used to prevent a timer from firing while the app is in the background and the effect of this being seen at the arbitrary time that the app next comes to the foreground (which may well be when we do not want the effect to occur). The default implementation in this class returns <tt><YES/tt> - a 'background timer' subclass implementation may choose to do the opposite.
 */
- (BOOL)automaticallySuspendAndResumeWithAppBackgroundStateChanges;

@end
