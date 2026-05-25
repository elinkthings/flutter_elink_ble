//
//  ELWheelMonitorBleManager.h
//  Elink
//
//  Created by iot_user on 2019/7/3.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELWheelMonitorBleHeader.h"
#import "ELWheelMonitorBleModel.h"

@protocol WheelMonitorBleManagerDelegate <NSObject>

@optional

/**
 Callback Bluetooth status(回调蓝牙状态)
 
 @param state 蓝牙状态
 */
-(void)wheelMonitorBleManagerUpdateBleState:(ELBluetoothState)state;

/**
 Callback scanned device(回调扫描到的设备)
 
 @param devices 设备
 */
-(void)wheelMonitorBleManagerScanDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;

/**
 Set unit callback(设置单位回调)
 
 @param type 结果
 @param settingType 支持类型:
 WheelMonitorBleDataTypeSetUnitResult
 WheelMonitorBleDataTypeSetPressureLimit
 WheelMonitorBleDataTypeSetTempLimit
 WheelMonitorBleDataTypeSetVoice
 */
-(void)wheelMonitorBleManagerReceiveSetResult:(ELSetBluetoothResponseType)type settingType:(WheelMonitorBleDataType)settingType;

/**
 Callback tire pressure data(回调胎压数据)

 @param model 胎压数据模型
 */
-(void)wheelMonitorBleManagerWheelMonitorData:(ELWheelMonitorBleModel *_Nonnull)model;


/**
 Get front and rear wheel parameter setting type(获取前后轮参数设置类型)

 @param type 类型
 */
-(void)wheelMonitorBleManagerReceiveSettingType:(WheelMonitorSettingType)type;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ELWheelMonitorBleManager : ELBluetoothManager

@property (nonatomic, weak) id<WheelMonitorBleManagerDelegate> wheelMonitordelegate;


+(instancetype)shareManager;

/**
 Set unit(设置单位)

 @param pressureUnit 压力单位
 @param tempUnit 温度单位
 */
-(void)changePressureUnit:(ELDevicePressureUnit)pressureUnit tempUnit:(ELDeviceTemperatureUnit)tempUnit;

/**
 Read tire pressure information(读取胎压信息)

 @param type 轮胎
 */
-(void)getWheelData:(WheelMonitorGetWheelData)type;

/**
 Set tire pressure threshold(设置胎压阀值)

 @param frontMax 前轮上限阀值
 @param frontMin 前轮下限阀值
 @param backMax 后轮上限阀值
 @param backMin 后轮下限阀值
 @param unit 单位
 @param point 阀值数值小数点
 */
-(void)sendSettingWheelPressureLimitWithFrontMax:(int)frontMax frontMin:(int)frontMin backMax:(int)backMax backMin:(int)backMin pressureUnit:(ELDevicePressureUnit)unit valuePoint:(int)point;

/**
 Set temperature threshold and alarm value(设置温度阀值、报警值)

 @param tempMax 温度上限阀值
 @param tempMin 温度下限阀值(目前用不到，值为 0000)
 @param unit 温度值单位
 @param point 阀值数值小数点
 @param open 语音报警:YES:打开,NO:关闭
 */
-(void)sendSettingWheelTempLimitWithTempMax:(int16_t)tempMax tempMin:(int16_t)tempMin tempUnit:(ELDeviceTemperatureUnit)unit valuePoint:(int)point openVoice:(BOOL)open;

/**
 Set alarm prompt(设置报警提示)

 @param open Voice alarm: YES: on, NO: off(语音报警:YES:打开,NO:关闭)
 */
-(void)sendSettingWheelOpenVoice:(BOOL)open;
@end

NS_ASSUME_NONNULL_END
