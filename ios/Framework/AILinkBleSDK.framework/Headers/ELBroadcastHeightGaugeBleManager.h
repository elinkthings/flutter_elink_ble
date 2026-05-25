//
//  ELBroadcastHeightGaugeBleManager.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/3/19.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <AILinkBleSDK/ELBluetoothManager.h>
#import "ELBroadcastHeightGaugeBleDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ELBroadcastHeightGaugeBleDelegate <NSObject>

@optional

/**Callback Bluetooth status(回调蓝牙状态) */
- (void)broadcastHeightGaugeUpdateState:(ELBluetoothState)state;

/** Call back all height gauge devices(回调所有身高仪设备) */
- (void)broadcastHeightGaugeScanDevices:(NSArray<ELPeripheralModel *> *)heightGaugeDevices;

/** 回调身高数据 */
- (void)broadcastHeightGaugeDeviceDataModel:(ELBroadcastHeightGaugeBleDataModel *)model;

@end

@interface ELBroadcastHeightGaugeBleManager : ELBluetoothManager

@property (nonatomic, weak) id<ELBroadcastHeightGaugeBleDelegate> heightGaugeDelegate;

+(instancetype)shareManager;

@end

NS_ASSUME_NONNULL_END
