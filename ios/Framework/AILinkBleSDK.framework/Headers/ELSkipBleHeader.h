//
//  ELSkipBleHeader.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/6/16.
//  Copyright © 2021 IOT. All rights reserved.
//

#ifndef ELSkipBleHeader_h
#define ELSkipBleHeader_h

/** 跳绳 ble head type 枚举定义 */
typedef NS_ENUM (NSInteger, Skip_BleHeadType)  {
    /** 同步时间戳 */
    Skip_BleHeadType_SyncTimestamp              = 0x00 ,
    /** 启动/结束自由跳绳模式 */
    Skip_BleHeadType_StartFreeMode              = 0x01 ,
    /** 启动/结束倒计时跳绳模式 */
    Skip_BleHeadType_StartCountdownTimeMode     = 0x02 ,
    /** 启动/结束倒计数跳绳模式 */
    Skip_BleHeadType_StartCountdownNumMode      = 0x03 ,
    /** 修改默认倒计时 */
    Skip_BleHeadType_UpdateCountdownTime        = 0x04 ,
    /** 修改默认倒计数 */
    Skip_BleHeadType_UpdateCountdownNum         = 0x05 ,
    /** 实时跳绳数据上报 */
    Skip_BleHeadType_RealtimeDataReporting      = 0x10 ,
    /** 跳绳结束，结果数据上报 */
    Skip_BleHeadType_EndRopeUploadData          = 0x20 ,
    
    
    /** 绑定设备 */
    Skip_BleHeadType_BindDevice                 = 0xB0 ,
    
    /** 请求获取离线记录 */
    Skip_BleHeadType_GetOfflineHistory          = 0xF1 ,
};

/** 跳绳回复结果枚举定义 */
typedef NS_ENUM (NSInteger, Skip_ResultType) {
    /** 成功 */
    Skip_ResultType_Success                     = 0x00 ,
    /** 失败 */
    Skip_ResultType_Fail                        = 0x01 ,
    /** 不支持 */
    Skip_ResultType_NotSupport                  = 0x02 ,
};

/** 启动/结束跳绳命令枚举 */
typedef NS_ENUM (NSInteger, Skip_UseDevCommandType) {
    /** 结束（本次跳绳数据上报） */
    Skip_UseDevCommandType_End                  = 0x00 ,
    /** 启动 */
    Skip_UseDevCommandType_Start                = 0x01 ,
    /** 重新开始 */
    Skip_UseDevCommandType_Restart              = 0x02 ,
};

/** 跳绳使用状态枚举定义 */
typedef NS_ENUM(NSInteger, Skip_ReadyStateType) {
    /** 跳绳准备阶段 */
    Skip_ReadyStateType_NotStarted              = 0 ,
    /** 正在跳绳阶段 */
    Skip_ReadyStateType_Sporting                    ,
    /** 跳绳完成阶段 */
    Skip_ReadyStateType_End                         ,
};

/** 跳绳模式枚举定义 */
typedef NS_ENUM(NSInteger, Skip_UseModeType) {
    /** 自由模式 */
    Skip_UseModeType_Free             = 1 ,
    /** 倒计时模式 */
    Skip_UseModeType_CountdownTime        ,
    /** 倒计数模式 */
    Skip_UseModeType_CountdownNum         ,
};


/** 绑定设备类型定义 */
typedef NS_ENUM(NSInteger, Skip_BindDeviceType) {
    /** 直接绑定 */
    Skip_BindDeviceType_DirectBinding           = 0x00 ,
    /** 按键绑定 */
    Skip_BindDeviceType_KeyBinding              = 0x01 ,
};

#endif /* ELSkipBleHeader_h */
