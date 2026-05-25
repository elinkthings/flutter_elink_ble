//
//  ELBroadcastScaleBleHeader.h
//  Elink
//
//  Created by iot_user on 2020/8/21.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#ifndef ELBroadcastScaleBleHeader_h
#define ELBroadcastScaleBleHeader_h

#import "ELSDKHeader.h"


typedef NS_ENUM(NSUInteger, BroadcastScaleTestStatus) {
    //Weighing(正在测量体重)
    BroadcastScaleTestStatusWeightTesting = 0,
    //Impedance is being measured (the impedance value is 0 at this time)(正在测量阻抗(此时阻抗数值为 0))
    BroadcastScaleTestStatusADCTesting,
    //Impedance measurement succeeded(阻抗测量成功)
    BroadcastScaleTestStatusADCTestSuccess,
    //Impedance measurement failed (the impedance value is 0xFFFF at this time)(阻抗测量失败(此时阻抗数值为 0xFFFF))
    BroadcastScaleTestStatusADCTestFailed,
    //Weight mode (skip impedance measurement, the impedance value is 0, and the APP will not prompt impedance failure)( 体重模式（跳过阻抗测量,此时阻抗数值为 0, APP不会提示阻抗失败的提示）)
    BroadcastScaleTestStatusWeightMode,
    //End of test(测试结束)
    BroadcastScaleTestStatusTestEnd       = 0xFF,
};

typedef NS_ENUM(NSUInteger, BroadcastScaleWeightType) {
    //Real-time weight(实时重量)
    BroadcastScaleWeightTypeRealTime = 0,
    //Stable weight(稳定重量)
    BroadcastScaleWeightTypeStable,
    
};



#endif /* ELBroadcastScaleBleHeader_h */
