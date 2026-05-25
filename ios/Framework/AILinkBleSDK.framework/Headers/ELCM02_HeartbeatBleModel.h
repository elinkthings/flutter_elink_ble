//
//  ELCM02_HeartbeatBleModel.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/9/13.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELCM02_BleHeader.h"

NS_ASSUME_NONNULL_BEGIN

/** CM02设备心跳包数据模型 */
@interface ELCM02_HeartbeatBleModel : NSObject

/** 是否正在充电 */
@property (nonatomic, assign) BOOL charging;

/** 电池电量 */
@property (nonatomic, assign) NSUInteger power;

/** 车辆速度 */
@property (nonatomic, assign) float speed;

/** 开机状态 */
@property (nonatomic, assign) enum CM02_PoweronState_Type poweronState;

/** 是否为推行模式,否则为正常行驶 */
@property (nonatomic, assign) BOOL pursueMode;

/** 是否为巡航状态 */
@property (nonatomic, assign) BOOL cruiseState;

/** 单位 */
@property (nonatomic, assign) enum CM02_Unit_Type unit;

/** 是否为助力模式 */
@property (nonatomic, assign) BOOL helpMode;

/** 巡航功能开关状态 */
@property (nonatomic, assign) BOOL cruiseSwitchState;

/** 是否为非零速度启动 */
@property (nonatomic, assign) BOOL speedStart;

/** 车辆是否被锁 */
@property (nonatomic, assign) BOOL isLocked;

/** 模式 */
@property (nonatomic, assign) enum CM02_Mode mode;

/** 车辆支持的最高速度，单位KM/H */
@property (nonatomic, assign) NSInteger topSpeedSupported;

/** 最低档位是否从0开始 */
@property (nonatomic, assign, getter=isGearStartAtZero) BOOL gearStartAtZero;

/** 档位(1-7) */
@property (nonatomic, assign) NSInteger gear;

/** 支持的档位个数 */
@property (nonatomic, assign) NSInteger gearsCount;


/** 转把是否有效 */
@property (nonatomic, assign) BOOL turnHandleEffective;

/** 电子刹车是否再刹车 */
@property (nonatomic, assign) BOOL electronicBrakeState;

/** 机械刹车是否再刹车 */
@property (nonatomic, assign) BOOL mechanicalBrakeState;

/** 电机是否再运行 */
@property (nonatomic, assign) BOOL motorState;


/** 右转向灯是否开启 */
@property (nonatomic, assign) BOOL rightLightState;
/** 左转向灯是否开启 */
@property (nonatomic, assign) BOOL leftLightState;
/** 氛围灯是否开启 */
@property (nonatomic, assign) BOOL atmosphereLightState;
/** 日行灯是否开启 */
@property (nonatomic, assign) BOOL daytimeRunningLightState;
/** 刹车灯是否开启 */
@property (nonatomic, assign) BOOL brakeLightState;
/** 前车灯开关 */
@property (nonatomic, assign) BOOL lightState;


/** 电池是否有故障 */
@property (nonatomic, assign) BOOL batteryState;
/** 控制器是否有故障 */
@property (nonatomic, assign) BOOL controlState;
/** 电机相线或者MOS管短路是否有故障 */
@property (nonatomic, assign) BOOL MOSState;
/** 电机霍尔是否有故障 */
@property (nonatomic, assign) BOOL hallState;
/** 刹车是否有故障 */
@property (nonatomic, assign) BOOL brakeState;
/** 转把是否有故障 */
@property (nonatomic, assign) BOOL turnHandleState;
/** 通讯是否有故障 */
@property (nonatomic, assign) BOOL communicationsState;


/** 单次行驶里程距离,使用当前单位 */
@property (nonatomic, assign) float distance;

/** 单次行驶时间，秒 */
@property (nonatomic, assign) NSInteger drivingTime;

/** 升级状态 */
@property (nonatomic, assign) BOOL upgradeStatus;

+ (instancetype)instanceWithBleData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
