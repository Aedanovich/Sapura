//
//  BluetoothControl.h
//  SmartLock
//
//  Created by 天防科技 on 15/6/25.
//  Copyright (c) 2015年 天防科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define DEVICE_STATE 0x00
    #define DEVICE_STATE_BTOPEN     0x00
    #define DEVICE_STATE_BTERROR1   0x01
    #define DEVICE_STATE_BTERROR2   0x02
    #define DEVICE_STATE_BTERROR3   0x03
    #define DEVICE_STATE_BTERROR4   0x04
    #define DEVICE_STATE_BTSCAN     0x05
    #define DEVICE_STATE_BTLINK     0x06

#define CMD_ENROLID     0x02
#define CMD_VERIFYID    0x03
#define CMD_IDENTIFYID  0x04
#define CMD_DELETEID    0x05
#define CMD_CLEARID     0x06

#define CMD_ENROLHOST   0x07
#define CMD_CAPTUREHOST 0x08
#define CMD_MATCH       0x09
#define CMD_GETIMAGE    0x30
#define CMD_GETCHAR     0x31

#define CMD_CARDSN      0x0E
#define CMD_UPCARDSN    0x43

#define CMD_GETSN       0x10
#define CMD_GETBAT      0x21

@interface BluetoothControl : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    id callbackObject;
    NSString *callbackFunction;
    
    CBCentralManager *manager;
    NSMutableArray *listData;
    NSMutableArray *devicesList;
    CBPeripheral * mPeripheral;
    
    Byte    mDevCMD;
    Boolean mIsWork;
    int     mCmdSize;
    NSMutableData* mCmdData;
    int     mImageSize;
    NSMutableData* mImageData;
}

-(Boolean)CheckDeviceName:(NSString *)name;

- (void)callBluetoothCallback:(NSData *)data1 Data:(NSData *)data2;
- (void)setDelegateObject:(id)cbobject setBluetoothCallback:(NSString *)selectorName;
- (void)callTest;

- (void)Open;
-(void)Close;

-(void)startScan;
-(void)stopScan;
-(BOOL)isLECapableHardware;
-(BOOL)connect:(CBPeripheral *)peripheral;
-(void)disconnect:(CBPeripheral *)peripheral;

@property(nonatomic,retain) NSMutableArray *listData;
@property (retain) NSMutableArray *devicesList;
@property (retain) CBPeripheral *mPeripheral;

@property(retain) CBCharacteristic *transparentDataWriteChar;
@property(retain) CBCharacteristic *transparentDataReadChar;

@property(nonatomic,retain) NSMutableData *mCmdData;
@property(nonatomic,retain) NSMutableData *mImageData;

-(void)SendCommand:(Byte)cmd Data:(Byte*)data Size:(int)size;
- (NSData*)GetDataToSend:(Byte)cmd Data:(Byte*)data Size:(int)size;
- (NSString*)DecodeIDData:(NSData *) retval Message:(NSData *) msgtxt;

@end