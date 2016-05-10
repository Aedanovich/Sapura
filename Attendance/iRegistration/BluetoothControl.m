#import "BluetoothControl.h"
#import "UUID.h"

@interface BluetoothControl ()

@end

@implementation BluetoothControl

@synthesize devicesList;
@synthesize listData;
@synthesize mPeripheral;
@synthesize transparentDataWriteChar;
@synthesize transparentDataReadChar;
@synthesize mCmdData;
@synthesize mImageData;

- (void)callBluetoothCallback:(NSData *)data1 Data:(NSData *)data2{
    SEL func_selector = NSSelectorFromString(callbackFunction);
    if ([callbackObject respondsToSelector:func_selector]) {
        NSLog(@"Callback OK ...");
        [callbackObject performSelector:func_selector withObject:data1 withObject:data2];
    }else{
        NSLog(@"Callback Fail ...");
    }
}

- (void)setDelegateObject:(id)cbobject setBluetoothCallback:(NSString *)selectorName{
    callbackObject = cbobject;
    callbackFunction = selectorName;
    
    mIsWork=false;
    mDevCMD=0x00;
}


- (void)callTest{
    Byte byte1[] = {0x46,0x54};
    NSData *data1 = [[NSData alloc] initWithBytes:byte1 length:2];
    
    Byte byte2[] = {0x46,0x54,0,0,6,0,0,0xA0,0};
    NSData *data2 = [[NSData alloc] initWithBytes:byte2 length:9];
    
    [self callBluetoothCallback:data1 Data:data2];
}


- (void)Open{//viewDidLoad{
    //[super viewDidLoad];
    if(manager==nil){
        manager = [CBCentralManager alloc];
        if ([manager respondsToSelector:@selector(initWithDelegate:queue:options:)]) {
            manager = [manager initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey: ISSC_RestoreIdentifierKey}];
        }
        else {
            manager = [manager initWithDelegate:self queue:nil];
        }
        
        devicesList = nil;
        listData=nil;
        
        self.transparentDataReadChar=nil;
        self.transparentDataWriteChar=nil;
        
        mCmdData=[NSMutableData dataWithLength:2048];
        mImageData=[NSMutableData dataWithLength:30400];
    }
}

-(void)Close{
    if(mPeripheral!=nil){
        [self disconnect:mPeripheral];
        mPeripheral=nil;
    }
    if(manager!=nil){
        [manager stopScan];
        manager=nil;
    }
    [devicesList removeAllObjects];
    [listData removeAllObjects];
}

- (BOOL) isLECapableHardware
{
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:{
            //state = @"手机不支持 Bluetooth BLE.";
            Byte cmdbyte[] = {0x00,0x00};
            NSData *cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
            Byte datbyte[] = {0x01,0x00};
            NSData *cmddat = [[NSData alloc] initWithBytes:datbyte length:2];
            [self callBluetoothCallback:cmdret Data:cmddat];
        }
            break;
        case CBCentralManagerStateUnauthorized:{
            //state = @"应用没有认证使用 Bluetooth BLE.";
            Byte cmdbyte[] = {0x00,0x00};
            NSData *cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
            Byte datbyte[] = {0x02,0x00};
            NSData *cmddat = [[NSData alloc] initWithBytes:datbyte length:2];
            [self callBluetoothCallback:cmdret Data:cmddat];
        }
            break;
        case CBCentralManagerStatePoweredOff:{
            //state = @"Bluetooth 未打开.";
            Byte cmdbyte[] = {0x00,0x00};
            NSData *cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
            Byte datbyte[] = {0x03,0x00};
            NSData *cmddat = [[NSData alloc] initWithBytes:datbyte length:2];
            [self callBluetoothCallback:cmdret Data:cmddat];
        }
            break;
        case CBCentralManagerStatePoweredOn:{
            //NSLog(@"Bluetooth 已打开");
            Byte cmdbyte[] = {0x00,0x00};
            NSData *cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
            Byte datbyte[] = {0x00,0x00};
            NSData *cmddat = [[NSData alloc] initWithBytes:datbyte length:2];
            [self callBluetoothCallback:cmdret Data:cmddat];
        }
            return TRUE;
        case CBCentralManagerStateUnknown:{
            Byte cmdbyte[] = {0x00,0x00};
            NSData *cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
            Byte datbyte[] = {0x04,0x00};
            NSData *cmddat = [[NSData alloc] initWithBytes:datbyte length:2];
            [self callBluetoothCallback:cmdret Data:cmddat];
        }
        default:
            return FALSE;
            
    }
    //NSLog(@"Central manager state: %@", state);
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"蓝牙(Bluetooth)"  message:state delegate:self cancelButtonTitle:@"关闭" otherButtonTitles: nil];
    //[alertView show];
    return FALSE;
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
}

- (void) centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@"%@",[dict description]);
}

-(void)startScan{
    listData=nil;
    devicesList=nil;
    [manager scanForPeripheralsWithServices:nil options:nil];
}

-(void)stopScan{
    [manager stopScan];
}

-(Boolean)CheckDeviceName:(NSString *)name{
    NSRange range = [name rangeOfString:@"TF"];//判断字符串是否包含
    if (range.length >0)//包含
    {
        return true;
    }
    else//不包含
    {
        return false;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if(listData==nil){
        listData = [[NSMutableArray alloc] init];
    }
    if(devicesList==nil){
        devicesList = [[NSMutableArray alloc] init];
    }
    //NSString * device= [NSString stringWithFormat:@"%s %d",peripheral.name.UTF8String,[peripheral.RSSI intValue]];
    //if(![self CheckDeviceName:peripheral.name])
    //    return;
    
    BOOL bfind=false;
    for(int i = 0; i < listData.count; i++){
        if(peripheral.name && [peripheral.name isEqualToString:listData[i]]){
            bfind=TRUE;
            break;
        }
    }
    
    if((peripheral.name != nil) &&
       (peripheral != nil) &&
       !bfind){
        [listData addObject:peripheral.name];
        [devicesList addObject:peripheral];
        //for (int i = 0; i < [devicesList count]; i++) {
        //    if (peripheral == [devicesList objectAtIndex:i]) {
        //        break;
        //    }
        //}
        
        Byte cmdbyte[] = {0x00,0x00};
        NSData *cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
        Byte datbyte[] = {0x05,0x00};
        NSData *cmddat = [[NSData alloc] initWithBytes:datbyte length:2];
        [self callBluetoothCallback:cmdret Data:cmddat];
    }
}

-(BOOL)connect:(CBPeripheral *)peripheral{
    manager.delegate = self;
    mPeripheral=peripheral;
    //[manager connectPeripheral:peripheral options:nil];
    [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    return  TRUE;
}


- (void)disconnect: (CBPeripheral *)peripheral {
    [manager cancelPeripheralConnection: peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    mPeripheral= peripheral;
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error){
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        //if ([self.delegate respondsToSelector:@selector(DidNotifyFailConnectService:withPeripheral:error:)])
        //    [self.delegate DidNotifyFailConnectService:nil withPeripheral:nil error:nil];
        return;
    }
    for (CBService *service in peripheral.services){
        NSLog(@"Service found with UUID: %@", service.UUID);
        //if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]]){
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"fff0"]]){
            [peripheral discoverCharacteristics:nil forService:service];
            
            Byte cmdbyte[] = {0x00,0x00};
            NSData *cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
            Byte datbyte[] = {0x06,0x00};
            NSData *cmddat = [[NSData alloc] initWithBytes:datbyte length:2];
            [self callBluetoothCallback:cmdret Data:cmddat];
            
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error){
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    //NSLog(@"服务：%@",service.UUID);
    
    for (CBCharacteristic *characteristic in service.characteristics){
        NSLog(@"didDiscoverCharacteristicsForService：%@",characteristic.UUID);
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_TX]]||
            [characteristic.UUID isEqual:[CBUUID UUIDWithString:@"fff1"]]) {
            NSLog(@"transparentDataReadChar：%@",characteristic);
            transparentDataReadChar = characteristic;
            [mPeripheral setNotifyValue:YES forCharacteristic:transparentDataReadChar];
        }
    }
    
    for (CBCharacteristic *characteristic in service.characteristics){
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_RX]]||
            [characteristic.UUID isEqual:[CBUUID UUIDWithString:@"fff2"]]) {
            NSLog(@"transparentDataWriteChar：%@", characteristic);
            [self.mPeripheral setNotifyValue:YES forCharacteristic:characteristic];
            transparentDataWriteChar=characteristic;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error){
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        //self.error_b = BluetoothError_System;
        //[self error];
        return;
    }
    //NSLog(@"收到的数据：%@",characteristic.value);
    //[self decodeData:characteristic.value];
    
    if(mDevCMD==CMD_GETIMAGE){
        memcpy(&(mImageData.bytes[mImageSize]),characteristic.value.bytes,characteristic.value.length);
        mImageSize=mImageSize+characteristic.value.length;
        if(mImageSize>=15200){
            //if(mImageSize>=7600){
            int rawsize=30400;
            int offset=54+1024;
            Byte * rawdat = malloc(30400+54+1024);
            rawdat[0]=0x42;
            rawdat[1]=0x4d;
            rawdat[2]=(Byte)(rawsize);
            rawdat[3]=(Byte)(rawsize>>8);
            rawdat[10]=(Byte)(offset);
            rawdat[11]=(Byte)(offset>>8);
            
            rawdat[14]=40;
            rawdat[18]=152;
            rawdat[22]=200;
            rawdat[26]=1;
            rawdat[28]=8;
            rawdat[30]=0;
            rawdat[34]=(Byte)(rawsize);
            rawdat[35]=(Byte)(rawsize>>8);
            rawdat[42]=0;
            rawdat[47]=1;
            for(int i=0;i<256;i++){
                rawdat[54+i*4+0]=(Byte)i;
                rawdat[54+i*4+1]=(Byte)i;
                rawdat[54+i*4+2]=(Byte)i;
                rawdat[54+i*4+3]=(Byte)0;
            }
            
            for(int i=0;i<15200;i++){
                rawdat[offset+i*2]=(((Byte *)mImageData.bytes)[i])&0xF0;
                rawdat[offset+i*2+1]=(((Byte *)mImageData.bytes)[i])<<4&0xF0;
            }
            
            NSData *imgbmp = [[NSData alloc] initWithBytes:rawdat length:(30400+54+1024)];
            Byte cmdbyte[] = {0x00,0x00};
            cmdbyte[0]=CMD_GETIMAGE;
            cmdbyte[1]=1;
            NSData * cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
            [self callBluetoothCallback:cmdret Data:imgbmp];
            free(rawdat);
        }
        
    }else{
        memcpy(&(mCmdData.bytes[mCmdSize]),characteristic.value.bytes,characteristic.value.length);
        mCmdSize=mCmdSize+characteristic.value.length;
        int totalsize=((Byte *)mCmdData.bytes)[5]+(((Byte *)mCmdData.bytes)[6]<<8)+9;
        if(mCmdSize>=totalsize){
            if(((Byte *)mCmdData.bytes)[0]==0x46&&((Byte *)mCmdData.bytes)[1]==0x54){
                
                NSData *cmdret=nil;
                NSData *cmddat=nil;
                Byte cmdbyte[] = {0x00,0x00};
                cmdbyte[0]=((Byte *)mCmdData.bytes)[4];
                cmdbyte[1]=((Byte *)mCmdData.bytes)[7];
                switch(((Byte *)mCmdData.bytes)[4]){
                    case CMD_ENROLID:
                        break;
                    case CMD_VERIFYID:
                        break;
                    case CMD_IDENTIFYID:{
                        if((Byte)cmdbyte[1]==1){
                            cmddat = [[NSData alloc] initWithBytes:&((Byte *)mCmdData.bytes)[8] length:2];
                        }
                    }
                        break;
                    case CMD_DELETEID:
                        break;
                    case CMD_CLEARID:
                        break;
                    case CMD_ENROLHOST:{
                        if((Byte)cmdbyte[1]==1){
                            int datasize=((Byte *)mCmdData.bytes)[5]+(((Byte *)mCmdData.bytes)[6]<<8)-1;
                            cmddat = [[NSData alloc] initWithBytes:&((Byte *)mCmdData.bytes)[8] length:datasize];
                        }
                    }
                        break;
                    case CMD_CAPTUREHOST:{
                        if((Byte)cmdbyte[1]==1){
                            int datasize=((Byte *)mCmdData.bytes)[5]+(((Byte *)mCmdData.bytes)[6]<<8)-1;
                            cmddat = [[NSData alloc] initWithBytes:&((Byte *)mCmdData.bytes)[8] length:datasize/2];
                        }
                    }
                        break;
                    case CMD_GETCHAR:{
                        if((Byte)cmdbyte[1]==1){
                            int datasize=((Byte *)mCmdData.bytes)[5]+(((Byte *)mCmdData.bytes)[6]<<8)-1;
                            cmddat = [[NSData alloc] initWithBytes:&((Byte *)mCmdData.bytes)[8] length:datasize/2];
                        }
                    }
                        break;
                    case CMD_MATCH:{
                        if((Byte)cmdbyte[1]==1){
                            cmddat = [[NSData alloc] initWithBytes:&((Byte *)mCmdData.bytes)[8] length:2];
                        }
                    }
                        break;
                    case CMD_CARDSN:
                    case CMD_UPCARDSN:{
                        if((Byte)cmdbyte[1]==1){
                            int datasize=((Byte *)mCmdData.bytes)[5]+(((Byte *)mCmdData.bytes)[6]<<8)-1;
                            cmddat = [[NSData alloc] initWithBytes:&((Byte *)mCmdData.bytes)[8] length:datasize];
                        }
                    }
                        break;
                    case CMD_GETSN:{
                        if((Byte)cmdbyte[1]==1){
                            int datasize=((Byte *)mCmdData.bytes)[5]+(((Byte *)mCmdData.bytes)[6]<<8)-1;
                            cmddat = [[NSData alloc] initWithBytes:&((Byte *)mCmdData.bytes)[8] length:datasize];
                        }
                    }
                        break;
                    case CMD_GETBAT:{
                        if((Byte)cmdbyte[1]==1){
                            int datasize=((Byte *)mCmdData.bytes)[5]+(((Byte *)mCmdData.bytes)[6]<<8)-1;
                            cmddat = [[NSData alloc] initWithBytes:&((Byte *)mCmdData.bytes)[8] length:datasize];
                        }
                    }
                        break;
                }
                
                
                cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
                [self callBluetoothCallback:cmdret Data:cmddat];
            }
        }
        
    }
    
    //Byte cmdbyte[] = {0x00,0x00};
    //NSData *cmdret = [[NSData alloc] initWithBytes:cmdbyte length:2];
    //[self callBluetoothCallback:cmdret Data:characteristic.value];
    
}


- (void) peripheral:(CBPeripheral *)aPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CBCharacteristicWriteType)sendTransparentData:(NSData *)data type:(CBCharacteristicWriteType)type {
    NSLog(@"[MyPeripheral] sendTransparentData:%@", data);
    if (transparentDataWriteChar == nil) {
        return CBCharacteristicWriteWithResponse;
    }
    CBCharacteristicWriteType actualType = type;
    if (type == CBCharacteristicWriteWithResponse) {
        if (!(transparentDataWriteChar.properties & CBCharacteristicPropertyWrite))
            actualType = CBCharacteristicWriteWithoutResponse;
    }
    else {
        if (!(transparentDataWriteChar.properties & CBCharacteristicPropertyWriteWithoutResponse))
            actualType = CBCharacteristicWriteWithResponse;
    }
    
    // HANDLE CRASH IF DEVICE CHARACTERISTICS ARE NULL
    if (data == nil) {
        NSLog(@"[Bluetooth Control] FAILED sendTransparentData: data should not be NULL");
        return CBCharacteristicWriteWithoutResponse;
    }
    if (transparentDataWriteChar == nil) {
        NSLog(@"[Bluetooth Control] FAILED sendTransparentData: transparentDataWriteChar should not be NULL");
        return CBCharacteristicWriteWithoutResponse;
    }
    
    [mPeripheral writeValue:data forCharacteristic:transparentDataWriteChar type:actualType];
    return actualType;
}

-(int)calcCheckSum:(Byte *)buffer Size:(int)size{
    int sum=0;
    for(int i=0;i<size;i++){
        sum=sum+buffer[i];
    }
    return sum;
}

-(void)SendCommand:(Byte)cmd Data:(Byte*)data Size:(int)size{
    /*
     Byte byte[] = {0x46,0x54,0,0,6,0,0,0xA0,0};
     NSData *buf = [[NSData alloc] initWithBytes:byte length:9];
     
     [mPeripheral writeValue:buf forCharacteristic:transparentDataWriteChar type:CBCharacteristicWriteWithoutResponse];
     //[mPeripheral writeValue:data for Characteristic:transparentDataWriteChar type:CBCharacteristicWriteWithoutResponse];
     */
    
    //NSData *buf = [[NSData alloc] initWithBytes:byte length:9];
    
    mImageSize=0;
    mCmdSize=0;
    mDevCMD=cmd;
    Byte * cmdbuf = malloc(size+9);
    cmdbuf[0]=0x46;
    cmdbuf[1]=0x54;
    cmdbuf[2]=0x00;
    cmdbuf[3]=0x00;
    cmdbuf[4]=cmd;
    cmdbuf[5]=(Byte)(size&0xFF);
    cmdbuf[6]=(Byte)((size>>8)&0xFF);
    if(size>0){
        for(int i=0;i<size;i++)
            cmdbuf[7+i]=data[i];
    }
    int sum=[self calcCheckSum:cmdbuf Size:(7+size)];
    cmdbuf[7+size]=(Byte)(sum&0xFF);
    cmdbuf[8+size]=(Byte)((sum>>8)&0xFF);
    NSData * cmddat = [NSData dataWithBytes:cmdbuf length:(size+9)];
    
    // HANDLE CRASH IF DEVICE CHARACTERISTICS ARE NULL
//    if (data == nil) {
//        NSLog(@"[Bluetooth Control] FAILED SendCommand: cmddat should not be NULL");
//        return;
//    }
    if (transparentDataWriteChar == nil) {
        NSLog(@"[Bluetooth Control] FAILED SendCommand: transparentDataWriteChar should not be NULL");
        return;
    }
    
    [mPeripheral writeValue:cmddat forCharacteristic:transparentDataWriteChar type:CBCharacteristicWriteWithoutResponse];
    free(cmdbuf);
}

- (NSData*)GetDataToSend:(Byte)cmd Data:(Byte*)data Size:(int)size {
    mImageSize=0;
    mCmdSize=0;
    mDevCMD=cmd;
    Byte * cmdbuf = malloc(size+9);
    cmdbuf[0]=0x46;
    cmdbuf[1]=0x54;
    cmdbuf[2]=0x00;
    cmdbuf[3]=0x00;
    cmdbuf[4]=cmd;
    cmdbuf[5]=(Byte)(size&0xFF);
    cmdbuf[6]=(Byte)((size>>8)&0xFF);
    if(size>0){
        for(int i=0;i<size;i++)
            cmdbuf[7+i]=data[i];
    }
    int sum=[self calcCheckSum:cmdbuf Size:(7+size)];
    cmdbuf[7+size]=(Byte)(sum&0xFF);
    cmdbuf[8+size]=(Byte)((sum>>8)&0xFF);
    NSData * cmddat = [NSData dataWithBytes:cmdbuf length:(size+9)];
    free(cmdbuf);
    
    return cmddat;
}

- (NSString*)DecodeIDData:(NSData *) retval Message:(NSData *) msgtxt {
    Byte *cmdret = (Byte *)[retval bytes];
    Byte *cmddat = (Byte *)[msgtxt bytes];
    switch ((Byte)cmdret[0]) {
        case CMD_UPCARDSN:
        case CMD_CARDSN:
            if((Byte)cmdret[1]==1){
                NSString *cardsn=@"Get Card SN OK:";
                for(int i=0;i<[msgtxt length];i++)
                {
                    NSString *newHexStr = [NSString stringWithFormat:@"%x",cmddat[i]&0xff]; ///16进制数
                    if([newHexStr length]==1)
                        cardsn = [NSString stringWithFormat:@"%@0%@",cardsn,newHexStr];
                    else
                        cardsn = [NSString stringWithFormat:@"%@%@",cardsn,newHexStr];
                }
                return cardsn;
            }else{
                return nil;
            }
            break;
    }
    return nil;
}

@end