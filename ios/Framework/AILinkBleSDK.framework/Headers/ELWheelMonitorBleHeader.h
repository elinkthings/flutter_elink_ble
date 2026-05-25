//
//  ELWheelMonitorBleHeader.h
//  Elink
//
//  Created by iot_user on 2019/7/4.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#ifndef ELWheelMonitorBleHeader_h
#define ELWheelMonitorBleHeader_h

#import "ELSDKHeader.h"

typedef NS_ENUM(NSUInteger, WheelMonitorBleDataType) {
    WheelMonitorBleDataTypeMCUSend    = 0x01,  //MCU upload tire pressure status(MCU 上传胎压状态)
    WheelMonitorBleDataTypeMCUReceive = 0x02,  //MCU returns to tire pressure(MCU 返回胎压状态)
    WheelMonitorBleDataTypeSetUnit    = 0x81,  //App release unit settings(app 下发单位设置)
    WheelMonitorBleDataTypeSetUnitResult    = 0x82, //MCU reply unit setting result(MCU 回复单位设置结果)
    WheelMonitorBleDataTypeSetPressureLimit = 0x84, //MCU reverts to setting the tire pressure threshold(MCU 回复设置胎压阀值)
    WheelMonitorBleDataTypeSetTempLimit     = 0x86,   //MCU reply setting temperature threshold and alarm value(MCU 回复设置温度阀值、报警值)
    WheelMonitorBleDataTypeSetVoice         = 0x88 ,      //MCU reply to set alarm prompt(MCU 回复设置报警提示)
};
typedef NS_ENUM(NSUInteger, WheelMonitorWheelType) {
    WheelMonitorWheelTypeLeftFront   = 1, //左前轮
    WheelMonitorWheelTypeRightFront  = 2, //右前轮
    WheelMonitorWheelTypeLeftBack    = 3, //左后轮
    WheelMonitorWheelTypeRightBack   = 4, //右后轮
};

typedef NS_ENUM(NSInteger, WheelMonitorDeviceState) {
    
    WheelMonitorDeviceStateNormal     = 0x00, //Normal（正常）
    WheelMonitorDeviceStateAirLeakage = 0x01, //Air Leakage （漏气）
    WheelMonitorDeviceStateInflatable = 0x02, //Inflatable（充气）
    WheelMonitorDeviceStateStart      = 0x03, //Start（启动）
    WheelMonitorDeviceStatePowerOn    = 0x04, //Power On（上电）
    WheelMonitorDeviceStateWakeUp     = 0x05, //Wake Up（唤醒）
    WheelMonitorDeviceStateLost       = 0x06, //Lost(丢失)
};

typedef NS_ENUM(NSUInteger, WheelMonitorGetWheelData) {
    WheelMonitorGetWheelData_All         = 0x00, //全部数据
    WheelMonitorGetWheelData_LeftFront   = 0x01, //左前轮数据
    WheelMonitorGetWheelData_RightFront  = 0x02, //右前轮数据
    WheelMonitorGetWheelData_LeftBack    = 0x03, //左后轮
    WheelMonitorGetWheelData_RightBack   = 0x04, //右后轮
};
//Get whether the front and rear wheel parameters are set uniformly(获取前后轮参数是否统一设置)
typedef NS_ENUM(NSUInteger, WheelMonitorSettingType) {
    WheelMonitorSettingType_Together = 1, //Set together(一起设置)
    WheelMonitorSettingType_Separate = 2, //Set separately(分开设定)
};


#endif /* ELWheelMonitorBleHeader_h */
