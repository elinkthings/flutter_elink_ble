//
//  ELHygrothermographBleHeader.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/5/8.
//  Copyright © 2021 IOT. All rights reserved.
//

#ifndef ELHygrothermographBleHeader_h
#define ELHygrothermographBleHeader_h

/** 温湿度计 ble head type 枚举定义 */
typedef NS_ENUM (NSInteger, TH_BleHeadType) {
    /** App获取设备状态 */
    TH_BleHeadType_App_GetDevState        = 0x01 ,
    /** 设备定时返回设备状态 */
    TH_BleHeadType_MCU_ReturnDevState     = 0x02 ,
    /** App设备变化阀值 */
    TH_BleHeadType_App_SetDevThreshold    = 0x03 ,
    /** 设备定时返回阀值 */
    TH_BleHeadType_MCU_ReturnDevThreshold = 0x04 ,
    /** App读取设备的历史数据 */
    TH_BleHeadType_App_GetDevRecordData   = 0x05 ,
    /** 设备返回历史数据 */
    TH_BleHeadType_MCU_ReturnRecordData   = 0x06 ,
    /** 设置采样频率和保存频率 */
    TH_BleHeadType_APP_SetSamplingFrequency   = 0x07 ,
    /** 设备返回采样频率和保存频率 */
    TH_BleHeadType_MCU_ReturnSamplingFrequency = 0x08 ,
    /** App返回收到历史数据反馈 */
    TH_BleHeadType_App_DataFeedback        = 0x09 ,
    
    /** APP设置、读取温湿度校准 */
    TH_BleHeadType_App_SetOrGetCalibrationNum = 0x0A ,
    /** MCU返回温湿度校准值 */
    TH_BleHeadType_MCU_ReturnCalibrationNum = 0x0B ,
    /** APP获取设备信息 */
//    TH_BleHeadType_App_GetDevInfo   = 0x10 ,
    /** 设备返回设备信息 */
    TH_BleHeadType_MCU_ReturnDevInfo   = 0x11 ,
    /** APP获取设备报警功能 设备回复报警功能信息 */
    TH_BleHeadType_AlarmDataInfo = 0x12 ,
    /** APP设置设备报警功能 */
    TH_BleHeadType_App_SetAlarmDataInfo = 0x13 ,
    /** APP设置设备wifi/4G例行上报时间  */
    TH_BleHeadType_App_Set_Wifi_4G_UploadTime = 0x14 ,
    /** 设备返回设备wifi/4G例行上报时间 */
    TH_BleHeadType_MCU_Return_Wifi_4G_UploadTime  = 0x15 ,
    
    /** APP获取wifi网络状态 */
    TH_BleHeadType_App_GetWiFiStatus  = 0x16 ,
    /** 设备返回wifi网络状态 */
    TH_BleHeadType_MCU_ReturnWiFiStatus = 0x17 ,
    
    
    /// APP设置/读取设备蜂鸣器功能
    TH_BleHeadType_App_SetOrGetBuzzerState = 0x20 ,
    /// 设备返回蜂鸣器状态
    TH_BleHeadType_MCU_ReturnBuzzerState = 0x021 ,
    /// APP设置/读取设备闹钟功能
    TH_BleHeadType_App_SetOrGetAlarmClock = 0x22 ,
    /// 设备返回闹钟
    TH_BleHeadType_MCU_ReturnAlarmClock = 0x23 ,
    /// APP设置/读取设备整点报时功能
    TH_BleHeadType_App_SetOrUpdateReportPunctually = 0X24 ,
    /// 设备返回整点报时功能
    TH_BleHeadType_MCU_ReturnReportPunctually = 0x25 ,
    /// 7.4.10  APP设置/读取设备小夜灯
    TH_BleHeadType_App_SetOrGetNightLightState = 0x26 ,
    /// 设备返回小夜灯状态
    TH_BleHeadType_MCU_ReturnNightLightState = 0x27 ,
    /// 7.4.11  APP设置/读取背光亮度
    TH_BleHeadType_App_SetOrGetGroundLightState = 0x28 ,
    /// 设备返回背光状态
    TH_BleHeadType_MCU_ReturnGroundLightState = 0x29 ,
    /// 7.4.12  APP设置/读取单位
    TH_BleHeadType_App_SetOrGetUnit = 0x2A ,
    ///  设备返回单位
    TH_BleHeadType_MCU_ReturnUnit = 0x2B ,
    /// 7.4.13  APP寻物功能
    TH_BleHeadType_App_Lost = 0x2C ,
    /// 返回寻物功能状态
    TH_BleHeadType_MCU_ReturnLost = 0x2D ,
    /// 7.4.14 App绑定设备
    TH_BleHeadType_Binding_Status = 0x2E ,
    
    
    /// BM设备定时返回设备状态
    TH_BleHeadType_BM_MCU_ReturnDevState     = 0x31 ,
    /// BM设备返回历史记录
    TH_BleHeadType_BM_MCU_ReturnRecordData   = 0x32 ,
    
    /// 清除BM里面的历史记录
    TH_BleHeadType_App_ClearRecordData = 0x40 ,
    /// 返回清除记录结果
    TH_BleHeadType_MCU_ClearRecordDataState = 0x41 ,
    /// 查询BM是否支持历史记录
    TH_BleHeadType_App_GetSupportRecordData = 0x42,
    /// BM回应是否支持历史记录
    TH_BleHeadType_App_ReturnSupportRecordData = 0x43,
    /// app获取设备支持功能
    TH_BleHeadType_App_GetSupportFeatures = 0x80 ,
    /// 设备返回支持功能
    TH_BleHeadType_MCU_ReturnSupportFeatures = 0x81 ,
    
};

/** 温湿度计设备类型定义 */
typedef NS_ENUM (NSInteger, Hygrothermograph_DevType) {
    Hygrothermograph_DevType_Ble = 0x00 ,
    Hygrothermograph_DevType_Ble_WiFi = 0x01 ,
    Hygrothermograph_DevType_Ble_4G = 0x02 ,
};


/** 温湿度计Wi-Fi连接状态枚举定义 */
typedef NS_ENUM(NSInteger, Hygrothermograph_ConnectStateType) {
    /** 未配置AP */
    Hygrothermograph_ConnectStateType_UnSetup        = 0x00 ,
    /** 连接AP失败，连接时密码错误、AP信号不好、主动断开都会是这个状态 */
    Hygrothermograph_ConnectStateType_ConnectFailed  = 0x01 ,
    /** 连接的AP信号不好 */
    Hygrothermograph_ConnectStateType_BadSignal      = 0x02 ,
    /** 成功连接上AP */
    Hygrothermograph_ConnectStateType_Connecd        = 0x03 ,
    /** 正在连接AP */
    Hygrothermograph_ConnectStateType_Connecting     = 0x04 ,
};

/** 温湿度计工作状态枚举定义 */
typedef NS_ENUM(NSInteger, Hygrothermograph_WorkStateType) {
    /** 唤醒 */
    Hygrothermograph_WorkStateType_Wake             = 0x00 ,
    /** 进入休眠 */
    Hygrothermograph_WorkStateType_Sleep            = 0x01 ,
    /** 模块准备就绪 */
    Hygrothermograph_WorkStateType_Ready            = 0x02 ,
};

/** 温湿度计配网失败原因枚举定义 */
typedef NS_ENUM(NSInteger, Hygrothermograph_FailedType) {
    /** 未知原因 */
    Hygrothermograph_FailedType_Unknow              = 0x00 ,
    /** AP信号差 */
    Hygrothermograph_FailedType_APSignalPoor        = 0x01 ,
    /** 密码错误 */
    Hygrothermograph_FailedType_PasswordWrong       = 0x02 ,
    /** 获取不到IP */
    Hygrothermograph_FailedType_CantGetIP           = 0x03 ,
};

/// 设备状态枚举定义
typedef NS_ENUM(NSInteger, TH_DevStateType) {
    /// APP读取时上报(若BM模块有历史功能,收到该指令不保存历史)
    TH_DevStateType_ReadReport = 0x00 ,
    /// 普通上报(前后两次差值超过设定值(灵敏度),MCU主动上报)(若BM模块有历史功能,收到该指令保存历史)
    TH_DevStateType_NormalReport = 0x01 ,
    /// 报警上报(当前值超出报警范围值,MCU主动上报)(若BM模块有历史功能,收到该指令保存历史)
    TH_DevStateType_AlarmReport = 0x02 ,
};

/// 闹钟状态枚举定义
typedef NS_ENUM(NSInteger, TH_AlarmClockState) {
    /// 增加闹钟
    TH_AlarmClockState_Add = 0x00 ,
    /// 删除闹钟(不需要处理时间值)
    TH_AlarmClockState_Del = 0x01 ,
    /// 停止该闹钟(停止对应的编号闹钟,不需要处理时间值)
    TH_AlarmClockState_Stop = 0x02 ,
    /// 获取设备已存在的闹钟(编号模式时间都设为0)
    TH_AlarmClockState_Get = 0x03 ,
};

/// 闹钟模式
typedef NS_ENUM(NSInteger, TH_AlarmClockMode) {
    /// 只触发一次
    TH_AlarmClockMode_Once = 0x00 ,
    /// 每天都触发
    TH_AlarmClockMode_Everyday = 0x01 ,
};

/// 温湿度计支持的设备功能
typedef NS_ENUM(NSInteger, TH_Dev_SupportFeatures) {
    /// 温湿度校准
    TH_Dev_SupportFeatures_Calibration = 0 ,
    /// 蜂鸣器报警
    TH_Dev_SupportFeatures_BuzzerAlarm = 1 ,
    /// 闹钟功能
    TH_Dev_SupportFeatures_AlarmClock = 2 ,
    /// 整点报时
    TH_Dev_SupportFeatures_ReportPunctually = 3 ,
    /// 小夜灯
    TH_Dev_SupportFeatures_NightLight = 4 ,
    /// 背光亮度
    TH_Dev_SupportFeatures_GroundLight = 5 ,
    /// 寻物功能(APP点击寻物时,设备蜂鸣器会响)
    TH_Dev_SupportFeatures_Lost = 6 ,
    /// 接收 APP 下发指令
    TH_Dev_SupportFeatures_ReceiveCommand = 7 ,
    /// 温度单位切换
    TH_Dev_SupportFeatures_TemperatureUnitSwitch = 8 ,
    /// 温度报警
    TH_Dev_SupportFeatures_TemperatureAlarm = 9 ,
    /// 湿度报警
    TH_Dev_SupportFeatures_HumidityAlarm = 10 ,

};


#endif /* ELHygrothermographBleHeader_h */
