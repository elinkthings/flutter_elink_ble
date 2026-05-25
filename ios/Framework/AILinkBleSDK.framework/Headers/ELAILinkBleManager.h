//
//  ELAILinkBleManager.h
//
//  Created by LarryZhang on 2022/8/13.
//  Copyright © 2022 iot_iMac. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "NELBleManagerHeader.h"
#import "ELSDKHeader.h"
#import "AILinkBleSDK_Version.h"

#import "ELAILinkBleManagerProtocol.h"
#import "ELAILinkPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

@class ELAILinkPeripheral;
@class ELBleWifiDetailModel;

@protocol ELAILinkBleWifiDelegate;
@protocol ELAILinkBleManagerDelegate;

@interface ELAILinkBleManager : NSObject

//不是必须使用单例
+ (instancetype)sharedManager;
- (NSString *)sdkVersion;
+ (NSString *)sdkVersion;

//扫描状态
@property(nonatomic, assign, readonly, getter=isScanning) BOOL scanning;

//BLE设备连接状态
@property(nonatomic, assign, readonly) NELBleManagerConnectState connectState;

@property(nonatomic, strong, readonly) CBCentralManager *central;

@property (nonatomic, weak) id<ELAILinkBleManagerDelegate> delegate DEPRECATED_MSG_ATTRIBUTE("use 'ailinkDelegate' only");

@property (nonatomic, weak) id<ELAILinkBleManagerDelegate> ailinkDelegate;

//Bluetooth wifi proxy(蓝牙wifi代理)
@property (nonatomic, weak) id<ELAILinkBleWifiDelegate> bleWifiDelegate;

//模块版本号
@property (nonatomic, copy) NSString *bmVersion;
@property (nonatomic, copy) NSString *bmVersionPro;
//电池状态
@property (nonatomic, assign) struct ELBatteryStruct battery;
//单位列表
@property (nonatomic, strong) NSArray<NSNumber *> *weightArray;
@property (nonatomic, strong) NSArray<NSNumber *> *heightArray;
@property (nonatomic, strong) NSArray<NSNumber *> *temperatureArray;
@property (nonatomic, strong) NSArray<NSNumber *> *bloodPressureArray;
@property (nonatomic, strong) NSArray<NSNumber *> *pressureArray;
@property (nonatomic, strong) NSArray<NSNumber *> *bloodSugarUnitArray;
@property (nonatomic, strong) NSArray<NSNumber *> *volumeUnitArray;

//SDK 自动重连超时 0~5秒，仅指定设备可使用此功能，其他设备可能会引起逻辑问题
@property (nonatomic, assign) NSInteger reconnectionTimeout;

@end

#pragma mark - scan
@interface ELAILinkBleManager (scan)

- (void)scanAll;
- (void)scanFilterWithCidArray:(NSArray<NSNumber *> *)cidArray;
- (void)scanFilterWithMacArray:(NSArray<NSString *> *)macArray;
- (void)scanFilterWithCidArray:(NSArray<NSNumber *> *)cidArray macArray:(NSArray<NSString *> *)macArray;
- (void)scanAllowDuplicatesFilterWithCidArray:(NSArray<NSNumber *> *)cidArray macArray:(NSArray<NSString *> *)macArray;

// 新扫描方法
- (void)scanWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *, id> * _Nullable)options;
- (void)setFilterCids:(NSArray<NSNumber *> *)cids;
- (void)setFilterMacs:(NSArray<NSString *> *)macs;

// 获取当前连接到系统的 peripheral 设备的列表(如被其它程序连接着)
- (NSArray<CBPeripheral *> *)retrieveConnectedPeripherals;

//NELBleManager
- (void)stopScan;

@end

#pragma mark - connect
@interface ELAILinkBleManager (connect)

- (void)disconnectPeripheral;

- (void)connectAILinkPeripheral:(ELAILinkPeripheral * _Nonnull)ailinkPeripheral;

- (ELAILinkPeripheral * _Nullable)currentAILinkPeripheral;

- (void)readRSSI;

@end

#pragma mark - send
@interface ELAILinkBleManager (send)

- (void)sendA7Payload:(NSData *)payload;
- (void)sendA7PayloadNoEncryption:(NSData *)payload;
- (void)sendA6Payload:(NSData *)payload;

/// base method of 'sendA7Payload' & 'sendA6Payload'
- (void)sendCmd:(NSData *)cmdData;
//直接发送
- (void)sendDirectCmd:(NSData *)cmdData;

//最大发送数据长度
- (NSUInteger)maximumWriteValueLength DEPRECATED_MSG_ATTRIBUTE("use 'maximumWriteValueLengthForWriteWithResponse' or 'maximumWriteValueLengthForWriteWithoutResponse' instead");
//最大发送A7 payload长度
- (NSUInteger)maximumWriteA7PayloadLength DEPRECATED_MSG_ATTRIBUTE("use 'maximumWriteValueLengthForWriteWithResponse' or 'maximumWriteValueLengthForWriteWithoutResponse' instead");
//最大发送A6 payload长度
- (NSUInteger)maximumWriteA6PayloadLength DEPRECATED_MSG_ATTRIBUTE("use 'maximumWriteValueLengthForWriteWithResponse' or 'maximumWriteValueLengthForWriteWithoutResponse' instead");

//可发送的最大字节数
@property(nonatomic, assign, readonly) NSUInteger maximumWriteValueLengthForWriteWithResponse;
//可发送的最大字节数
@property(nonatomic, assign, readonly) NSUInteger maximumWriteValueLengthForWriteWithoutResponse;

//发送队列发送周期
- (void)configWriteDataQueueInterval:(CGFloat)interval;

- (void)configWriteCharacteristicWriteType:(CBCharacteristicWriteType)type;

@end

#pragma mark - Open
@interface ELAILinkBleManager (Open)

//解析指令 外部开放 Method
- (void)processA7Data:(NSMutableData *)rawData withMac:(NSData *)mac withCid:(UInt16)cid;
- (void)processA6Data:(NSMutableData *)rawData;

//生成数据包 外部开放 Method
- (NSData * _Nullable)makePacketA7Payload:(NSData *)payload withMac:(NSData *)mac withCid:(UInt16)cid;
- (NSData * _Nullable)makePacketA6Payload:(NSData *)payload;

@end

#pragma mark - A6Method
@interface ELAILinkBleManager (A6Method)

/**
 Get Bluetooth information(获取蓝牙信息)
 @param type ELInetGetCmdType （ELInetGetCmdTypeGetHandshake除外）
 */
- (void)getBluetoothInfoWithELInetGetCmdType:(ELInetGetCmdType)type;

/**
 Sync the current time of phone to BLE(设置手机本地时间给蓝牙模块，只在蓝牙体脂秤等需要蓝牙模块保存历史记录时才调用)
 @param enable
 NO: In addition to the ability to turn off the time function, you can save part of the current (default)(除能，关闭时间功能，可省部分电流（默认）)
 YES:Enable, turn on the timer function timer(使能，开启计时功能定时器)
 */
- (void)syncBleNowDate:(BOOL)enable;

///仅WIFI秤调用，同步世界时间(0时区)到wifi-ble模块
- (void)syncBleGMTNowDate:(BOOL)enable;

///同步手机本地时间给mcu，每次连接成功后会自动调用
- (void)syncMCUNowDate;

///同步手机时间戳给设备 //0x45
- (void)syncUnixTimestamp;

///查询mqtt链接状态 CMD=0xC5
- (void)checkMqttState;

#pragma mark - 发现服务
- (void)discoverServiceWithUUIDString:(NSString *)UUIDString;

#pragma mark - 设置已发现特征notifyValue
- (void)setCharacteristicsNotifyValue:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
