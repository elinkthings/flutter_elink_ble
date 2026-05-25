//
//  ELRemoteControlBleManager.h
//  Elink
//
//  Created by cliCk on 2019/7/2.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELRemoteControlBleHeader.h"
#import "ELBluetoothManager.h"
#import "ELRemoteControlDeviceModel.h"


NS_ASSUME_NONNULL_BEGIN

@protocol ELRemoteControlBleDelegate <NSObject>

@optional
/** 回调蓝牙状态 */
- (void)remoteControlManagerUpdateState:(ELBluetoothState )state;

/** 回调所有遥控器设备 */
- (void)remoteControlManagerScanDevices:(NSArray<ELRemoteControlDeviceModel *> *)deviceList;

@end


@interface ELRemoteControlBleManager : ELBluetoothManager

@property (nonatomic,weak) id <ELRemoteControlBleDelegate> remoteControlDelegate;

+ (ELRemoteControlBleManager *)shareManager;

/** APP下发控制命令 */
- (void)sendRemoreControlData:(RemoteControlType )type;

@end

NS_ASSUME_NONNULL_END
