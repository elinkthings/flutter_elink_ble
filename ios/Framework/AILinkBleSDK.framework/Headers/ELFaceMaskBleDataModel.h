//
//  ELFaceMaskBleDataModel.h
//  Elink
//
//  Created by iot_user on 2020/9/30.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELFaceMaskBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELFaceMaskBleDataModel : NSObject
@property (nonatomic, assign) int index;//空气质量指数，大端序 无效则该值为 65535
/*
风扇状态
0:关闭状态
1:1 档状态
2:2 档状态
*/
@property (nonatomic, assign) FaceMaskFanStatus fanStatus;
//电池电量，单位 % 0-100
@property (nonatomic, assign) int battery;
/*
电池状态
1:充电
2:非充电 如该值无效则为 0xFF
*/
@property (nonatomic, assign) FaceMaskBatteryStatus batteryStatus;
//电池续航 大端序。单位:分钟 无效则该值为 65535
@property (nonatomic, assign) int batteryLife;
//呼吸频率 单位，次/min
@property (nonatomic, assign) int breathRate;
/*
呼吸状态
1:呼气
2:吸气 无效则该值为 0xFF
*/
@property (nonatomic, assign) FaceMaskBreathStatus  breathStatus;
//滤网的总工作时长 大端序，单位:min
@property (nonatomic, assign) int workTime;


@end

NS_ASSUME_NONNULL_END
