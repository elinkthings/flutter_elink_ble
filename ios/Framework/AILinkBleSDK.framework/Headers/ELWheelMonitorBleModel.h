//
//  ELWheelMonitorBleModel.h
//  Elink
//
//  Created by iot_user on 2019/7/3.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELWheelMonitorBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELWheelMonitorBleModel : NSObject

@property (nonatomic, assign) WheelMonitorWheelType wheelType;//Tire number, 1: front left wheel 2: front right wheel 3: rear left wheel 4: rear right wheel(轮胎编号,1:左前轮 2:右前轮 3:左后轮 4:右后轮)

@property (nonatomic, copy) NSString *v;//Actual voltage (unit: V)(实际电压(单位:V))

@property (nonatomic, copy) NSString *p;//pressure(压力)

@property (nonatomic, assign) ELDevicePressureUnit pressureUnit;

@property (nonatomic, copy) NSString *t;//temperature(温度)

@property (nonatomic, assign) ELDeviceTemperatureUnit tempUnit;//

@property (nonatomic, assign) WheelMonitorDeviceState state;//状态

@property (nonatomic, assign) long long createTime;


/**
 Analyze tire pressure data(解析胎压数据)

 @param playload playload
 @return 数据模型
 */
+(ELWheelMonitorBleModel *)analysisWheelMonitorData:(NSData *)playload;
@end

NS_ASSUME_NONNULL_END
