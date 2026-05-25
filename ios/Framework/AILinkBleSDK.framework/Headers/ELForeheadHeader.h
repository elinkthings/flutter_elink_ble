//
//  ELForeheadHeader.h
//  Elink
//
//  Created by iot_user on 2019/5/10.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#ifndef ELForeheadHeader_h
#define ELForeheadHeader_h

#import "ELSDKHeader.h"

//单位
#define ForeheadUnit_CStr   AiLinkBleTempUnit_CStr
#define ForeheadUnit_FStr   AiLinkBleTempUnit_FStr

#define ForeheadUnitDic @{@(ForeheadUnitType_C):ForeheadUnit_CStr,@(ForeheadUnitType_F):ForeheadUnit_FStr}
//
#define C_TO_F(C)                    (C*1.8+32)     //F = C*1.8 + 32
#define CFMultiple                      1.8
#define F_TO_C(F)                    ((F-32)/1.8)     //F = C*1.8 + 32

//异常
typedef NS_ENUM(NSUInteger, ForeheadFailCode) {
    ForeheadFailCodeTemperatureTooHigh  = 0, //Temperature is too high(温度过高)
    ForeheadFailCodeTemperatureTooLow   = 1, //The temperature is too low(温度过低)
};

#endif /* ELForeheadHeader_h */
