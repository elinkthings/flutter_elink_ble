//
//  ELAILinkBleManagerProtocol.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2023/3/31.
//

#import "ELAILinkBleManager.h"

@class ELAILinkPeripheral, ELBleWifiDetailModel, ELAILinkBleManager;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ELAILinkBleManagerDelegate

@protocol ELAILinkBleManagerDelegate <NSObject>

@optional
//扫描
- (void)managerDidUpdateState:(CBCentralManager *)central;

- (void)managerScanState:(BOOL)scanning;

- (void)managerDidDiscoverPeripheral:(ELAILinkPeripheral *)peripheral;

- (void)managerDidDiscoverMorePeripheral:(NSDictionary<NSUUID *, ELAILinkPeripheral *> *)peripherals;

//连接
- (void)managerDidConnectPeripheral:(CBPeripheral *)peripheral;

- (void)managerDidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

- (void)managerDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

- (void)managerDidUpdateConnect:(NELBleManagerConnectState)state;

- (void)managerDidDisconnectError:(NSError * __nullable)error;

//服务 & 特征
- (void)peripheralDidDiscoverServices:(NSArray<CBService *> *)services;

- (void)peripheralDidDiscoverCharacteristicsForService:(NSArray<CBCharacteristic *> *)characteristics;

- (void)peripheralDidUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic;

- (void)peripheralDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic;

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic;

- (void)peripheralDidReadRSSI:(nonnull NSNumber *)RSSI;


@optional

//A7数据 payload
- (void)aiLinkBleReceiveA7Data:(NSData *)payload;
- (void)aiLinkBleReceiveA7Data:(NSData *)payload withMac:(NSData *)mac DEPRECATED_MSG_ATTRIBUTE("use 'aiLinkBleReceiveA7Data:aILinkPeripheral' instead");
- (void)aiLinkBleReceiveA7Data:(NSData *)packet aILinkPeripheral:(ELAILinkPeripheral *)aILinkPeripheral;
- (void)aiLinkBleReceiveA7Data:(NSData *)rawData manager:(ELAILinkBleManager *)manager;

//A6数据 packet
- (void)aiLinkBleReceiveA6Data:(NSData *)packet;
- (void)aiLinkBleReceiveA6Data:(NSData *)packet withMac:(NSData *)mac DEPRECATED_MSG_ATTRIBUTE("use 'aiLinkBleReceiveA6Data:aILinkPeripheral' instead");
- (void)aiLinkBleReceiveA6Data:(NSData *)packet aILinkPeripheral:(ELAILinkPeripheral *)aILinkPeripheral;
- (void)aiLinkBleReceiveA6Data:(NSData *)rawData manager:(ELAILinkBleManager *)manager;

//原始数据
- (void)aiLinkBleReceiveRawData:(NSData *)rawData aILinkPeripheral:(ELAILinkPeripheral *)aILinkPeripheral;
- (void)aiLinkBleReceiveRawData:(NSData *)rawData manager:(ELAILinkBleManager *)manager;

@end

#pragma mark - Bluetooth Wifi protocol(蓝牙Wifi协议)

@protocol ELAILinkBleWifiDelegate <NSObject>

@optional

/**
 Callback Wifi details(回调Wifi详情)
 @param model 模型
 */
- (void)bleWifiReceiveWifiDetailModel:(ELBleWifiDetailModel *)model;

/**
Scan nearby wifi results(扫描附近wifi结果)
 @param count Number of nearby wifi(附近wifi数量)
 */
- (void)bleWifiReceiveScanedWifiCount:(int)count;

/**
 Callback Wifi MAC address(回调Wifi MAC地址)
 @param macData mac
 */
- (void)bleWifiReceiveWifiMacData:(NSData *_Nullable)macData;

/**
Callback WIFI password(回调WIFI密码)
 @param pwd password(密码)
 */
- (void)bleWifiReceiveWifiPwd:(NSString *)pwd;

/**
 Get DTIM interval (unit: ms)(获取DTIM间隔(单位:ms))
 @param interval Interval (unit: ms)(间隔(单位:ms))
 */
- (void)bleWifiReceiveWifiDTIMInterval:(NSInteger)interval;

/**
 Returns the visited URL(返回访问的url)
 @param url url
 */
- (void)bleWifiReceiveURL:(NSString *)url;

/**
  Call back wifi port number(回调wifi的端口号)
 @param port 端口号
 */
- (void)bleWifiReceivePort:(UInt16)port;

//Returns the visited path(返回访问的path)
- (void)bleWifiReceivePath:(NSString *)path;

/**
 Set or query the callback of the instruction execution result（设置指令蓝牙WIFI响应回调方法）
 只支持蓝牙Wifi部分枚举
 @param type Type of setting （设置的类型）
 @param result Set result（设置的结果）
 */
- (void)bleWifiReceiceResponseType:(ELInetSetCmdType)type result:(ELSetBluetoothResponseType)result;

/**
 获取会话码(deviceId)
 @param code (deviceId) deviceId(0 means no:为0时表示不存在)
 */
- (void)bleWifiReceiveWifiSNCode:(int)code;

/** 返回wifi名称 */
- (void)bleWifiName:(NSString *)wifiName;

@end

NS_ASSUME_NONNULL_END
