//
//  ELFoodThermometerHead.h
//  Elink
//
//  Created by LarryZhang on 2021/4/23.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#ifndef ELFoodThermometerHead_h
#define ELFoodThermometerHead_h

#import "ELSDKHeader.h"

typedef NS_ENUM(NSUInteger, FoodThermometerProtocol) {//cmd:命令 sta:状态 ack:应答
    FoodThermometerProtocol_AppGetBasicInfo_cmd_A701 = 0x01, //APP-获取设备基础信息
    FoodThermometerProtocol_DeviceBasicInfo_sta_A702 = 0x02, //MCU-上发设备基础信息
    FoodThermometerProtocol_DeviceDataInfo_sta_A703 = 0x03, //MCU-上发数据状态
    FoodThermometerProtocol_AppSetUnit_cmd_A704 = 0x04, //APP-切换单位
    FoodThermometerProtocol_DeviceSetUnit_ack_A705 = 0x05, //MCU-切换单位ack
    FoodThermometerProtocol_AppDeviceSetAlarm_cmd_A706 = 0x06, //APP-MCU-同步取消报警
    FoodThermometerProtocol_AppDeviceSetAlarm_ack_A707 = 0x07, //APP-MCU-同步取消报警ack
    FoodThermometerProtocol_AppSetTempPre_cmd_A708 = 0x08, //APP-设置目标温度
    FoodThermometerProtocol_DeviceSetUnit_ack_A709 = 0x09, //MCU-设置目标温度ack
    FoodThermometerProtocol_AppSetDuration_cmd_A70A = 0x0A, //APP-设置定时时间时长
    FoodThermometerProtocol_DeviceSetDuration_ack_A70B = 0x0B, //MCU-设置定时时间时长ack
    FoodThermometerProtocol_AppDeviceSetPower_cmd_A70C = 0x0C, //APP-MCU-开始结束指令
    FoodThermometerProtocol_AppDeviceSetPower_ack_A70D = 0x0D, //APP-MCU-开始结束指令ack
    FoodThermometerProtocol_AppSetDateTime_cmd_A710 = 0x10, //APP-下发时间
    FoodThermometerProtocol_DeviceSetDateTime_ack_A711 = 0x11, //MCU-下发时间ack
    FoodThermometerProtocol_AppDeviceSetStart_cmd_A712 = 0x12, //APP-MCU-启动关闭设备探针
    FoodThermometerProtocol_AppDeviceSetStart_ack_A713 = 0x13, //APP-MCU-启动关闭设备探针

};

//A7 02
//MCU 上发基础信息
typedef struct {
    //探针总数量
    Byte probeCount;
    //电池充电状态
    Byte charging;
    //电量(若无电量检测功能，则该值为0xFF)
    Byte batteryLevel;
    //当前温度
    Byte curTemperatureUnit;
    //异常报警类型
    Byte alarmType;
    //设备支持烧烤模式
    Byte mode;
    //设备支持报警模式
    Byte alarmMode;
    
} BasicInfo;

//A7 03
//MCU上发数据状态
typedef struct {
    Byte index;//探针编号 1~8
    Byte working;//探针是否插入设备状态
    UInt16 internalRawTemperature;//实时温度
    UInt16 ambientRawTemperature;//环境温度
    UInt16 targetRawTemperature;//目标温度
    Byte inserting;//探针状态是否已插入肉内
    Byte started;//探针状态是否已启动报警功能,关联app Start
    Byte mode;//模式0：烤架。1：烤箱
    UInt16 duration;//定时时间（大端序，单位min。若无，则该值为0xFFFF）
    Byte alarmType;//报警类型 0：无报警 1：温度达到报警 2：定时达到报警

} ProbeStatus;

#endif /* ELFoodThermometerHead_h */
