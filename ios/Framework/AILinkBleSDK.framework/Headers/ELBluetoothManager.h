//
//  ELBluetoothManager.h
//  Elink
//
//  Created by iot_user on 2019/4/22.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELPeripheralModel.h"
#import "ELSDKHeader.h"
#import "ELBlePublicTool.h"
#import "ELBluetoothManager+Settings_Callback.h"
#import "ELBluetoothManager+BleWifi_Callback.h"
#import "AILinkBleSDK_Version.h"


NS_ASSUME_NONNULL_BEGIN

/// 有些设备需要页面获取到发送的数据内容，给服务器，监听该通知获得发送数据，保险起见需要判断一个header.内容是data
/// 发送A7不加密数据
static NSString *SEND_A7_BLE_DATA_CONTENT = @"SEND_A7_BLE_DATA_CONTENT";
/// 发送A7加密数据
static NSString *SEND_A7_ENCRYPTED_BLE_DATA_CONTENT = @"SEND_A7_ENCRYPTED_BLE_DATA_CONTENT";
/// 设备返回A7解密的payload数据
static NSString *GET_A7_DECRYPT_BLE_PAYLOAD_DATA_CONTENT = @"GET_A7_DECRYPT_BLE_PAYLOAD_DATA_CONTENT";

@interface ELBluetoothManager : NSObject

@property (nonatomic, assign, readonly) BOOL isOn;
//Bluetooth status（蓝牙状态）
@property (nonatomic, assign, readonly) ELBluetoothState state;
//version number（版本号）
@property (nonatomic, copy, readonly) NSString *bmVersion;

// 好身材秤 连接秤特有区分ac02和ac03
@property (nonatomic,assign) Byte acByte;

/**
 Save the model corresponding to the currently connected device
 保存当前连接的设备对应的模型
 */
@property (nonatomic, strong, readonly) ELPeripheralModel *peripheralModel;
//Bluetooth proxy(蓝牙代理)
@property (nonatomic, weak) id<ELBluetoothManagerDelegate> delegate;
//Bluetooth wifi proxy(蓝牙wifi代理)
@property (nonatomic, weak) id<ElBleWifiDelegate> bleWifiDelegate;
//Bluetooth Broadcast Device Protocol(蓝牙广播设备协议)
@property (nonatomic, weak) id<ELBleBroadcastDelegate> broadDelegate;


/** 需要搜索与系统绑定的蓝牙设备 */
@property (nonatomic, assign) BOOL needScanBindSysDevice;


//SDK 自动重连超时 0~5秒，仅指定设备可使用此功能，其他设备可能会引起逻辑问题
@property (nonatomic, assign) NSInteger reconnectionTimeout;


//设置支持设备列表 - 扫描过滤
- (void)setSupportDeviceCids:(NSArray<NSNumber *> *)cids;

//
+(__kindof ELBluetoothManager * _Nonnull)shareManager;

/**
 Get the SDK version number
 获取SDK版本号
 */
-(NSString *)sdkVersion;

//Start scanning（开始扫描）
-(void)startScan;

//Start scanning（开始扫描）- 过滤 cid 列表
-(void)startScanFilterCids:(NSArray<NSNumber *> *)cids;
-(void)startScanAllFilterCids:(NSArray<NSNumber *> *)cids;

//Start scanning all (开始扫描附近所有设备)
- (void)startScanAll;
//Stop scanning（停止扫描）
-(void)stopScan;
//Connecting device（连接设备）
-(void)connectPeripheral:(ELPeripheralModel *)peripheralModel;
//Disconnect device（断开设备）
-(void)disconnectPeripheral;

- (void)readRSSI;

/**
 Get Bluetooth information(获取蓝牙信息)

 @param type ELInetGetCmdType （ELInetGetCmdTypeGetHandshake除外）
 */
-(void)getBluetoothInfoWithELInetGetCmdType:(ELInetGetCmdType)type;
/**
 Sync the current time of phone to BLE(设置手机本地时间给蓝牙模块，只在蓝牙体脂秤等需要蓝牙模块保存历史记录时才调用)
 @param enable
 NO: In addition to the ability to turn off the time function, you can save part of the current (default)(除能，关闭时间功能，可省部分电流（默认）)
 YES:Enable, turn on the timer function timer(使能，开启计时功能定时器)
 */
-(void)syncBleNowDate:(BOOL)enable;

///仅WIFI秤调用，同步世界时间(0时区)到wifi-ble模块
-(void)syncBleGMTNowDate:(BOOL)enable;

///同步手机本地时间给mcu，每次连接成功后会自动调用
-(void)syncMCUNowDate;


#pragma mark  ============ 发送指令的3种方法 ==============
/**
 Shortcut method to send A6 data to BLE(发送A6数据给BLE的快捷方法)
 @param data The stitched payload part(拼接好的payload部分)
 */
-(void)sendCmdToMCUWithA6PayloadData:(NSData *)data;
/**
 Shortcut method of sending A7 data to MCU(发送A7数据给MCU的快捷方法)
 @param data The stitched payload part(拼接好的payload部分)
 @param type Equipment type(设备类型)
 */
-(void)sendCmdToMCUWithA7PayloadData:(NSData *)data deviceType:(ELSupportDeviceType)type;
- (void)sendCmdToMCUWithA7PayloadDataNew:(NSData *)data deviceType:(ELSupportDeviceType)type;

/// 直接发送A7命令，不加载在队列中
-(void)immediatelySendCmdToMCUWithA7PayloadData:(NSData *)data deviceType:(ELSupportDeviceType)type;

/**
 General method of sending data (support data transparent transmission)(发送数据通用方法（支持数据透传）)
 
 @param data 数据
 */
-(void)sendData:(NSData *)data;

//恢复出厂设置
- (void)setFactoryDataReset;


#pragma mark  ============ Please rewrite the following methods in the subclass(请在子类重写以下方法) BEGIN==============

-(void)bluetoothUpdateState:(ELBluetoothState)state;

-(void)bluetoothScanPeripherals:(NSArray *)peripherals;


/**
Callback decrypted A7 transparent data (payload part), type device type( 回调解密后的A7透传数据(payload部分),type设备类型)
 */
-(void)bluetoothReceiveData:(NSData *)playload deviceType:(ELSupportDeviceType)type;

/**
 The special A6 data will only be received by the supported devices, and the complete A6 data (A6 is not encrypted) is passed to the subclass resolution.
 特殊的A6数据，只有支持的设备才会收到，将完整A6数据(A6不加密)传给子类解析
 ELSupportDeviceType support：
 ELSupportDeviceTypeBodyFatScale
 ELSupportDeviceTypeSmartLock
 */
-(void)bluetoothBackA6Data:(NSData *)data withClassId:(ELSupportDeviceType)type;

/**
 Callback to scan special devices that can be bound, such as door locks（回调扫描到的可以绑定的特殊设备，如门锁）
 */
-(void)bluetoothScanCanBindSpecialPeripherals:(NSArray *)peripherals;
//Call back the scanned broadcast device(回调扫描到的广播设备)
-(void)bluetoothScanBroadcastPeripherals:(NSArray *)peripherals;

/**
 Callback device basic information（回调设备基本信息）

 @param data Device basic information payload data (length is 16 bytes)（设备基本信息payload数据（长度为16个byte））
 */
-(void)bluetoothReceiveBasicInfoPayloadData:(NSData *)data;

///Callback transparent transmission data(回调透传数据)
/// @param data Transparent data(透传数据)
-(void)bluetoothReceivePassData:(NSData *)data;

/** 滑板车专用,返回设备消息推送内容 */
- (void)bluetoothManagerScooterMessageWithUUID:(NSString *)uuid data:(NSData *)data;
/** 返回滑板车软件版本号 */
- (void)bluetoothManagerScooterSoftwareRevision:(NSString *)version;

//Broadcast equipment dedicated（广播设备专用）
/// Broadcast device data
/// @param cid cid
/// @param vid vid
/// @param pid pid
/// @param mac mac
/// @param data custom data(自定义数据)
-(void)bluetoothReceiveBroadcastDataWithCid:(int)cid vid:(int)vid pid:(int)pid mac:(NSString *_Nonnull)mac data:(NSData *_Nonnull)data;

#pragma mark  ============ Please rewrite the following methods in the subclass(子类重写方法) END==============





@end
NS_ASSUME_NONNULL_END

