//
//  RCRHourChangeTimer.m
//
//  Created by Rich Robinson on 07/09/2014.
//  Copyright (c) 2014 Rich Robinson. All rights reserved.
//

#import "RCRHourChangeTimer.h"

@implementation RCRHourChangeTimer

- (NSDate *)nextFireDate {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *oneHourComponents = [[NSDateComponents alloc] init];
    oneHourComponents.hour = 1;
    
    NSDate *nowPlusOneHour = [calendar dateByAddingComponents:oneHourComponents toDate:now options:0];
    
    NSDateComponents *nowPlusOneHourComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:nowPlusOneHour];
    
    // Set the minute and second components to be zero, for the start of the next hour
    nowPlusOneHourComponents.minute = 0;
    nowPlusOneHourComponents.second = 0;
    
    // This loses any sub-second 'components' that we may have previously had, so we get a time back that contains an exact second (with no tenths, hundredths, etc, of seconds)
    return [calendar dateFromComponents:nowPlusOneHourComponents];
}

@end
