//
//  ELBabyScaleBleHeader.h
//  Elink
//
//  Created by iot_user on 2019/9/16.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#ifndef ELBabyScaleBleHeader_h
#define ELBabyScaleBleHeader_h

//Baby scale transparent data type(婴儿秤透传数据类型)
typedef NS_ENUM(NSUInteger, BabyScaleBleDataType) {
    /**Weight stability data( 体重稳定数据) */
    BabyScaleBleDataType_WeightStableData           = 0x01 ,
    /** Weight real-time data(体重实时数据) */
    BabyScaleBleDataType_WeightRealtimeData         = 0x02 ,
    /** Length data(身长数据) */
    BabyScaleBleDataType_Height                     = 0x03 ,
    
    /** App delivery unit settings(app下发单位设置 )*/
    BabyScaleBleDataType_AppSendUnit                = 0x81 ,
    /** MCU reply setting result(MCU回复设置结果) */
    BabyScaleBleDataType_BackSendUnit               = 0x82 ,
    
    /** App sends control class instructions(app发送控制类指令 )*/
    BabyScaleBleDataType_AppSendCtrl                = 0x83 ,
    /** MCU reply control result(MCU回复控制结果) */
    BabyScaleBleDataType_BackSendCtrl               = 0x84 ,
    
    
    /** he device sends an error code.(设备上发错误码) */
    BabyScaleBleDataType_DeviceBackErrorCode        = 0xFF,
    
};


typedef NS_ENUM(NSInteger ,BabyScaleResultType) {
    /** Successful setup(设置成功) */
    BabyScaleResultType_Succeed                     = 0 ,
    /** Setup failed(设置失败) */
    BabyScaleResultType_Failure                         ,
    /** Does not support settings(不支持设置) */
    BabyScaleResultType_Unsupported                     ,
};

typedef NS_ENUM(NSInteger ,BabyScaleDeviceErrorCode) {
    /** overweight(超重) */
    BabyScaleDeviceErrorCode_Overweight             = 0 ,
    /** Unstable weight during weighing 0(称重为0 期间，重量不稳定） */
    BabyScaleDeviceErrorCode_Unstable                   ,
    /** Weighing to 0 failed（称重为 0 失败 ）*/
    BabyScaleDeviceErrorCode_Failure                    ,
};

typedef NS_ENUM(NSUInteger, HoldDataType) {
    HoldDataTypeKeep       = 0x00,
    HoldDataTypeCancel     = 0x01,
    HoldDataTypeUnkonwn
};

#endif /* ELBabyScaleBleHeader_h */
