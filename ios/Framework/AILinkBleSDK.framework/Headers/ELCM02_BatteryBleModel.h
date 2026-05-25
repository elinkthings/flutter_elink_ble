//
//  ELCM02_BatteryBleModel.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/9/13.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELCM02_BleHeader.h"

NS_ASSUME_NONNULL_BEGIN

/** 电池信息蓝牙数据模型 */
@interface ELCM02_BatteryBleModel : NSObject

/** 电池温度，摄氏度 */
@property (nonatomic, assign) float tem;

/** 电流状态 */
@property (nonatomic, assign) enum CM02_BatteryElectricCurrent_Type state;

/** 电流 A 正数位放电电流，负数为充电电流 */
@property (nonatomic, assign) float electricCurrent;

/** 电压 V */
@property (nonatomic, assign) float voltage;

/** 电池总容量 mAh */
@property (nonatomic, assign) NSInteger capacitance;

/** 电池充放电次数 */
@property (nonatomic, assign) NSInteger chargeTimes;

+ (instancetype)instanceWithBleData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
