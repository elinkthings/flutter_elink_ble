//
//  ELNutritionScaleBleHeader.h
//  Elink
//
//  Created by iot_user on 2020/8/21.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#ifndef ELNutritionScaleBleHeader_h
#define ELNutritionScaleBleHeader_h

#import "ELSDKHeader.h"


typedef NS_ENUM(NSUInteger, NutritionScaleTestStatus) {
    //Real-time weight(实时重量)
    NutritionScaleTestStatus_RealTime = 1,
    //Stable weight(稳定重量)
    NutritionScaleTestStatus_Stable = 2,

};

/** 营养秤 Weight unit(重量单位)*/
typedef NS_ENUM(NSInteger, NutritionScaleWeightUnit) {
    /** g */
    NutritionScaleWeightUnit_G             = 0 ,
    /** ml */
    NutritionScaleWeightUnit_ML            = 1 ,
    /** lb:oz */
    NutritionScaleWeightUnit_LB_OZ         = 2 ,
    /** oz */
    NutritionScaleWeightUnit_OZ            = 3 ,
    /** kg */
    NutritionScaleWeightUnit_KG            = 4 ,
    /** 斤 */
    NutritionScaleWeightUnit_JIN           = 5 ,
    /** 牛奶 ml */
    NutritionScaleWeightUnit_MILK_ML       = 6 ,
    /** 水 ml */
    NutritionScaleWeightUnit_WATER_ML      = 7 ,
    /** 牛奶 fl.oz */
    NutritionScaleWeightUnit_MILK_FLOZ     = 8 ,
    /** 水 fl.oz */
    NutritionScaleWeightUnit_WATER_FLOZ    = 9 ,
    /** lb */
    NutritionScaleWeightUnit_LB            = 10 ,
    
    /** Unsupported unit */
    NutritionScaleWeightUnit_Fail          = 0xFF ,
};


typedef NS_ENUM(NSUInteger, NutritionScaleErrorStatus) {
    //Over Range(1: 超重 0：正常)
    NutritionScaleErrorStatus_Over_Range_mask = 1 << 0,
    //Low Power(1：电量过低，无法测试 0：正常)
    NutritionScaleErrorStatus_Low_Power_mask = 1 << 1,

};

#endif /* ELNutritionScaleBleHeader_h */
