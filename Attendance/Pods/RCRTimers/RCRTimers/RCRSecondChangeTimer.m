//
//  RCRSecondChangeTimer.m
//
//  Created by Rich Robinson on 07/09/2014.
//  Copyright (c) 2014 Rich Robinson. All rights reserved.
//

#import "RCRSecondChangeTimer.h"

@implementation RCRSecondChangeTimer

- (NSDate *)nextFireDate {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *oneSecondComponents = [[NSDateComponents alloc] init];
    oneSecondComponents.second = 1;
    
    NSDate *nowPlusOneSecond = [calendar dateByAddingComponents:oneSecondComponents toDate:now options:0];
    
    NSDateComponents *nowPlusOneSecondComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:nowPlusOneSecond];

    // We don't need to perform any additional work on the components (as we lose anything less than a second anyway, see below)
    
    // This loses any sub-second 'components' that we may have previously had, so we get a time back that contains an exact second (with no tenths, hundredths, etc, of seconds)
    return [calendar dateFromComponents:nowPlusOneSecondComponents];
}

@end
