//
//  ELBluetoothManager+BleWifi.h
//  AILinkBleSDK
//
//  Created by steven wu on 2021/8/6.
//  Copyright © 2021 IOT. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELBleWifiDetailModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface ELBluetoothManager (BleWifi)


#pragma mark ============ Bluetooth WIFI calling method(蓝牙WIFI 设置命令) ==============

/**
 WIFI initiate connection and disconnect(WIFI 发起连接、断开连接)

 @param connect YES: initiate connection NO: disconnect(YES:发起连接 NO:断开连接)
 */
-(void)bleWifiSetupWifiConnect:(BOOL)connect;

/**
 Set WIFI access URL(设置WIFI访问URL)
 
 @param url url（Not more than 56chars(不超过56chars)）
 */
-(void)bleWifiSetWifiURL:(NSString *)url;

/**
 Set Wifi access port number(设置Wifi访问端口号)
 
 @param port 端口号
 */
-(void)bleWifiSetPort:(int)port;

/**
 Set DTIM interval(设置DTIM间隔)

 @param interval 间隔
 */
-(void)bleWifiSetDTIMInterval:(int)interval;

/**
 Set WIFI password(设置WIFI密码)
 
 @param pwd WIFI password (8 ~ 56 chars)(WIFI密码(8~56 个chars))
 */
-(void)bleWifiSetWifiPwd:(NSString *)pwd;

/**
 Set up connected WIFI(设置连接的WIFI)

 @param macData wifi MAC (little endian)(wifi的MAC（小端序）)
 */
-(void)bleWifiSetConnectWifiMac:(NSData *)macData;

@end

NS_ASSUME_NONNULL_END
