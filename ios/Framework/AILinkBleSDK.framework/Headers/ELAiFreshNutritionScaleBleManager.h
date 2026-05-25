//
//  ELAiFreshNutritionScaleBleManager.h
//  Elink
//
//  Created by LarryZhang on 2021/12/1.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELAiFreshNutritionScaleDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AiFreshNutritionScaleBleDelegate <NSObject>

@optional

/// 蓝牙连接状态
/// @param state 连接状态
- (void)deviceBleReceiveState:(ELBluetoothState)state;

/// 附近的设备
/// @param devices 设备列表
- (void)deviceBleReceiveDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;

//获得支持单位列表
- (void)supportUnits:(NSArray *_Nonnull)unitArray;

//正在连接中倒计时
- (void)deviceBleCountDown:(NSInteger)count;

//ble version
- (void)firmwareVersion:(NSString *)version;


//称重数据
- (void)aiFreshNutritionScaleBleDataModel:(ELAiFreshNutritionScaleDataModel *_Nonnull)model;
//超载
- (void)overload:(BOOL)status;
//低电
- (void)lowPower:(BOOL)status;
//切换单位
- (void)uintDidChange:(AiFreshNutritionScaleWeightUnit)unit;

@end

@interface ELAiFreshNutritionScaleBleManager : ELBluetoothManager

@property(nonatomic, weak) id <AiFreshNutritionScaleBleDelegate> nutritionScaleBleDelegate;


+ (instancetype)shareManager;

@end

@interface ELAiFreshNutritionScaleBleManager ()

- (void)autoScan;
- (void)stopAutoScan;
- (void)checkStatus;

@end

@interface ELAiFreshNutritionScaleBleManager (send)

//APP 下发归零
- (void)sendMakeZero;

//APP 切换单位
- (void)sendUnit:(AiFreshNutritionScaleWeightUnit)unit;

//APP 获取设备支持单位列表
- (void)sendRequestUnitSupported;

@end

NS_ASSUME_NONNULL_END
