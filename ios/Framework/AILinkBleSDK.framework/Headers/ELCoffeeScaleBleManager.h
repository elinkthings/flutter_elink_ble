//
//  ELCoffeeScaleBleManager.h
//  Elink
//
//  Created by iot_user on 2020/9/30.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELCoffeeScaleBleHeader.h"
#import "ELCoffeeScaleBleDataModel.h"

@protocol CoffeeScaleBleDelegate <NSObject>

@optional

/// 蓝牙连接状态
/// @param state 连接状态
- (void)deviceBleReceiveState:(ELBluetoothState)state;

/// 附近的设备
/// @param devices 设备列表
- (void)deviceBleReceiveDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;

//获得支持单位列表
- (void)supportWeightUnits:(NSArray *_Nullable)weightArray;

//正在连接中倒计时
- (void)deviceBleCountDown:(NSInteger)count;

/** 返回咖啡秤称量的数据模型 */
- (void)coffeeScaleBleReceiveStatusDataModel:(ELCoffeeScaleBleDataModel *_Nonnull)model;

/** 返回设备电量 */
- (void)coffeeScaleBleRechargeState:(CoffeeChargingType)type powerNumber:(NSInteger)power;

/** 返回报警设置指令设置结果 */
- (void)coffeeScaleAlarmSystemState:(CoffeeSetResultType)state;

/** 返回计时设置指令设置结果 */
- (void)coffeeScaleBleReceiveSupportCountTime:(CoffeeSetResultType)state;

//计时功能控制
- (void)coffeeScaleBleReceiveTimerControl:(BOOL)countdown duration:(NSUInteger)duration control:(ELCoffeeScaleTimerControl)control;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ELCoffeeScaleBleManager : ELBluetoothManager

@property (nonatomic, weak) id<CoffeeScaleBleDelegate> coffeeScaleDelegate;


+ (instancetype)shareManager;

- (void)autoScan;
- (void)stopAutoScan;
- (void)checkStatus;

//APP 下发归零
- (void)sendMakeZero; //A7 00 24 LEN *02 *01 SUM 7A
//APP 下发单位设置
- (void)sendWeightUnit:(ELDeviceWeightUnit)unit; //A7 00 24 LEN *04 *[00~06] SUM 7A
- (void)sendTemperatureUnit:(ELDeviceTemperatureUnit)unit; //A7 00 24 LEN *06 *[00~01] SUM 7A
- (void)sendBeepOn:(BOOL)on;
//APP 下发自动关机设置
- (void)sendPowerOffDuration:(NSInteger)duration; //A7 00 24 LEN *08 [*00 *00 ~ *FF *FE] SUM 7A

 /** APP 设置报警指令
 * @param state : 开关
 * @param duration : 报警持续时间值,单位s
 */
- (void)sendAlarmInstructionWithState:(BOOL)state duration:(NSInteger)duration;

/** 停止报警指令 */
- (void)sendStopAlarmInstruction;

//APP 下发计时控制 control:1计时2暂停3重置 countdown:YES倒计时NO正计时
- (void)sendTimeControlDuration:(NSInteger)duration control:(ELCoffeeScaleTimerControl)control countdown:(BOOL)countdown; //A7 00 24 *0A *[00~01] [*00 *00 ~ *FF *FE] *[00~03] SUM 7A

//退出冲煮或称重:(appMode:0 subMode:1) 冲煮:(appMode:1 subMode:0) 称重:(appMode:1 subMode:1)
- (void)sendSwithAppMode:(BOOL)appMode subMode:(Byte)subMode; //A7 00 24 LEN *11 *[00~01] *[00~01] SUM 7A

@end

@interface ELCoffeeScaleBleManager ()

@property (nonatomic, assign) NSInteger supportTimer;//0 未检测 1 支持 2 不支持

@end


NS_ASSUME_NONNULL_END
