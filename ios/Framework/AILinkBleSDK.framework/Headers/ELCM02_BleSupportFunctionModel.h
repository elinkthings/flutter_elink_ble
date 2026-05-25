//
//  ELCM02_BleSupportFunctionModel.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/9/22.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELCM02_BleHeader.h"

NS_ASSUME_NONNULL_BEGIN

/** CM02设备支持功能对象模型 */
@interface ELCM02_BleSupportFunctionModel : NSObject

/** 设备类型 */
@property (nonatomic, assign) enum CM02_DeviceType deviceType;

/** 是否支持自动背光 */
@property (nonatomic, assign) BOOL autoLight;

/** 是否支持手动背光 */
@property (nonatomic, assign) BOOL manualLight;

/** 支持的档位个数 */
@property (nonatomic, assign) NSInteger gearNum;

/** 是否支持定速巡航功能, 0：不支持，1：支持 */
@property (nonatomic, assign, getter=isCruiseSupported) BOOL cruiseSupported;

/** 是否支持定速巡航开关, 0：不支持，1：支持 */
@property (nonatomic, assign, getter=isCruiseControlSupported) BOOL cruiseControlSupported;

/** 是否支持零启动和非零启动切换 */
@property (nonatomic, assign) BOOL speedStartChange;

/** 控制器厂商代码编号 */
@property (nonatomic, assign) BOOL controlCodeNum;

/** 电池信息 */
@property (nonatomic, assign) BOOL batteryInformation;

/** 电池厂商代码编号 */
@property (nonatomic, assign) BOOL batteryCodeNum;

/** 右转灯开关 */
@property (nonatomic, assign) BOOL rightLightSwitch;

/** 左转灯开关 */
@property (nonatomic, assign) BOOL leftLightSwitch;

/** 氛围灯开关 */
@property (nonatomic, assign) BOOL ambientLightSwitch;

/** 日行灯开关 */
@property (nonatomic, assign) BOOL daytimeRunningLightSwitch;

/** 刹车灯开关 */
@property (nonatomic, assign) BOOL brakeLightSwitch;

/** 前车灯开关 */
@property (nonatomic, assign) BOOL frontLightSwitch;

+ (instancetype)instanceWithBleData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
