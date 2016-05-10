//
//  RCRMinuteChangeTimer.m
//
//  Created by Rich Robinson on 07/09/2014.
//  Copyright (c) 2014 Rich Robinson. All rights reserved.
//

#import "RCRMinuteChangeTimer.h"

@implementation RCRMinuteChangeTimer

- (NSDate *)nextFireDate {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *oneMinuteComponents = [[NSDateComponents alloc] init];
    oneMinuteComponents.minute = 1;
    
    NSDate *nowPlusOneMinute = [calendar dateByAddingComponents:oneMinuteComponents toDate:now options:0];
    
    NSDateComponents *nowPlusOneMinuteComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:nowPlusOneMinute];
    
    nowPlusOneMinuteComponents.second = 0; // Set the second component to be zero, for the start of the next minute
    
    // This loses any sub-second 'components' that we may have previously had, so we get a time back that contains an exact second (with no tenths, hundredths, etc, of seconds)
    return [calendar dateFromComponents:nowPlusOneMinuteComponents];
}

@end
