//
//  FingerPrintScannerDelegate.h
//  Attendance
//
//  Created by Alex on 5/12/15.
//  Copyright © 2015 A2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BluetoothControl.h"

@interface FingerPrintScannerDelegate : NSObject
@property (nonatomic, strong) BluetoothControl* bluetoothControl;
- (void)BluetoothCallback:(NSData *) retval Message:(NSData *) msgtxt;
@end
