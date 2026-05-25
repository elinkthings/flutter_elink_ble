//
//  ELToothburshHeader.h
//  Elink
//
//  Created by iot_user on 2020/5/11.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#ifndef ELToothburshHeader_h
#define ELToothburshHeader_h

#import "ELSDKHeader.h"

typedef NS_ENUM(NSUInteger, ToothSupportGearType) {
    ToothSupportGearTypeUnknown_00 = 0x00, //Unsupported gear(不支持的档位)
    ToothSupportGearTypeOneGear_01 = 0x01, //First gear(一档)
    ToothSupportGearTypeTwoGear_02 = 0x02, //Second gear(二档)
};


//Working gear(工作档位)
typedef NS_ENUM(NSUInteger, ToothbrushGearType) {
    ToothbrushGearTypeStop_00 = 0x00,      //Stop the motor(停止电机)
    ToothbrushGearTypeClean_01 = 0x01,      //clean(清洁)
    ToothbrushGearTypeWhite_02 = 0x02,      //Whitening(美白)
    ToothbrushGearTypeMassage_03 = 0x03,    //massage(按摩)
    ToothbrushGearTypeSensitive_04 = 0x04, //sensitive(敏感)
    ToothbrushGearTypePolish_05 = 0x05,     //polishing(抛光)
    ToothbrushGearTypeGumCare_06 = 0x06,    //Gum care(牙龈护理)
    ToothbrushGearTypeRefresh_07 = 0x07,    //gargle(漱口)
    ToothbrushGearTypeHealthcare_08 = 0x08,    //health care(保健)
    ToothbrushGearTypeNewbie_09 = 0x09,     //Novice(新手)
    ToothbrushGearTypeSoft_0A = 0x0A,      //Soft(舒柔)
    ToothbrushGearTypeGentle_0B = 0x0B,     //gentle(轻柔)
    ToothbrushGearTypeCare_0C = 0x0C,     //Care(呵护)
    ToothbrushGearTypeCustom_FF = 0xFF,     //manual setting(手动设置)
};

typedef NS_ENUM(NSUInteger, ToothbrushDataType) {
    ToothbrushDataTypeSetGear_A702 = 0x02,//Set gear(设置档位)
    ToothbrushDataTypeGetGear_A703 = 0x03,//Get the current working gear(获取当前工作的档位)
    ToothbrushDataTypeTry_A706 = 0x06,//try out(试用)
    ToothbrushDataTypeWorkPhase_A707 = 0x07,//Work Phase(工作阶段)
    ToothbrushDataTypeSetCustomData_A709 = 0x09,//Set manual setting mode(设置手动设置模式)
    ToothbrushDataTypeGetCustomGear_A70A = 0x0A,//Get manually set data(获取手动设置的数据)
    ToothbrushDataTypeSwitchWork_A70B = 0x0B,//Switch toothbrush(开关牙刷)
    ToothbrushDataTypeSetTwoGearDefault_A70C = 0x0C,//Set second gear default(设置二档默认)
    ToothbrushDataTypeGetTwoGearDefault_A70D = 0x0D,//Get second gear default(获取二档默认)
    ToothbrushDataTypeAppPreventSplashing_A710 = 0x10,//APP request Prevent Splashing mode 防飞溅
    ToothbrushDataTypeMcuPreventSplashing_A711 = 0x11,//MCU response Prevent Splashing mode 防飞溅
    ToothbrushDataTypeGetTwoGearDefault_A7FC = 0xFC,//获取当前工作状态（针对获取已工作时长）
    ToothbrushDataTypeToothbrushData_A7FD = 0xFD,//Brushing data(刷牙数据)
    ToothbrushDataTypeReportResult_A7FE = 0xFE,//Report received data result(上报接收数据结果)
};

typedef NS_ENUM(NSUInteger, ToothbrushA6DataType) {
    ToothbrushA6DataTypeTriaxialDirection_02 = 0x02, //Get the three-axis direction of the toothbrush(获取牙刷三轴方向)
    ToothbrushA6DataTypeTriaxialData_05 = 0x05, //Get toothbrush three-axis data(获取牙刷三轴数据)
    ToothbrushA6DataTypeOfflineDataCount_11 = 0x11, //Cmd toothbrush offline data count(APP 获取离线历史记录条数 二级指令 0x11)
    ToothbrushA6DataTypeOfflineDataStart_12 = 0x12, //Cmd toothbrush offline data start(APP 请求接收离线历史记录 二级指令 0x12)
    ToothbrushA6DataTypeOfflineDataCancel_13 = 0x13, //Cmd toothbrush offline data cancel(APP 取消接收离线历史记录 二级指令 0x13)
    ToothbrushA6DataTypeOfflineDataClear_14 = 0x14, //Cmd toothbrush offline data clear(APP 请求清空离线历史记录 二级指令 0x14)
    ToothbrushA6DataTypeOfflineData_15 = 0x15, //Data toothbrush offline data(离线历史记录数据上报给 APP 二级指令 0x15)
    ToothbrushA6DataTypeGetOfflineData_16 = 0x16, //Obtain offline history records, this command is sent one by one and then sent again when offline history records are received 获取离线历史记录，该命令为逐条发送再收到离线历史记录的时候再次发送该命令
};


typedef NS_ENUM(NSUInteger, ToothbrushSetResult) {
    ToothbrushSetResultSuccess,//Set successfully(设置成功)
    ToothbrushSetResultFail,//Setting failed for unknown reason(设置失败，原因未知)
    ToothbrushSetResultUnsupported,//Does not support settings(不支持设置)
    ToothbrushSetResultLowPower,//Setting failed, battery voltage is low(设置失败，电池电压不足)
    ToothbrushSetResultCharging,//Setting failed, charging(设置失败，正在充电)
    ToothbrushSetResultWorking,//Setting failed, working(设置失败，正在工作)
};
//Work Phase(工作阶段)
typedef NS_ENUM(NSUInteger, ToothbrushWorkPhaseType) {
    ToothbrushWorkPhaseTypeLeftTop,
    ToothbrushWorkPhaseTypeLeftBottom,
    ToothbrushWorkPhaseTypeRightTop,
    ToothbrushWorkPhaseTypeRightBottom
};

//Y axis direction(Y轴方向)
typedef NS_ENUM(NSUInteger, ToothbrushTriaxialDirection) {
    ToothbrushTriaxialDirectionYTop_01 = 1,//Y axis up(Y轴朝上)
    ToothbrushTriaxialDirectionYBottom_02 = 2,//Y axis down(Y轴朝下)
    ToothbrushTriaxialDirectionYLeft_03 = 3,//Y axis left(Y轴朝左)
    ToothbrushTriaxialDirectionYRight_04 = 4,//Y axis right(Y轴朝右)
};

/** 0x16回复命令枚举定义 */
typedef NS_ENUM(NSInteger, ToothbrushOfflineRecrodStatusType) {
    ToothbrushOfflineRecrodStatusType_DataCompleted_00 = 0x00 , //数据全部发送完成
    ToothbrushOfflineRecrodStatusType_DataAbnormal_01 = 0x01  , //数据发送异常
    ToothbrushOfflineRecrodStatusType_SendNextData_02 = 0x02  , //app通知模块可以发送下一组数据
};


typedef struct {
    int interval;//operating hours(工作时间)
    ToothbrushGearType gearType;//Gear(档位)
    ToothSupportGearType supportType;//What Gear(什么档)
} ToothbrushWorkGear, ToothbrushWorkGear;

typedef struct {
    ToothbrushGearType gear;
    ToothSupportGearType supportType;//一档、二档
    ToothbrushWorkPhaseType workPhase;
} ToothBrushWorkPhase, ToothBrushWorkPhase;

typedef struct {
    ToothbrushGearType gear;    //模式
    ToothSupportGearType supportType;//档位 一档、二档
    ToothbrushWorkPhaseType workPhase;  //工作阶段
    int workTime;   //已工作时间
    int defaultWorktime;    //默认工作时长，未获取到为FF
} ToothBrushNewWorkPhase, ToothBrushNewWorkPhase;

//
typedef struct {
    int frequency;
    int duty;
    int interval;
} ToothbrushCustomData, ToothbrushCustomData;

//Brushing data(刷牙数据)
typedef struct {
    ToothbrushGearType gear;//Working gear(工作档位)
    int workTime;//work time(工作时长)
    int leftTime;//Time left(左边时长)
    int rightTime;//Right time(右边时长)
    int battery;//battery(电量)

} ToothbrushData, ToothbrushData;

//Brushing offline data(刷牙数据)
typedef struct {
    unsigned char year;
    unsigned char month;
    unsigned char day;
    unsigned char hour;
    unsigned char minute;
    unsigned char second;
    ToothbrushGearType gearType;
    unsigned short workTime;
    unsigned short leftTime;
    unsigned short rightTime;
    unsigned char battery;//电池电量
    unsigned short defaultWorkTime; //默认工作总时长
} ToothbrushOfflineData;

#endif /* ELToothburshHeader_h */
