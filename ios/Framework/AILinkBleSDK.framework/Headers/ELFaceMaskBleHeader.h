//
//  ELFaceMaskBleHeader.h
//  Elink
//
//  Created by iot_user on 2020/9/30.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#ifndef ELFaceMaskBleHeader_h
#define ELFaceMaskBleHeader_h
#import "ELSDKHeader.h"

/*
风扇状态
0:关闭状态
1:1 档状态
2:2 档状态
*/
typedef NS_ENUM(NSUInteger, FaceMaskFanStatus) {
    FaceMaskFanStatusClose        = 0x00,
    FaceMaskFanStatusFirstGear    = 0x01,
    FaceMaskFanStatusSecondGear   = 0x02,
};

/*
电池状态
1:充电
2:非充电
如该值无效则为 0xFF
*/

typedef NS_ENUM(NSUInteger, FaceMaskBatteryStatus) {
    FaceMaskBatteryStatusRecharge = 1,
    FaceMaskBatteryStatusNoRecharge = 2,
    FaceMaskBatteryStatusInvalid  = 0xFF,
};

/*
呼吸状态
1:呼气
2:吸气 无效则该值为 0xFF
*/
typedef NS_ENUM(NSUInteger, FaceMaskBreathStatus) {
    FaceMaskBreathStatusExhale  = 1,
    FaceMaskBreathStatusInhale  = 2,
    FaceMaskBreathStatusInvalid = 0xFF,
};
/*
 风扇控制结果
 0x00:成功 0x01:失败，电量不足 0x02:不支持 0x03:失败，风扇已坏
 */
typedef NS_ENUM(NSUInteger, FaceMaskFanControlResult) {
    FaceMaskFanControlResultSuccess   =  0,
    FaceMaskFanControlResultFailed    =  1,
    FaceMaskFanControlResultUnsupported = 2,
    FaceMaskFanControlResultFault      = 3,
};

#endif /* ELFaceMaskBleHeader_h */
