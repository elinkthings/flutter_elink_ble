//
//  ELCM02_BleHeader.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/9/13.
//  Copyright © 2021 IOT. All rights reserved.
//

#ifndef ELCM02_BleHeader_h
#define ELCM02_BleHeader_h

/** 蓝牙协议type定义 */
typedef NS_ENUM(NSInteger, CM02_BleDataType) {
    /** 查询设备支持功能 */
    CM02_BleDataType_SupportFunction      = 0x00 ,
    /** 心跳数据交互 */
    CM02_BleDataType_Heartbeat            = 0x01 ,
    /** 设置控制器状态 */
    CM02_BleDataType_SetControl           = 0x02 ,
    /** 清除BM模块参数 */
    CM02_BleDataType_ClearBMParam         = 0x03 ,
    /** 设置模式档位速度 */
    CM02_BleDataType_SetupGear            = 0x04 ,
    /** 设置灯光 */
    CM02_BleDataType_SetupLight           = 0x05 ,
    /** 设置解锁车密码 */
    CM02_BleDataType_SetupPassworld       = 0x06 ,
    /** 锁车及解锁 */
    CM02_BleDataType_LockOrUnlock         = 0x07 ,
    /** 售后密码查询 */
    CM02_BleDataType_AfterSalesPassword   = 0x08 ,
    /** 查询单次行驶里程时间 */
    CM02_BleDataType_SingleMileage        = 0x0C ,
    /** 查询总里程 */
    CM02_BleDataType_TotalMileage         = 0x0D ,
    /** 查询电池信息 */
    CM02_BleDataType_Battery              = 0x0E ,
    /** 查询控制器厂商代码及编号 */
    CM02_BleDataType_ControlVersion       = 0x10 ,
    /** 查询仪表固件版本 */
    CM02_BleDataType_DashboardVersion     = 0x11 ,
    /** 天气信息 */
    CM02_BleDataType_WeatherPush          = 0x13 ,
    /** 导航数据 */
    CM02_BleDataType_NaviData             = 0x14 ,
    /** 当前时区*/
    CM02_BleDataType_CurrentTimeZone      = 0x15 ,
    
    /** 开始仪表OTA指令 */
    CM02_BleDataType_StartOTA             = 0xA0 ,
    /** 发送仪表OTA数据 */
    CM02_BleDataType_SendOTAData          = 0xA1 ,
    /** 发送仪表OTA完成指令 */
    CM02_BleDataType_EndOTA               = 0xA2 ,
};

/** 开机状态 */
typedef NS_ENUM(NSInteger, CM02_PoweronState_Type) {
    /** 开机状态 */
    CM02_PoweronState_Type_Poweron              = 0 ,
    /** 准备关机 */
    CM02_PoweronState_Type_ReadyShutDown            ,
};

/** 公里制单位 */
typedef NS_ENUM(NSInteger, CM02_Unit_Type) {
    /** 公里制 */
    CM02_Unit_Type_Kilometer                     = 0 ,
    /** 英里制 */
    CM02_Unit_Type_Mile                          = 1 ,
};

/** 模式 */
typedef NS_ENUM(NSInteger, CM02_Mode) {
    CM02_Mode_None                              = 0 ,
};

/** 密码是否正确枚举定义 */
typedef NS_ENUM(NSInteger, CM02_PasswordCorrect_Type) {
    /** 密码正确 */
    CM02_PasswordCorrect_Type_Correct           = 0 ,
    /** 密码错误 */
    CM02_PasswordCorrect_Type_Wrong             = 1 ,
};

/** 开锁相关的功能枚举定义 */
typedef NS_ENUM(NSInteger, CM02_LockState_Type) {
    /** 解锁 */
    CM02_LockState_Type_UnLock                         = 0 ,
    /** 上锁 */
    CM02_LockState_Type_Lock                           = 1 ,
    /** 验证密码 */
    CM02_LockState_Type_VerifyPassword                 = 2 ,
    /** 查询仪表开锁验证密码功能状态 */
    CM02_LockState_Type_Query_VerifyPassword_Status    = 3 ,
    /** 打开仪表开锁验证密码功能(需要携带密码) */
    CM02_LockState_Type_VerifyPassword_On              = 4 ,
    /** 关闭仪表开锁验证密码功能(需要携带密码) */
    CM02_LockState_Type_VerifyPassword_Off             = 5 ,
};

/** 结果枚举定义 */
typedef NS_ENUM(NSInteger, CM02_Result_Type) {
    /** 成功 */
    CM02_Result_Type_Success                      = 0 ,
    /** 失败 */
    CM02_Result_Type_Faild                            ,
    /** 不支持 */
    CM02_Result_Type_NotSupport                       ,
};

/** 电池电流枚举定义 */
typedef NS_ENUM(NSInteger, CM02_BatteryElectricCurrent_Type) {
    /** 实时电流 */
    CM02_BatteryElectricCurrent_Type_Real            = 0 ,
    /** 电流限流 */
    CM02_BatteryElectricCurrent_Type_Limit           = 1 ,
};

/** 设备类型 */
typedef NS_ENUM(NSInteger, CM02_DeviceType) {
    /** 仪表桥接:表示BM模块作为核心板，搭配客户的底板，作为仪表功能 */
    CM02_DeviceType_InstrumentBridge                  = 0 ,
    /** BLE透传:表示BM模块只提供BLE功能，作为透传模块，和客户的仪表通过uart连接，做透传功能 */
    CM02_DeviceType_BlePassThrough                    = 1 ,
};

/** 导航状态 */
typedef NS_ENUM(NSInteger, ElectricScooter_NavigationState) {
    /** 关闭导航 */
    ElectricScooter_NavigationState_Off             = 0 ,
    /** 开启导航 */
    ElectricScooter_NavigationState_On                  ,
    /** 更新导航数据 */
    ElectricScooter_NavigationState_UpdateData          ,
};

/** 导航方向代码 */
typedef NS_ENUM(NSInteger, ElectricScooter_NavigationPushCode) {
    /** 直行 */
    ElectricScooter_NavigationPushCode_Straight             = 0 ,
    /** 左转 */
    ElectricScooter_NavigationPushCode_TurnLeft                 ,
    /** 右转 */
    ElectricScooter_NavigationPushCode_TurnRight                ,
    /** 左转掉头 */
    ElectricScooter_NavigationPushCode_TurnRoundLeft            ,
    /** 右转掉头 */
    ElectricScooter_NavigationPushCode_TurnRoundRight           ,
};


#endif /* ELCM02_BleHeader_h */
