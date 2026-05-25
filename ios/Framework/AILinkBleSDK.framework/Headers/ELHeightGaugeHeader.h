//
//  ELHeightGaugeHeader.h
//  Elink
//
//  Created by iot_user on 2019/5/10.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#ifndef ELHeightGaugeHeader_h
#define ELHeightGaugeHeader_h

//单位
//typedef NS_ENUM(NSUInteger, ELHeightGaugeUnitType) {
//    ELHeightGaugeUnitType_cm = 0,
//    ELHeightGaugeUnitType_inch = 1,
//    ELHeightGaugeUnitType_ft_in = 2, //feet-inch
//};

//abnormal(异常)
typedef NS_ENUM(NSUInteger, ELHeightGaugeFailCode) {
    ELHeightGaugeFailCodeMeasureFailed  = 0, //Measurement failed(测量失败)
};

#endif /* ELHeightGaugeHeader_h */
