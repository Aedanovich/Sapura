//
//  RCRHourChangeTimer.h
//
//  Created by Rich Robinson on 07/09/2014.
//  Copyright (c) 2014 Rich Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRTimer.h"

/**
 A simple hour-based timer that does its best to synchronize with the clock, firing when the hour changes.
 */
@interface RCRHourChangeTimer : RCRTimer

@end
