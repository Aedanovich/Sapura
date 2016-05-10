//
//  FingerPrintScannerDelegate.m
//  Attendance
//
//  Created by Alex on 5/12/15.
//  Copyright © 2015 A2. All rights reserved.
//

#import "FingerPrintScannerDelegate.h"
#import "UUID.h"
#import "BluetoothControl.h"

@implementation FingerPrintScannerDelegate
- (void)BluetoothCallback:(NSData *) retval Message:(NSData *) msgtxt
{
    {
        NSLog(@"Logs %@", retval);
        NSLog(@"Logs %@", msgtxt);
        Byte *cmdret = (Byte *)[retval bytes];
        Byte *cmddat = (Byte *)[msgtxt bytes];
        switch ((Byte)cmdret[0]) {
            case DEVICE_STATE:{
                NSString * state = nil;
                switch (cmddat[0]) {
                    case DEVICE_STATE_BTOPEN:{
                        NSLog(@"DEVICE_STATE_BTOPEN Bluetooth 已打开");
                        NSLog(@"DEVICE_STATE_BTOPEN 扫描设备中...");
                        [self.bluetoothControl startScan];
                    }
                        break;
                    case DEVICE_STATE_BTERROR1: state = @"DEVICE_STATE_BTERROR1 手机不支持 Bluetooth BLE.";  break;
                    case DEVICE_STATE_BTERROR2: state = @"DEVICE_STATE_BTERROR2 应用没有认证使用 Bluetooth BLE.";   break;
                    case DEVICE_STATE_BTERROR3: state = @"DEVICE_STATE_BTERROR3 Bluetooth 未打开.";    break;
                    case DEVICE_STATE_BTERROR4: state = @"DEVICE_STATE_BTERROR4 Bluetooth 未知错误.";   break;
                    case DEVICE_STATE_BTSCAN:{
                        NSLog(@"DEVICE_STATE_BTSCAN");
                        if (self.bluetoothControl.devicesList.count > 0) {
                            [self.bluetoothControl connect:[self.bluetoothControl.devicesList objectAtIndex:0]];
                        }
                    }
                        break;
                    case DEVICE_STATE_BTLINK:{
                        NSLog(@"DEVICE_STATE_BTLINK 连接成功");
                    }
                        break;
                    default:break;
                }
                if(cmddat[0]>=DEVICE_STATE_BTERROR1&&cmddat[0]<=DEVICE_STATE_BTERROR4){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"蓝牙(Bluetooth)"  message:state delegate:self cancelButtonTitle:@"关闭" otherButtonTitles: nil];
                    [alertView show];
                }
            }
                break;
            case 0x01:
                break;
            default:
                break;
        }
    }
    {
        Byte *cmdret = (Byte *)[retval bytes];
        Byte *cmddat = (Byte *)[msgtxt bytes];
        switch ((Byte)cmdret[0]) {
            case CMD_UPCARDSN:
            case CMD_CARDSN:
                if((Byte)cmdret[1]==1){
                    NSString *cardsn=@"";
                    for(int i=0;i<[msgtxt length];i++)
                    {
                        NSString *newHexStr = [NSString stringWithFormat:@"%x",cmddat[i]&0xff]; ///16进制数
                        if([newHexStr length]==1)
                            cardsn = [NSString stringWithFormat:@"%@0%@",cardsn,newHexStr];
                        else
                            cardsn = [NSString stringWithFormat:@"%@%@",cardsn,newHexStr];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDidDecodeIDNotification" object:cardsn];
                }else{
                    NSLog(@"Get Card SN Fail");
                }
                break;
        }
    }
    {
        Byte *cmdret = (Byte *)[retval bytes];
        Byte *cmddat = (Byte *)[msgtxt bytes];
        switch ((Byte)cmdret[0]) {
            case CMD_CAPTUREHOST:
                if((Byte)cmdret[1]==1){
                    NSData* mfpData = [[NSData alloc] initWithData:msgtxt];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDidReceiveFingerPrintNotification" object:mfpData];
                }
                else{
                    NSLog(@"Capture Fail");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDidReceiveFingerPrintNotification" object:nil];
                }
                break;

            case CMD_MATCH:{
                if((Byte)cmdret[1]==1){
                    int score = cmddat[0]+(cmddat[1]<<8);
                    NSLog(@"MATCH Success (Score: %d)", score);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDidDecodeFingerPrintNotification" object:[NSNumber numberWithBool:true]];
                }
                else{
                    NSLog(@"MATCH Fail");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDidDecodeFingerPrintNotification" object:[NSNumber numberWithBool:false]];
                }
            }
                break;
        }
    }
}

@end
