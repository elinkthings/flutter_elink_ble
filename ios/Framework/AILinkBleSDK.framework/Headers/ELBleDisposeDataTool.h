//
//  ELBleDisposeDataTool.h
//  Elink
//
//  Created by iot_user on 2019/4/23.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"


NS_ASSUME_NONNULL_BEGIN

@interface ELBleDisposeDataTool : NSObject

#pragma mark 校验和
+(BOOL)checksum:(NSData *)data;
#pragma mark  广播设备校验和
+(BOOL)broadcastChecksum:(NSData *)data;

#pragma mark  ============ 解析A6数据 ==============
/**
 解析电池数据

 @param data 原始数据
 @return 电池充电状态和电量的结构体
 */
+(struct ELBatteryStruct)analysisBattery:(NSData *)data;

/**
 解析CID、VID、PID

 @param data 原始数据
 @return CID,VID,PID的结构体
 */
+(struct ELDIDStruct)analysisDid:(NSData *)data;
/**
 解析模块时间

 @param data 原始数据
 @return  yyyy-MM-dd HH:mm:ss
 */
+(NSString *)analysisBluetoothDate:(NSData *)data;
/**
 解析MCU软硬件版本号

 @param data 原始数据
 @return MCU软硬件版本号
 */
+(NSString *)analysisMCUVersion:(NSData *)data;
/**
 解析BM模块软硬件版本号

 @param data 原始数据
 @return BM模块软硬件版本号
 */
+ (NSString *)analysisBMVersion:(NSData *)data;
+ (NSString *)analysisBMVersionPro:(NSData *)data;

/**
 解析MAC地址

 @param data 原始数据
 @return MAC地址
 */
+(NSString *)analysisBluetoothMACAddrress:(NSData *)data;

/**
 解析模块状态

 @param data 原始数据
 @return 结构体
 */
+(struct ELMCUStateStruct)analysisBluetoothConnectState:(NSData *)data;
//重构
+ (ELWMStateStruct)analysisWMState:(NSData *)data;

/**
 解析模块通信模式

 @param data 原始数据
 @return 模式
 */
+(ELCommunicationModeType)analysisBluetoothCommunicationMode:(NSData *)data;

/**
 解析自动睡眠时间

 @param data 原始数据
 @return 结构体
 */
+(struct ELAutoSleepTimeStruct)analysisBluetoothAutoSleepTime:(NSData *)data;

/**
 解析主从模式数据

 @param data 原始数据
 @return 模式
 0:从机模式 1:主机模式
 */
+(int)analysisBluetoothMCUMode:(NSData *)data;

/**
 解析UUID

 @param data 原始数据
 @return UUID 的结构体
 */
+(struct ELUUIDStruct)analysisBluetoothUUID:(NSData *)data;
/**
 解析大小端序

 @param data 原始数据
 @return 大小端序
 */
+(int)analysisBluetoothMACAddressType:(NSData *)data;

/**
 解析串口波特率

 @param data 原始数据
 @return 波特率
 0:9600
 1:19200
 2:38400
 3:57600
 4:115200
 5:921600
 */
+(int)analysisBluetoothSerialPostBaudRate:(NSData *)data;

/**
 解析发射功率

 @param data 原始数据
 @return 发射功率:1~10
 */
+(int)analysisBluetoothTransmittingPower:(NSData *)data;

/**
 解析蓝牙连接间隔

 @param data 原始数据
 @return 连接间隔时间的结构体
 */
+(struct ELConnectIntervalStruct)analysisBluetoothConnectInterval:(NSData *)data;

/**
 解析蓝牙广播间隔时间

 @param data 蓝牙发送的原始数据
 @return 广播间隔
 */
+(int)analysisBluetoothBroadcastInterval:(NSData *)data;

/**
 解析蓝牙名称

 @param data 蓝牙发送的原始数据
 @return 蓝牙名称
 */
+(NSString *)analysisBluetoothName:(NSData *)data;


/**
 解析设备支持的体重数组
 
 @param data 蓝牙发送的原始数据
 @return 体重单位数组，内容为ELDeviceWeightUnit枚举
 */
+ (NSArray<NSNumber *> *)analysisBluetoothSupportWeightUnitArray:(NSData *)data;

/**
 解析设备支持的身高数组
 
 @param data 蓝牙发送的原始数据
 @return 身高单位数组，内容为ELDeviceHeightUnit枚举
 */
+ (NSArray<NSNumber *> *)analysisBluetoothSupportHeightUnitArray:(NSData *)data;

/**
 解析设备支持的温度数组
 
 @param data 蓝牙发送的原始数据
 @return 温度单位数组，内容为ELDeviceTemperatureUnit枚举
 */
+ (NSArray<NSNumber *> *)analysisBluetoothSupportTemperatureUnitArray:(NSData *)data;

/**
 解析设备支持的血压数组
 
 */
+ (NSArray<NSNumber *> *)analysisBluetoothSupportBloodPressureUnitArray:(NSData *)data;

/**
 解析设备支持的血压数组
 
 @param data 蓝牙发送的原始数据
 @return 血压单位数组，内容为ELDeviceTemperatureUnit枚举
 */
+ (NSArray<NSNumber *> *)analysisBluetoothSupportPressureUnitArray:(NSData *)data;

/// 解析设备支持的血糖仪单位
/// @param data 蓝牙发送的原始数据
+ (NSArray<NSNumber *> *)analysisBluetoothSupportBloodSugarUnitArray:(NSData *)data;

/// 解析设备支持的体积单位
/// @param data 蓝牙发送的原始数据
+ (NSArray<NSNumber *> *)analysisBluetoothSupportVolumUnitArray:(NSData *)data;

/// 解析设备支持的营养秤单位
/// @param data 蓝牙发送的原始数据
+ (NSArray<NSNumber *> *)analysisBluetoothSupportNutritionUnitArray:(NSData *)data;

/**
 解析蓝牙接收密钥的结果

 @param data 原数据
 @return YES：成功，NO失败
 */
+(BOOL)analysisBluetoothReceiveKeyState:(NSData *)data;

/**
 解析设备基本信息

 @param data 原数据
 @return 设备基本信息
 */
+(NSData *)analysisBluetoothReceiveBasicInfoData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
