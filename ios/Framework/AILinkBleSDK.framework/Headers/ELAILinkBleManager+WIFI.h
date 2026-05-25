//
//  ELAILinkBleManager+WIFI.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2023/3/31.
//

#import "ELAILinkBleManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELAILinkBleManager (WIFI)

//============ Bluetooth WIFI calling method(蓝牙WIFI 设置命令) ==============

/**
 WIFI initiate connection and disconnect(WIFI 发起连接、断开连接)
 @param connect YES: initiate connection NO: disconnect(YES:发起连接 NO:断开连接)
 */
- (void)bleWifiSetupWifiConnect:(BOOL)connect;

/**
 Set WIFI access URL(设置WIFI访问URL)
 @param url url（Not more than 56chars(不超过56chars)）
 */
- (void)bleWifiSetURL:(NSString *)url;

/**
 Set Wifi access port number(设置Wifi访问端口号)
 @param port 端口号
 */
- (void)bleWifiSetPort:(int)port;

/**
 Set WIFI access path(设置WIFI访问path)
 @param path path（Not more than 56chars(不超过56chars)）
 */
- (void)bleWifiSetPath:(NSString *)path;

//Get WIFI access URL(设置WIFI访问URL)
- (void)bleWifiGetURL;

//Get Wifi access port number(设置Wifi访问端口号)
- (void)bleWifiGetPort;

//Get WIFI access path(设置WIFI访问path)
- (void)bleWifiGetPath;


/**
 Set DTIM interval(设置DTIM间隔)
 @param interval 间隔
 */
- (void)bleWifiSetDTIMInterval:(int)interval;

/**
 Set WIFI password(设置WIFI密码)
 @param pwd WIFI password (8 ~ 56 chars)(WIFI密码(8~56 个chars))
 */
- (void)bleWifiSetWifiPwd:(NSString *)pwd;

/**
 Set up connected WIFI(设置连接的WIFI)
 @param macData wifi MAC (little endian)(wifi的MAC（小端序）)
 */
- (void)bleWifiSetConnectWifiMac:(NSData *)macData;

//解析
- (void)parseA6WifiPacket:(NSData *)packet;

@end


NS_ASSUME_NONNULL_END
