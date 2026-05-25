//
//  ELFasciaGunBleManager.h
//  AILinkBleSDK
//
//  Created by LarryZhang on 2022/1/15.
//  Copyright © 2022 IOT. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELFasciaGunBleDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FasciaGunBleDelegate;

@interface ELFasciaGunBleManager : ELBluetoothManager

@property (nonatomic, weak) id<FasciaGunBleDelegate> fasciaGunDelegate;

+ (instancetype)shareManager;

- (void)autoScan;
- (void)stopAutoScan;
- (void)checkStatus;

@end

@interface ELFasciaGunBleManager (sendCmd)

- (void)sendCmdToDeviceStart:(BOOL)started withGear:(UInt8)gear;

- (void)sendCmdToDeviceGear:(UInt8)gear;

- (void)sendCmdToDeviceCountdown:(UInt16)timeInterval enable:(BOOL)enabled;

@end


@protocol FasciaGunBleDelegate <NSObject>

@optional

/// 蓝牙连接状态
/// @param state 连接状态
- (void)fasciaGunBleReceiveState:(ELBluetoothState)state;

/// 附近的设备
/// @param devices 设备列表
- (void)fasciaGunBleReceiveDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;

//正在连接中倒计时
- (void)fasciaGunBleCountDown:(NSInteger)count;


- (void)fasciaGunBleReceiveStatusDataModel:(ELFasciaGunBleDataModel *_Nonnull)model;

- (void)fasciaGunBleReceiveStart:(BOOL)started withGear:(UInt8)gear;

- (void)fasciaGunBleReceiveGear:(UInt8)gear;

- (void)fasciaGunBleReceiveCountdown:(UInt16)timeInterval enabled:(BOOL)enabled;


@end
NS_ASSUME_NONNULL_END
