//
//  ELBluetoothManagerProtocol.h
//  AILinkBleSDK
//
//  Created by steven wu on 2021/8/6.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ELBleWifiDetailModel;


NS_ASSUME_NONNULL_BEGIN


#pragma mark Bluetooth Wifi protocol(蓝牙Wifi协议)
@protocol ElBleWifiDelegate <NSObject>

@optional

/**
 Callback Wifi details(回调Wifi详情)

 @param model 模型
 */
-(void)bleWifiReceiveWifiDetailModel:(ELBleWifiDetailModel *_Nonnull)model;

/**
Scan nearby wifi results(扫描附近wifi结果)

 @param count Number of nearby wifi(附近wifi数量)
 */
-(void)bleWifiReceiveScanedWifiCount:(int)count;

/**
 Callback Wifi MAC address(回调Wifi MAC地址)

 @param macData mac
 */
-(void)bleWifiReceiveWifiMacData:(NSData *_Nullable)macData;

/**
Callback WIFI password(回调WIFI密码)

 @param pwd password(密码)
 */
-(void)bleWifiReceiveWifiPwd:(NSString *_Nonnull)pwd;

/**
 Get DTIM interval (unit: ms)(获取DTIM间隔(单位:ms))

 @param interval Interval (unit: ms)(间隔(单位:ms))
 */
-(void)bleWifiReceiveWifiDTIMInterval:(NSInteger)interval;

/**
 Returns the visited URL(返回访问的url)

 @param url url
 */
-(void)bleWifiReceiveWifiAccessURL:(NSString *_Nonnull)url;

/**
  Call back wifi port number(回调wifi的端口号)

 @param port 端口号
 */
-(void)bleWifiReceiveWifiPort:(int)port;

//Returns the visited path(返回访问的path)
- (void)bleWifiReceiveWifiPath:(NSString *)path;


/**
 Set or query the callback of the instruction execution result（设置指令蓝牙WIFI响应回调方法）
 只支持蓝牙Wifi部分枚举
 @param type Type of setting （设置的类型）
 @param result Set result（设置的结果）
 */
-(void)bleWifiReceiceResponseType:(ELInetSetCmdType)type result:(ELSetBluetoothResponseType)result;

/**
 获取会话码(deviceId)

 @param code (deviceId) deviceId(0 means no:为0时表示不存在)
 */
-(void)bleWifiReceiveWifiSNCode:(int)code;

/** 返回wifi名称 */
- (void)bleWifiName:(NSString *)wifiName;

@end


NS_ASSUME_NONNULL_END
