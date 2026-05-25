//
//  ELBluetoothManagerProtocol.h
//  AILinkBleSDK
//
//  Created by steven wu on 2021/8/6.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#pragma mark  Broadcast Equipment Protocol(广播设备协议)

@protocol ELBleBroadcastDelegate <NSObject>

@optional

/// Callback broadcast device data(回调广播设备数据)
/// @param cid cid
/// @param vid vid
/// @param pid pid
/// @param mac mac地址
/// @param data Custom data(自定义数据)
-(void)bleBroadcastWithCid:(int)cid vid:(int)vid pid:(int)pid mac:(NSString *_Nonnull)mac data:(NSData *_Nonnull)data;


@end




#pragma mark 蓝牙通用协议
@protocol ELBluetoothManagerDelegate <NSObject>
@optional

//Callback Bluetooth status（回调蓝牙状态）
-(void)bluetoothManagerUpdateBleState:(ELBluetoothState)state;
//Callback to scanned device（回调扫描到的设备）
-(void)bluetoothManagerScanedPeripherals:(NSArray<ELPeripheralModel *> *_Nonnull)peripherals;
//Special devices that can be bound in the callback, such as door locks（回调中扫描到的可以绑定的特殊设备，如门锁）
-(void)bluetoothManagerScanedCanBindSpecialPeripherals:(NSArray<ELPeripheralModel *> *_Nonnull)peripherals;
//Call back the scanned broadcast device(回调扫描到的广播设备)
-(void)bluetoothManagerScanedBroadcastPeripherals:(NSArray<ELPeripheralModel *> *_Nonnull)peripherals;

//Callback decrypted transparent data (A7 decrypted payload data)（回调解密后的数据(A7解密后payload数据)）
-(void)bluetoothManagerReceiveData:(NSData *_Nonnull)data deviceType:(ELSupportDeviceType)type;

- (void)peripheralDidReadRSSI:(nonnull NSNumber *)RSSI;

/**
 Callback transparent transmission data(回调透传数据)

 @param data Transparent data transmission (this data cannot start with A6 or A7)(透传数据(此数据不能以A6或A7开头))
 */
-(void)bluetoothManagerReceivePassData:(NSData *_Nullable)data;

/** 回调已经连接到系统的设备 */
//- (void)bluetoothManagerLinkedSysPeripheral:(NSArray *_Nonnull)peripherals;

#pragma mark  ============ A6 Set or query the callback of the instruction execution result（设置或查询指令执行结果的回调） ==============
/**
 Set or query the callback of the instruction execution result（设置指令蓝牙响应回调方法(握手指令除外)）

 @param type Type of setting （设置的类型）
 @param result Set result（设置的结果）
 */
-(void)bluetoothManagerReceiceResponseType:(ELInetSetCmdType)type result:(ELSetBluetoothResponseType)result;

/**
 Query module status callback（查询模块状态的回调）

 @param stateStrct 结构体
 */
-(void)bluetoothManagerReceiveMCUConnectedState:(struct ELMCUStateStruct)stateStrct;
//重构
-(void)bluetoothManagerReceiveWMState:(ELWMStateStruct)stateStrct;
-(void)bluetoothManagerReceiveWMStateFailCode:(WMWorkStateFailCode)failCode;

/**
 Query the callback of the communication mode（查询通信模式的回调）

 @param type communication mode（通信模式）
 */
-(void)bluetoothManagerReceiveCommunicationMode:(ELCommunicationModeType)type;

/**
 Query the callback of automatic sleep time（查询自动睡眠时间的回调）

 @param sleetStrct Automatic sleep time(自动睡眠时间)
 */
-(void)bluetoothManagerReceiveAutoSleepTime:(struct ELAutoSleepTimeStruct)sleetStrct;

/**
 Query master-slave mode callback（查询主从模式回调）

 @param mode 模式
 0:Slave mode（从机模式）
 1:Host mode（主机模式）
 */
-(void)bluetoothManagerReceiveMCUMode:(int)mode;

/**
 Query the callback of UUID information（查询UUID信息的回调）

 @param uuid ELUUIDStruct
 */
-(void)bluetoothManagerReceiveUUID:(struct ELUUIDStruct)uuid;

/**
 Query the callback of the MAC address size endian（查询MAC地址大小端序的回调）

 @param type 类型
 0:Little endian（小端序）
 1:Big endian （大端序）
 */
-(void)bluetoothManagerReceiveMacAddressType:(int)type;

/**
 Query the callback of the Bluetooth serial port baud rate（查询蓝牙串口波特率的回调）

 @param rate Serial port baud rate（串口波特率）
 0:9600
 1:19200
 2:38400
 3:57600
 4:115200
 5:921600
 */
-(void)bluetoothManagerReceiveSerialPostBaudRate:(int)rate;

/**
 Query the callback of Bluetooth transmit power（查询蓝牙发射功率的回调）

 @param dbm Transmit power（发射功率）
 */
-(void)bluetoothManagerReceiveTransmittingPower:(int)dbm;

/**
 Query the callback of the Bluetooth connection interval（查询蓝牙连接间隔的回调）

 @param intervalStrct connection interval
 */
-(void)bluetoothManagerReceiveConnectInterval:(struct ELConnectIntervalStruct)intervalStrct;

/**
 Query the callback of the Bluetooth name（查询蓝牙名称的回调）

 @param name Bluetooth name（蓝牙名称）
 */
-(void)bluetoothManagerReceiceName:(NSString *_Nullable)name;

/**
 Query the callback of the Bluetooth broadcast interval（查询蓝牙广播间隔的回调）

 @param interval broadcast interval（广播间隔）
 */
-(void)bluetoothManagerReceiveBroadcastInterval:(int)interval;

/**
 Query the callback of the Bluetooth MAC address（查询蓝牙MAC地址的回调）

 @param macAddress MAC
 */
-(void)bluetoothManagerReceiveMACAddress:(NSString *_Nonnull)macAddress;

/**
 Query the callback of the software and hardware version number of the BM module（查询BM模块软硬件版本号的回调）

 @param bmVersion BM module software and hardware version number（BM模块软硬件版本号）
 */
-(void)bluetoothManagerReceiveBMVersion:(NSString *_Nonnull)bmVersion;

/**
 Query the callback of the MCU software and hardware version number（查询MCU软硬件版本号的回调）
 
 @param mcuVersion Callback of MCU software and hardware version number（MCU软硬件版本号的回调）
 */
-(void)bluetoothManagerReceiveMCUVersion:(NSString *_Nonnull)mcuVersion;

/**
 Query the callback of Bluetooth time（查询蓝牙时间的回调）

 @param date yyyy-MM-dd HH:mm:ss
 @param effective Time is invalid（时间有无效）
 0：effective（系统时间无效）
 1：invalid（系统时间有效）
 */
-(void)bluetoothManagerReceiveBluetoothDate:(NSString * _Nonnull)date effective:(BOOL)effective;

/**
 Query CID, VID, PID callback（查询CID,VID,PID的回调）

 @param did CID,VID,PID
 */
-(void)bluetoothManagerReceiveDID:(struct ELDIDStruct)did;

/**
 Query the callback of the battery status（查询电池状态的回调）

 @param battery Structure of battery charge status and charge percentage（电池充电状态和电量百分比的结构体）
 */
-(void)bluetoothManagerReceiveBattery:(struct ELBatteryStruct)battery;

/**
 * Query the callback of the device support unit（查询设备支持单位的回调）
 
 */
- (void)bluetoothManagerBackDeviceSupportUnitWithWeight:(NSArray<NSNumber *> *_Nullable)weightArray
                                                 Height:(NSArray<NSNumber *> *_Nullable)heightArray
                                            Temperature:(NSArray<NSNumber *> *_Nullable)temperatureArray
                                          BloodPressure:(NSArray<NSNumber *> *_Nullable)bloodPressureArray
                                               Pressure:(NSArray<NSNumber *> *_Nullable)pressureArray;

- (void)bluetoothManagerBackDeviceSupportUnitWithWeight:(NSArray<NSNumber *> *_Nullable)weightArray
                                                 Height:(NSArray<NSNumber *> *_Nullable)heightArray
                                            Temperature:(NSArray<NSNumber *> *_Nullable)temperatureArray
                                          BloodPressure:(NSArray<NSNumber *> *_Nullable)bloodPressureArray
                                               Pressure:(NSArray<NSNumber *> *_Nullable)pressureArray
                                                 Volume:(NSArray<NSNumber *> *_Nullable)volumeArray;

/// Blood glucose units supported by callback supported devices(回调支持的设备支持的血糖单位)
/// @param bloodSugarUnitArray Blood glucose unit array(血糖单位数组)
-(void)bluetoothManagerReceiveSupportBloodSugarUnitArray:(NSArray<NSNumber *>* _Nullable)bloodSugarUnitArray;


/**
 Set the result of the decoding key（设置解码密钥的结果）

 @param result 结果
 */
-(void)bluetoothManagerReceiveSetKeyResult:(BOOL)result;

/// Device authorization result(设备授权结果)
/// @param result 结果
-(void)bluetoothManagerReceiveDeviceAuthorizeResult:(ELBluetoothDeviceAuthorizeResult)result;


@end




NS_ASSUME_NONNULL_END
