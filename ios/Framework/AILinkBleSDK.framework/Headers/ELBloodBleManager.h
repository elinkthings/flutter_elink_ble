//
//  ELBloodBleManager.h
//  Elink
//
//  Created by iot_user on 2019/5/11.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELBloodBleSDKHeader.h"
#import "ELBloodBleDataModel.h"



typedef NS_ENUM(NSUInteger, ELBloodBleDataType) {
    ELBloodBleDataTypeStableData        = 0x01, //Stable data(稳定数据)
    ELBloodBleDataTypeRealTimeData      = 0x02, //Real-time data(实时数据)
    ELBloodBleDataTypeSetUnit           = 0x81, //App release unit settings(app 下发单位设置)
    ELBloodBleDataTypeSetUnitResult     = 0x82, //Unit setting result(单位设置结果)
    ELBloodBleDataTypeInteraction       = 0x83, //Interactive command(交互指令)
    ELBloodBleDataTypeSetSwitchVoice    = 0x85, //Send voice alarm settings(下发语音报警设置)
    ELBloodBleDataTypeSwitchVoiceResult = 0x86, //Send voice alarm setting result(下发语音报警设置结果)
    ELBloodBleDataTypeFailCode          = 0xFF, //Report error code(上报错误码)
};



@protocol ELBloodBleManagerDelegate <NSObject>

@optional
/**
 Callback Bluetooth status(回调蓝牙状态)
 
 @param state Bluetooth status(蓝牙状态)
 */
-(void)bloodBleManagerUpdateBleState:(ELBluetoothState)state;

/**
 Callback scanned device(回调扫描到的设备)
 
 @param devices 设备
 */
-(void)bloodBleManagerScanDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;

/**
 Call back real-time, stable data(回调实时、稳定数据)

 @param model 数据
 @param type 类型
 */
-(void)bloodBleManagerReceiceTestData:(ELBloodBleDataModel *_Nonnull)model type:(ELBloodBleDataModelType)type;

/**
 Set unit callback(设置单位回调)
 
 @param type 结果
 */
-(void)bloodBleManagerReceiveSetUnitResult:(ELSetBluetoothResponseType)type;

/**
 Set the interaction type(设置交互类型)
 
 @param type 结果
 */
-(void)bloodBleManagerReceiveInteractionType:(ELBloodInteractionType)type;


/**
 Error code sent on the device(设备上发错误码)
 
 @param code error code(错误码)
 */
-(void)bloodBleManagerReceiveFailCode:(ELBloodFailCode)code;

/**
 Send voice alarm setting result(下发语音报警设置结果)

 @param type 操作类型
 @param result 结果
 */
-(void)bloodBleManagerReceiveSetSwitchVoiceOperationType:(ELBloodBleSwitchVoiceType)type result:(ELSetBluetoothResponseType)result;
@end


NS_ASSUME_NONNULL_BEGIN

@interface ELBloodBleManager : ELBluetoothManager

@property (nonatomic, weak) id<ELBloodBleManagerDelegate> bloodDelegate;


+(instancetype)shareManager;


//Set unit(设置单位)
-(void)changeUnit:(ELDeviceBloodPressureUnit)unit;

/**
 Interact with Bluetooth(与蓝牙交互)

 @param type 类型
 ELBloodInteractionTypeStartTest   = 0, //Start measurement(开始测量)
 ELBloodInteractionTypeStopTest    = 1, //Stop testing(停止测试)
 ELBloodInteractionTypeBoot        = 2, //Boot(开机)
 ELBloodInteractionTypeShutdown    = 3, //Shut down(关机)
 */
-(void)sendInteractiveInstructions:(ELBloodInteractionType)type;

/**
 Send voice alarm settings(下发语音报警设置)

 @param type operation type
 */
-(void)sendSwitchVoice:(ELBloodBleSwitchVoiceType)type;
@end

NS_ASSUME_NONNULL_END
