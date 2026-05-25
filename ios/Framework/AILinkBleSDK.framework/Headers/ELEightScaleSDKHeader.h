//
//  ELEightScaleSDKHeader.h
//  Elink
//
//  Created by iot_user on 2020/6/3.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#ifndef ELEightScaleSDKHeader_h
#define ELEightScaleSDKHeader_h
#import "ELSDKHeader.h"


typedef NS_ENUM(NSUInteger, EightScaleWeightType) {
    EightScaleWeightTypeAuto    = 0x01,//Real-time weight(实时体重)
    EightScaleWeightTypeStable  = 0x02,//Stabilize weight(稳定体重)
};

//Weight data(体重数据)
typedef struct EightScaleWeightStruct{
    //Weight type(体重类型)
    EightScaleWeightType weightType;
    //Original weight(体重原始值)
    int weight;
    //Weight decimal point(体重小数点)
    int point;
    //unit(单位)
    ELDeviceWeightUnit unit;
} EightScaleWeightStruct;

//Impedance measurement process（阻抗测量过程）
typedef NS_ENUM(NSUInteger, EightScaleAdcTestStep) {
    EightScaleAdcTestStepTesting = 0x01,//Measuring impedance（测阻抗中）
    EightScaleAdcTestStepFailure = 0x02,//Impedance measurement failed（测阻抗失败）
    //The impedance measurement is successful, bring the impedance data, and use the APP algorithm (APP will calculate according to the algorithm identification of byte7)
    //测阻抗成功，带上阻抗数据，并使用APP算法(APP 会根据byte7的算法标识进行计算)
    EightScaleAdcTestStepSuccess = 0x03,
    EightScaleAdcTestStepTestEnd = 0x04,//End of impedance measurement.（测阻抗结束。）
    EightScaleAdcBfrTestStepSuccess = 0x05, //阻抗测量成功，并使用 MCU 端算法。体脂算法 ID=0。
};
// 阻抗类型
typedef NS_ENUM(NSUInteger, EightScaleAdcType) {
    EightScaleAdcTypeFeet        = 0x00,//Two-foot impedance（双脚阻抗）
    EightScaleAdcTypeHands       = 0x01,//Hands resistance（双手阻抗）
    EightScaleAdcTypeLeftHand    = 0x02,//Left hand impedance（左手阻抗）
    EightScaleAdcTypeRightHand   = 0x03,//Right hand impedance（右手阻抗）
    EightScaleAdcTypeLeftFoot    = 0x04,//Left foot impedance（左脚阻抗）
    EightScaleAdcTypeRightFoot   = 0x05,//Right foot impedance（右脚阻抗）
    EightScaleAdcTypeLWholeBody  = 0x06,//Left whole body impedance（左全身阻抗）
    EightScaleAdcTypeRWholeBody  = 0x07,//Right whole body impedance（右全身阻抗）
    EightScaleAdcTypeRHand_LFoot = 0x08,//Impedance of right hand and left foot（右手左脚阻抗）
    EightScaleAdcTypeLHand_RFoot = 0x09,//Impedance of left hand and right foot（左手右脚阻抗）
    EightScaleAdcTypeTrunk       = 0x0A,//Torso impedance（躯干阻抗）
};
//Impedance data（阻抗数据）
typedef struct EightScaleAdcStruct{
    //Impedance measurement stage（阻抗测量阶段）
    EightScaleAdcTestStep adcTestStep;
    //Impedance type（阻抗类型）
    EightScaleAdcType adcType;
    //Impedance value（阻抗值）
    unsigned int adc;
    //Algorithm Id（算法Id）
    int algorithmID;
    
}EightScaleAdcStruct;

//Heart rate measurement process（心率测量过程）
typedef NS_ENUM(NSUInteger, EightScaleHeartRateTestStep) {
    EightScaleHeartRateTestStepTesting = 0x01,//Heart rate measurement（心率测量中）
    EightScaleHeartRateTestStepSuccess = 0x02,//Successful heart rate measurement, bring heart rate data（测心率成功，带上心率数据）
    EightScaleHeartRateTestStepFailure = 0x03,//Failed to measure heart rate（测心率失败）
};

//Temperature data（温度数据）
typedef struct EightScaleTempStruct{
    //Positive and negative temperature(正负温度)
    BOOL negative;
    //temperature(温度)
    int temp;
    //Decimal point(小数点)
    int point;
    //unit(单位)
    ELDeviceTemperatureUnit unit;
}EightScaleTempStruct;


typedef NS_ENUM(NSUInteger, EightScaleSwitchUnitResult) {
    EightScaleSwitchUnitResultSuccess   =0,//Successful operation(操作成功)
    EightScaleSwitchUnitResultFailure   =1,//operation failed(操作失败)
    EightScaleSwitchUnitResultOperation =2,//In operation(正在操作中)
};

//Measurement status(测量状态)
typedef NS_ENUM(NSUInteger, EightScaleTestStatus) {
    EightScaleTestStatusIdle     = 0,//Idle(闲置)
    EightScaleTestStatusTesting  = 1,//Testing(测量中)
    EightScaleTestStatusComplete = 2,//Complete(测量完成)
    EightScaleTestStatusError    = 3,//Error(测量出错)
};

/** 八电极设备mcuhead枚举定义 */
typedef NS_ENUM(NSUInteger, EightScale_MCU_HeadType) {
    /** 上报称重状态 */
    EightScale_MCU_HeadType_ReportWeightData    = 0x01 ,
    /** 上报阻抗数据 */
    EightScale_MCU_HeadType_ReportADC           = 0x02 ,
    /** 上报心率数据 */
    EightScale_MCU_HeadType_ReportHeartRate     = 0x03 ,
    /** 发送温度数据 */
    EightScale_MCU_HeadType_ReportTem           = 0x04 ,
    /** 上报身高数据 */
    EightScale_MCU_HeadType_ReportHeightData    = 0x05 ,
    
    /** 请求用户信息 */
    EightScale_MCU_HeadType_RequestUserData     = 0x08 ,
    /** 发送体脂数据 */
    EightScale_MCU_HeadType_ReportBodyFatData   = 0x09 ,
    
    /** 发送请求补全体脂数据 */
    EightScale_MCU_HeadType_CompletionBodyFatData    = 0x0E ,
    
    /** 发送测量完成 */
    EightScale_MCU_HeadType_ReportCompleted     = 0x0F ,
    
    
    /** 下发操作指令 */
    EightScale_MCU_HeadType_SendOperation       = 0x81 ,
    /** 回复操作结果 */
    EightScale_MCU_HeadType_ReportOperation     = 0x82 ,
    /** 回复测量完成 */
    EightScale_MCU_HeadType_SendCompleted       = 0x84 ,
    
    /** 设备上发错误码 */
    EightScale_MCU_HeadType_ReportErrorCode     = 0xFF ,
    
 
    
};

//Character(角色) 同四电极体脂秤枚举
typedef NS_ENUM(NSUInteger, EightScaleRole) {
    EightScaleRole_Ordinary   = 0x00,//Ordinary(普通人)
    EightScaleRole_Athlete    = 0x01,//Athlete(业余运动员)
    EightScaleRole_AthletePro = 0x02,//AthletePro(专业运动员)
    EightScaleRole_Pregnancy  = 0x03,//Pregnancy(孕妇)
};

///app下发指令操作枚举定义
typedef NS_ENUM(NSUInteger, EightScaleOperationType) {
    /** 校准 */
    EightScaleOperationType_Calibration          = 0x01 ,
    /** 温度单位切换 */
    EightScaleOperationType_UpdateTemUnit               ,
    /** 重量单位切换 */
    EightScaleOperationType_UpdateWeightUnit            ,
    /** 身高单位切换 */
    EightScaleOperationType_UpdateHeightUnit            ,
};

///设备上发错误码
typedef NS_ENUM(NSUInteger, EightScaleErrorCodeType) {
    /** 超重 */
    EightScaleErrorCodeType_Overweight          = 0x01 ,
} ;


//Impedance measurement process（阻抗测量过程） 双频八电极
typedef NS_ENUM(NSUInteger, DualBandEightScaleAdcMeasureStatus) {
    DualBandEightScaleAdcMeasureStatus_Testing       = 0x04,//测阻抗中
   
    DualBandEightScaleAdcMeasureStatus_Fail          = 0x06,//测阻抗失败
    DualBandEightScaleAdcMeasureStatus_SuccessCustom = 0x07,//The impedance measurement is successful, and the APP algorithm is used. The APP will identify the corresponding algorithm according to VID and PID(测阻抗成功，并使用 APP 算法，APP 会根据 VID,PID 来识 别对应算法)
};

#endif /* ELEightScaleSDKHeader_h */
