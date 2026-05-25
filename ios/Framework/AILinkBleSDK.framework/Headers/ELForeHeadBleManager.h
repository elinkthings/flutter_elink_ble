//
//  ELForeHeadBleManager.h
//  Elink
//
//  Created by iot_user on 2019/4/18.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELForeheadBleDataModel.h"
#import "ELForeheadHeader.h"

typedef NS_ENUM(NSUInteger, ForeheadBleDataType) {
    ForeheadBleDataType_ForeheadStabilityData    = 0x01,  //Forehead temperature stability data sign(额头温度稳定数据标志)
    ForeheadBleDataType_ForeheadDynamicData      = 0x02,  //Forehead temperature real-time data sign(额头温度实时数据标志)
    ForeheadBleDataType_EarStabilityData         = 0x03,  //Ear temperature stability data sign(耳朵温度稳定数据标志)
    ForeheadBleDataType_EarDynamicData           = 0x04,  //Ear temperature real-time data sign(耳朵温度实时数据标志)
    ForeheadBleDataType_EnvironmentStabilityData = 0x05,  //Ambient temperature stable data sign(环境温度稳定数据标志)
    ForeheadBleDataType_EnvironmentDynamicData   = 0x06,  //Ambient temperature real-time data sign(环境温度实时数据标志)
    ForeheadBleDataType_SubstatanceStabilityData = 0x07,  //Object temperature stable data sign(物体温度稳定数据标志)
    ForeheadBleDataType_SubstatanceDynamicData   = 0x08,  //Object temperature real-time data sign(物体温度实时数据标志)
    ForeheadBleDataTypeAppSendUnit    = 0x81,  //App release unit settings(app下发单位设置)
    ForeheadBleDataTypeSetUnitResult  = 0x82,  //Unit setting result(单位设置结果)
    ForeheadBleDataTypeFailCode       = 0xFF,  //Report an error message(上报错误信息)
};


@protocol ELForeheadBleManagerDelegate <NSObject>
@optional

/**
 Callback Bluetooth status(回调蓝牙状态)

 @param state 蓝牙状态
 */
-(void)foreheadBleManagerUpdateBleState:(ELBluetoothState)state;

/**
 Callback scanned device(回调扫描到的设备)

 @param devices 额温枪设备
 */
-(void)foreheadBleManagerScanDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;

/**
 Callback temperature(回调温度)

 @param model ELForeheadBleDataModel
 */
-(void)foreheadBleManagerReceiveTemperature:(ELForeheadBleDataModel *_Nonnull)model dataType:(ForeheadBleDataType)dataType;

/**
Set unit callback( 设置单位回调)

 @param type 结果
 */
-(void)foreheadBleManagerReceiveSetUnitResult:(ELSetBluetoothResponseType)type;

/**
 Error code sent on the device(设备上发错误码)

 @param code 错误码
 */
-(void)foreheadBleManagerReceiveFailCode:(ForeheadFailCode)code;
@end


NS_ASSUME_NONNULL_BEGIN

@interface ELForeHeadBleManager : ELBluetoothManager

@property (nonatomic, weak) id<ELForeheadBleManagerDelegate> foreheadDelegate;


+(instancetype)shareManager;


/**
 Edit unit(修改单位)

 @param unit 单位
 */
-(void)changeUnit:(ELDeviceTemperatureUnit)unit;

@end

NS_ASSUME_NONNULL_END
