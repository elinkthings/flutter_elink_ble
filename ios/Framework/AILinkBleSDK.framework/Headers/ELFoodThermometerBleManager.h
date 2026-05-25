//
//  ELFoodThermometerBleManager.h
//  Elink
//
//  Created by LarryZhang on 2021/4/23.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELFoodThermometerHead.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FoodThermometerBleDelegate <NSObject>

@optional
//Bluetooth status callback(回调蓝牙状态)
- (void)deviceBleReceiveState:(ELBluetoothState)state;

//Callback FoodThermometer device list(回调牙刷设备列表)
- (void)deviceBleReceiveDevices:(NSArray<ELPeripheralModel *> *)devices;

//设备返回基础信息
- (void)foodThermometerBasicInfo:(BasicInfo)basicInfo;

//设备返回数据状态
- (void)foodThermometerProbeStatus:(ProbeStatus)probeStatus;

//设备设置温度
- (void)foodThermometerSwitchTemperatureUnit:(ELDeviceTemperatureUnit)unit;

@end

@interface ELFoodThermometerBleManager : ELBluetoothManager


@property(nonatomic, weak) id <FoodThermometerBleDelegate> foodThermometerBleDelegate;



+ (instancetype)shareManager;

- (void)autoScan;
- (void)stopAutoScan;
- (void)checkStatus;

@end

//发送数据给设备
@interface ELFoodThermometerBleManager (cmd)
//获取基础信息    A7 01
- (void)checkDeviceInfo;
//切换温度单位    A7 04
- (void)switchTemperatureUnit:(ELDeviceTemperatureUnit)unit;
//取消报警       A7 06
- (void)cancelAlarm:(NSUInteger)probeIndex;
//设置目标温度    A7 08
- (void)setTarget:(NSUInteger)probeIndex temperature:(NSInteger)temperature unit:(ELDeviceTemperatureUnit)unit;
//设置定时时长    A7 0A
- (void)setTarget:(NSUInteger)probeIndex duration:(NSUInteger)duration;
//启动关闭设备探针  A7 12
- (void)setProbe:(NSUInteger)probeIndex start:(BOOL)start;
//下发时间         A7 10
- (void)sendCurrentTime;
@end

NS_ASSUME_NONNULL_END
