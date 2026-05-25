//
//  ELAiFreshNutritionScaleBleHeader.h
//  Elink
//
//  Created by LarryZhang on 2021/12/2.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#ifndef ELAiFreshNutritionScaleBleHeader_h
#define ELAiFreshNutritionScaleBleHeader_h


typedef NS_ENUM(NSUInteger, AiFreshNutritionScaleTestStatus) {
    //Real-time weight(实时重量)
    AiFreshNutritionScaleTestStatus_RealTime = 0xCE,
    //Stable weight(稳定重量)
    AiFreshNutritionScaleTestStatus_Stable = 0xCA,

};

/** 营养秤 Weight unit(重量单位)*/
typedef NS_ENUM(NSInteger, AiFreshNutritionScaleWeightUnit) {
    /** g */
    AiFreshNutritionScaleWeightUnit_G             = 0 ,
    /** ml */
    AiFreshNutritionScaleWeightUnit_ML            = 1 ,
    /** lb:oz */
    AiFreshNutritionScaleWeightUnit_LB_OZ         = 2 ,
    /** oz */
    AiFreshNutritionScaleWeightUnit_OZ            = 3 ,
    /** kg */
    AiFreshNutritionScaleWeightUnit_KG            = 4 ,
    /** 斤 */
    AiFreshNutritionScaleWeightUnit_JIN           = 5 ,
    /** 牛奶 ml */
    AiFreshNutritionScaleWeightUnit_MILK_ML       = 6 ,
    /** 水 ml */
    AiFreshNutritionScaleWeightUnit_WATER_ML      = 7 ,
    /** 牛奶 fl.oz */
    AiFreshNutritionScaleWeightUnit_MILK_FLOZ     = 8 ,
    /** 水 fl.oz */
    AiFreshNutritionScaleWeightUnit_WATER_FLOZ    = 9 ,
    /** lb */
    AiFreshNutritionScaleWeightUnit_LB            = 10 ,
    
    /** Unsupported unit */
    AiFreshNutritionScaleWeightUnit_Fail          = 0xFF ,
};



#endif /* ELAiFreshNutritionScaleBleHeader_h */
