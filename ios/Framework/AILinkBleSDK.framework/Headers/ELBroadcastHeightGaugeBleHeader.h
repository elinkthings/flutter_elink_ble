//
//  ELBroadcastHeightGaugeBleHeader.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/3/19.
//  Copyright © 2021 IOT. All rights reserved.
//

#ifndef ELBroadcastHeightGaugeBleHeader_h
#define ELBroadcastHeightGaugeBleHeader_h

/** 广播身高仪 测量标识符枚举定义 */
typedef NS_ENUM(NSUInteger, BroadcastHeightGuage_TestState) {
    /** 正在测量 */
    BroadcastHeightGuage_TestState_Measuring          = 0x00 ,
    /** 稳定身高体重 */
    BroadcastHeightGuage_TestState_Stable             = 0x01 ,
    /** 测量失败 */
    BroadcastHeightGuage_TestState_Failed             = 0xFF ,
};


//身高数据标志 ELDeviceHeightUnit

//体重数据标志 ELDeviceWeightUnit

#endif /* ELBroadcastHeightGaugeBleHeader_h */
