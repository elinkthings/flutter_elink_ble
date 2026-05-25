//
//  ELNutritionScaleBleManager.h
//  Elink
//
//  Created by iot_user on 2020/8/21.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELNutritionScaleDataModel.h"

@protocol NutritionScaleBleDelegate <NSObject>

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


//称重数据
- (void)nutritionScaleBleDataModel:(ELNutritionScaleDataModel *_Nonnull)model;
//超载
- (void)overload:(BOOL)status;
//低电
- (void)lowPower:(BOOL)status;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ELNutritionScaleBleManager : ELBluetoothManager

@property(nonatomic, weak) id <NutritionScaleBleDelegate> nutritionScaleBleDelegate;


+ (instancetype)shareManager;

@end

@interface ELNutritionScaleBleManager ()

- (void)autoScan;
- (void)stopAutoScan;
- (void)checkStatus;

@end

@interface ELNutritionScaleBleManager (send)

//APP 下发归零
- (void)sendMakeZero;

//APP 切换单位
- (void)sendUnit:(NutritionScaleWeightUnit)unit;

@end

NS_ASSUME_NONNULL_END
