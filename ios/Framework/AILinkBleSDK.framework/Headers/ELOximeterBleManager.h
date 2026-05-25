//
//  ELOximeterBleManager.h
//  Elink
//
//  Created by cliCk on 2020/11/16.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <AILinkBleSDK/ELBluetoothManager.h>
#import "ELOximeterBleModel.h"
#import "ELOximeterDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

/** 血氧仪获取app设备状态类型定义 */
typedef NS_ENUM(NSInteger, OximeterBleDataType) {
    /** app获取设备状态 */
    OximeterBleDataType_AppGetDeviceState        = 0x01 ,
    /** muc上报设置信息 */
    OximeterBleDataType_McuUploadSetupState      = 0x03 ,
    /** APP设置报警值 */
    OximeterBleDataType_AppSetupAlarm            = 0x04 ,
    /** muc回复报警值设置结果 */
    OximeterBleDataType_McuReplyAlarmResult      = 0x05 ,
    /** 设备上报错误码 */
    OximeterBleDataType_DeviceUploadErrorCode    = 0xFF ,
};

/** 血氧仪测量标识符 */
typedef NS_ENUM(NSInteger, OximeterTestMarkType) {
    /** 开始测量 */
    OximeterTestMarkType_StartTest               = 0x00 ,
    /** 测量中 */
    OximeterTestMarkType_Testing                        ,
    /** 结束测量 */
    OximeterTestMarkType_EndTest                 = 0xFF ,
};

/** 血氧仪设备上报错误码 */
typedef NS_ENUM(NSInteger, OximeterErrorCodeType) {
    /** 血氧饱和率不稳定 */
    OximeterErrorCodeType_UnstableBloodOxygenSaturationRate     = 0 ,
    /** 脉率不稳定 */
    OximeterErrorCodeType_UnstablePulseRate                         ,
    /** 测量出错 */
    OximeterErrorCodeType_TestWrong                                 ,
    /** 设备低电 */
    OximeterErrorCodeType_DeviceLowPower                            ,
};

@protocol ELOximeterBleDelegate <NSObject>

/** 回调蓝牙状态 */
- (void)oximeterManagerBleState:(ELBluetoothState)state;

/** 回调搜索到的血氧仪设备 */
- (void)oximeterManagerScanDevices:(NSArray<ELOximeterDeviceModel *> *)devices;

/** mcu上报设置信息 */
- (void)oximeterManagerSetupState:(ELOximeterBleModel *)bleModel markType:(enum OximeterTestMarkType)markType;

/** mcu回复报警设置结果 */
- (void)oximeterManagerReplyAlarmSetupState:(BOOL)setupState;

/** 设备上报错误码 */
- (void)oximeterManagerUploadErrorCode:(enum OximeterErrorCodeType)codeType;

@end

@interface ELOximeterBleManager : ELBluetoothManager

@property (nonatomic, weak) id<ELOximeterBleDelegate> oximeterBleDelegate;

+ (ELOximeterBleManager *)shareManager;

/** APP 获取设备状态 */
- (void)sendToBleWithGetDeviceStaus;

/** APP设置报警值 (设置负数则表示该值无效) */
- (void)sendToBleSetupAlarmNumberWithSpO2Upper:(NSInteger)Spo2Upper spo2Lower:(NSInteger)Spo2Lower prUpper:(NSInteger)PRUpper prLower:(NSInteger)PRLower piUpper:(NSInteger)PIUpper piLower:(NSInteger)PILower;

@end

NS_ASSUME_NONNULL_END
