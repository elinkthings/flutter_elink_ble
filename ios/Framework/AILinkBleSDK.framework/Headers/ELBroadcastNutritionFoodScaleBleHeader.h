//
//  ELBroadcastNutritionFoodScaleBleHeader.h
//  Elink
//
//  Created by iot_user on 2020/8/21.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#ifndef ELBroadcastNutritionFoodScaleBleHeader_h
#define ELBroadcastNutritionFoodScaleBleHeader_h

#import "ELSDKHeader.h"


typedef NS_ENUM(NSUInteger, BroadcastNutritionFoodScaleStatus) {
    //Real-time weight(实时重量)
    BroadcastNutritionFoodScaleStatus_RealTime = 0,
    //Stable weight(稳定重量)
    BroadcastNutritionFoodScaleStatus_Stable = 1,

    //error (测量异常)
    BroadcastNutritionFoodScaleStatus_Error = 2,

};

/** 广播营养秤 Weight unit(重量单位)*/
typedef NS_ENUM(NSInteger, BroadcastNutritionFoodScaleWeightUnit) {
    /** g */
    BroadcastNutritionFoodScaleWeightUnit_G             = 0 ,
    /** ml */
    BroadcastNutritionFoodScaleWeightUnit_ML            = 1 ,
    /** lb:oz */
    BroadcastNutritionFoodScaleWeightUnit_LB_OZ         = 2 ,
    /** oz */
    BroadcastNutritionFoodScaleWeightUnit_OZ            = 3 ,
    /** kg */
    BroadcastNutritionFoodScaleWeightUnit_KG            = 4 ,
    /** 斤 */
    BroadcastNutritionFoodScaleWeightUnit_JIN           = 5 ,
    /** 牛奶 ml */
    BroadcastNutritionFoodScaleWeightUnit_MILK_ML       = 6 ,
    /** 水 ml */
    BroadcastNutritionFoodScaleWeightUnit_WATER_ML      = 7 ,
    /** 牛奶 fl.oz */
    BroadcastNutritionFoodScaleWeightUnit_MILK_FLOZ     = 8 ,
    /** 水 fl.oz */
    BroadcastNutritionFoodScaleWeightUnit_WATER_FLOZ    = 9 ,
    /** lb */
    BroadcastNutritionFoodScaleWeightUnit_LB            = 10 ,
    
    /** Unsupported unit */
    BroadcastNutritionFoodScaleWeightUnit_Fail          = 0xFF ,
};


typedef NS_ENUM(NSUInteger, BroadcastNutritionFoodScaleErrorStatus) {
    //Low Power(1：电量过低，无法测试 0：正常)
    BroadcastNutritionFoodScaleErrorStatus_Low_Power_mask = 1 << 0,
    //Over Range(1: 超重 0：正常)
    BroadcastNutritionFoodScaleErrorStatus_Over_Range_mask = 1 << 1,

};

#endif /* ELBroadcastNutritionFoodScaleBleHeader_h */
