//
//  ELBloodBleSDKHeader.h
//  Elink
//
//  Created by iot_user on 2019/5/11.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#ifndef ELBloodBleSDKHeader_h
#define ELBloodBleSDKHeader_h
#import "ELSDKHeader.h"

#define BloodUnitDic @{\
                       @(ELBloodUnitType_mmhg):BloodUnit_mmhg,\
                       @(ELBloodUnitType_kPa):BloodUnit_kPa\
                      }

#define BloodUnit_mmhg  AiLinkBloodUnit_mmHgStr
#define BloodUnit_kPa   AiLinkBloodUnit_kPaStr

#define kPa_To_mmHg(kPa)   (kPa*7.5006168270417)
#define mmHg_To_kPa(mmHg)   (mmHg/7.5006168270417)

//type of data(数据类型)
typedef NS_ENUM(NSUInteger, ELBloodBleDataModelType) {
    ELBloodBleDataModelTypeStable,    //Stable data(稳定数据)
    ELBloodBleDataModelTypeRealTime,  //Real-time data(实时数据)
};
//error code(错误码)
typedef NS_ENUM(NSUInteger, ELBloodFailCode) {
    ELBloodFailCodeUnfoundDia     = 0, //High voltage not found(未找到高压)
    ELBloodFailCodeCantInflating  = 1, //Unable to pressurize normally, please check whether the cuff is inserted, or re-insert the cuff trachea(无法正常加压，请检查是否插入袖带，或者重新插拔袖带气管)
    ELBloodFailCodePowerLow       = 2, //Low battery(电量低)
    ELBloodFailCodeSignalError    = 3, //Abnormal sensor signal(传感器信号异常)
    ELBloodFailCodeMeasureError   = 4, //Abnormal measurement results(测量结果异常)
    ELBloodFailCodeWristbandError = 5, //Wrist strap is too tight or the airway is blocked(腕带过紧或气路堵塞)
    ELBloodFailCodeHaveInterence  = 6, //Serious pressure interference during measurement(测量中压力干扰严重)
    ELBloodFailCodeOverStressed   = 7, //Overpressure 290(压力超 290)
    ELBloodFailCodeDataError      = 8, //Abnormal calibration data or abnormal storage IC(标定数据异常或存储 IC 异常)
};



//Interactive command(交互指令)
typedef NS_ENUM(NSUInteger, ELBloodInteractionType) {
    ELBloodInteractionTypeStartTest   = 0, //Start measurement(开始测量)
    ELBloodInteractionTypeStopTest    = 1, //Stop testing(停止测试)
    ELBloodInteractionTypeBoot        = 2, //Boot(开机)
    ELBloodInteractionTypeShutdown    = 3, //Shut down(关机)
};

typedef NS_ENUM(NSUInteger, ELBloodBleSwitchVoiceType) {
    ELBloodBleSwitchVoiceTypeOn  = 0x00, //turn on(打开)
    ELBloodBleSwitchVoiceTypeOff = 0x01, //shut down(关闭)
};


#endif /* ELBloodBleSDKHeader_h */
