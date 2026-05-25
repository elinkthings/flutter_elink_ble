//
//  ELCoffeeScaleBleHeader.h
//  Elink
//
//  Created by iot_user on 2020/9/30.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#ifndef ELCoffeeScaleBleHeader_h
#define ELCoffeeScaleBleHeader_h
#import "ELSDKHeader.h"


/** 咖啡秤电池充电状态枚举定义 */
typedef NS_ENUM(NSInteger, CoffeeChargingType) {
    /** 没有充电 */
    CoffeeChargingType_NoCharging               = 0 ,
    /** 充电中 */
    CoffeeChargingType_Charging                     ,
    /** 充满电 */
    CoffeeChargingType_FullyCharged                 ,
    /** 充电异常 */
    CoffeeChargingType_AbnormalCharging             ,
};

/** 咖啡秤设置结果枚举定义 */
typedef NS_ENUM(NSInteger, CoffeeSetResultType) {
    /** 成功 */
    CoffeeSetResultType_Success                 = 0    ,
    /** 失败 */
    CoffeeSetResultType_Failure                 = 1    ,
    /** 不支持 */
    CoffeeSetResultType_NotSupport              = 2    ,
};



typedef NS_ENUM(NSUInteger, ELCoffeeScaleTimerControl) {
    ELCoffeeScaleTimerControl_count         = 0x01,//计时
    ELCoffeeScaleTimerControl_pause        = 0x02,//暂停
    ELCoffeeScaleTimerControl_reset      = 0x03,//重置
};

#endif /* ELCoffeeScaleBleHeader_h */
