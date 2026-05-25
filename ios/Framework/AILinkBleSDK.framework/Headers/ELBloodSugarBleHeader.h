//
//  ELBloodSugarBleHeader.h
//  Elink
//
//  Created by iot_user on 2020/7/7.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#ifndef ELBloodSugarBleHeader_h
#define ELBloodSugarBleHeader_h
#import <AILinkBleSDK/ELSDKHeader.h>

//设备状态
typedef NS_ENUM(NSUInteger, BloodSugarDeviceStatus) {
    BloodSugarDeviceStatusNoStatus        = 0x00, //无状态
    BloodSugarDeviceStatusTestWaiting     = 0x01, //设备等待插入试纸
    BloodSugarDeviceStatusSamplingWaiting = 0x02, //设备已插入试纸，等待获取血样
    BloodSugarDeviceStatusAnalysising     = 0x03, //血样已获取，分析血样中...
    BloodSugarDeviceStatusTestComplete    = 0x04, //上发数据完成，测量完成
};

typedef NS_ENUM(NSUInteger, BloodSugarErrorCode) {
    BloodSugarErrorCodeLowBattery    = 0x01 ,//电池没电
    BloodSugarErrorCodeUsedTestPaper = 0x02 ,//已使用过的试纸
    BloodSugarErrorCodeTempHigh      = 0x03 ,//环境温度超出使用范围
    BloodSugarErrorCodeCancelTest    = 0x04 ,//试纸施加血样后测试未完成，被退出试纸
    BloodSugarErrorCodePassError     = 0x05 ,//机器自检未通过
    BloodSugarErrorCodeLow           = 0x06 ,//测量结果过低，超出测量范围
    BloodSugarErrorCodeHigh          = 0x07 ,//测量结果过高，超出测量范围,
};


#endif /* ELBloodSugarBleHeader_h */
