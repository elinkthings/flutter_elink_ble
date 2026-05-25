//
//  ELHeightBodyFatScaleBleHeader.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/3/24.
//  Copyright © 2021 IOT. All rights reserved.
//

#ifndef ELHeightBodyFatScaleBleHeader_h
#define ELHeightBodyFatScaleBleHeader_h

/** 身高体脂秤 ble head  type 枚举定义 */
typedef NS_ENUM (NSInteger, HeightBodyFatScale_BleHeadType){
    /* APP下发用户信息 */
    HeightBodyFatScale_BleHeadType_App_SendUserData    = 0x01 ,
    /** MCU 返回收到用户数据结果 */
    HeightBodyFatScale_BleHeadType_MCU_ReturnUserData  = 0x02 ,
    /** MCU请求用户信息 */
    HeightBodyFatScale_BleHeadType_MCU_RequestUserData = 0x03 ,
    /** APP/MCU 设置单位 */
    HeightBodyFatScale_BleHeadType_App_MCU_SetupUnit   = 0x04 ,
    /** APP/MCU 回复设置结果 */
    HeightBodyFatScale_BleHeadType_App_MCU_ReturnUnitResult     = 0x05 ,
    /** APP 下发工作模式 */
    HeightBodyFatScale_BleHeadType_App_SetWorkMode      = 0x06 ,
    /** MCU回复工作模式 */
    HeightBodyFatScale_BleHeadType_MCU_ReturnWorkMode   = 0x07 ,
    /** APP 读取声音设置 */
    HeightBodyFatScale_BleHeadType_App_GetVideoSetup    = 0x08 ,
    /** APP/MCU 声音设置 */
    HeightBodyFatScale_BleHeadType_App_MCU_VideoSetup   = 0x09 ,
    /** APP/MCU 回复声音设置 */
    HeightBodyFatScale_BleHeadType_App_MCU_ReturnVideoSetup = 0x0A ,
    /** APP 获取设备状态 */
    HeightBodyFatScale_BleHeadType_App_GetDeviceState     = 0x0B ,
    /** MCU 回复设备状态 */
    HeightBodyFatScale_BleHeadType_MCU_ReturnDeviceState    = 0x0C ,
    /** MCU 上报称重状态 */
    HeightBodyFatScale_BleHeadType_MCU_ReportWeighingState  = 0x10 ,
    /** MCU 上报阻抗数据 */
    HeightBodyFatScale_BleHeadType_MCU_ReportAdcData        = 0x11 ,
    /** MCU 上报心率数据 */
    HeightBodyFatScale_BleHeadType_MCU_ReportHeartRateData      = 0x12 ,
    /** MCU 上报温度数据 */
    HeightBodyFatScale_BleHeadType_MCU_ReportTemData            = 0x13 ,
    /** MCU 上报身高数据 */
    HeightBodyFatScale_BleHeadType_MCU_ReportHeightData         = 0x14 ,
    /** MCU 上报体脂数据 */
    HeightBodyFatScale_BleHeadType_MCU_ReportBodyFatData        = 0x15 ,
    
    /** MCU 上报抱婴模式的称重状态 */
    HeightBodyFatScale_BleHeadType_MCU_ReportBabyWeighingState  = 0x20 ,
    
    /** MCU 上报体重模式的称重状态 */
    HeightBodyFatScale_BleHeadType_MCU_ReportBodyWeighingState  = 0x30 ,
    
    /** MCU 上报体重身高模式的称重状态 */
    HeightBodyFatScale_BleHeadType_MCU_ReportWeightHeightWeightState = 0x40 ,
    /** MCU 上报体重身高模式的身高数据 */
    HeightBodyFatScale_BleHeadType_MCU_ReportWeightHeightHeightState = 0x41 ,
    
    /** MCU 发送测量完成 */
    HeightBodyFatScale_BleHeadType_MCU_SendWeighingCompleted    = 0x80 ,
    /** APP 回复测量完成 */
    HeightBodyFatScale_BleHeadType_App_ReportWeighingCompleted  = 0x81 ,
    
    /** MCU 上发错误码 */
    HeightBodyFatScale_BleHeadType_MCU_SendWrongCode            = 0xFF ,
};


/** 身高体脂秤设置结果枚举定义 */
typedef NS_ENUM (NSInteger, HeightBodyFatScale_SetupResult) {
    /** 成功 */
    HeightBodyFatScale_SetupResult_Success                  = 0x00 ,
    /** 失败 */
    HeightBodyFatScale_SetupResult_Failure                  = 0x01 ,
    /** 不支持 */
    HeightBodyFatScale_SetupResult_NotSupport               = 0x02 ,
};

/** 身高体脂秤工作模式枚举定义 */
typedef NS_ENUM(NSInteger, HeightBodyFatScale_WorkModeType) {
    /** 身高体脂模式 */
    HeightBodyFatScale_WorkModeType_HeightBodyFatMode       = 0x01 ,
    /** 抱婴模式 */
    HeightBodyFatScale_WorkModeType_BabyMode                = 0x02 ,
    /** 体重模式 */
    HeightBodyFatScale_WorkModeType_WeightMode              = 0x03 ,
    /** 体重身高模式 */
    HeightBodyFatScale_WorkModeType_WeightHeightMode        = 0x04 ,
};

/** 身高体脂秤充电状态枚举定义 */
typedef NS_ENUM(NSInteger, HeightBodyFatScale_ChargingType) {
    /** 不充电 */
    HeightBodyFatScale_ChargingType_NotCharging             = 0x00 ,
    /** 充电中 */
    HeightBodyFatScale_ChargingType_charging                = 0x01 ,
};

/** 身高体脂秤体重是否稳定 */
typedef NS_ENUM(NSInteger, HeightBodyFatScale_WeightStableType) {
    /** 实时体重 */
    HeightBodyFatScale_WeightStableType_RealTime            = 0x01 ,
    /** 稳定体重 */
    HeightBodyFatScale_WeightStableType_Stable              = 0x02 ,
};

/** 身高体脂秤测量阻抗状态 */
typedef NS_ENUM(NSInteger, HeightBodyFatScale_AdcStateType) {
    /** 测量阻抗中 */
    HeightBodyFatScale_AdcStateType_Measuring         = 0x01 ,
    /** 测量阻抗失败 */
    HeightBodyFatScale_AdcStateType_Failed            = 0x02 ,
    /** 测量阻抗成功，使用App算法 */
    HeightBodyFatScale_AdcStateType_Success_UseAppAlgorithm = 0x03 ,
    /** 测量阻抗成功，使用MCU算法 */
    HeightBodyFatScale_AdcStateType_Success_UseMCUAlgorithm = 0x04 ,
    /** 测量阻抗结束 */
    HeightBodyFatScale_AdcStateType_Over              = 0x05 ,
};

/** 阻抗通道枚举定义 */
typedef NS_ENUM(NSInteger, HeightBodyFatScale_AdcAisleType) {
    /** 双手阻抗 */
    HeightBodyFatScale_AdcAisleType_TwoFeets                = 0x00 ,
    /** 双手阻抗 */
    HeightBodyFatScale_AdcAisleType_TwoHands                = 0x01 ,
    /** 左手阻抗 */
    HeightBodyFatScale_AdcAisleType_LeftHand                = 0x02 ,
    /** 右手阻抗 */
    HeightBodyFatScale_AdcAisleType_RightHand               = 0x03 ,
    /** 左脚阻抗 */
    HeightBodyFatScale_AdcAisleType_LeftFeet                = 0x04 ,
    /** 右脚阻抗 */
    HeightBodyFatScale_AdcAisleType_RIghtFeet               = 0x05 ,
    /** 左全身阻抗 */
    HeightBodyFatScale_AdcAisleType_LeftBody                = 0x06 ,
    /** 右全身阻抗 */
    HeightBodyFatScale_AdcAisleType_RightBody               = 0x07 ,
    /** 右手左脚阻抗 */
    HeightBodyFatScale_AdcAisleType_RightHand_LeftFeet      = 0x08 ,
    /** 左手右脚阻抗 */
    HeightBodyFatScale_AdcAisleType_LeftHand_RightFeet      = 0x09 ,
    /** 躯干阻抗 */
    HeightBodyFatScale_AdcAisleType_Body                    = 0x0A ,
};

/** 心率测量状态枚举定义 */
typedef NS_ENUM(NSInteger, HeightBodyFatScale_HeartRateStateType) {
    /** 测心率中 */
    HeightBodyFatScale_HeartRateStateType_Measuring         = 0x01 ,
    /** 测心率成功 */
    HeightBodyFatScale_HeartRateStateType_Success           = 0x02 ,
    /** 测心率失败 */
    HeightBodyFatScale_HeartRateStateType_Failed            = 0x03 ,
};

/** 肥胖等级枚举定义 */
typedef NS_ENUM(NSInteger, HeightBodyFatScale_ObesityGrade) {
   /** 瘦 */
    HeightBodyFatScale_ObesityGrade_Thin                    = 0x00 ,
    /** 健康 */
    HeightBodyFatScale_ObesityGrade_Health                  = 0x01 ,
    /** 肥胖 */
    HeightBodyFatScale_ObesityGrade_Obesity                 = 0x02 ,
    /** 超标 */
    HeightBodyFatScale_ObesityGrade_Exceeding               = 0x03 ,
};

#endif /* ELHeightBodyFatScaleBleHeader_h */
