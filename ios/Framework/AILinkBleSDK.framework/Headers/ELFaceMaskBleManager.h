//
//  ELFaceMaskBleManager.h
//  Elink
//
//  Created by iot_user on 2020/9/30.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELFaceMaskBleHeader.h"
#import "ELFaceMaskBleDataModel.h"

@protocol FaceMaskBleDelegate <NSObject>

@optional

/// 蓝牙连接状态
/// @param state 连接状态
- (void)faceMaskBleReceiveState:(ELBluetoothState)state;

/// 附近的设备
/// @param devices 设备列表
- (void)faceMaskBleReceiveDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;


- (void)faceMaskBleReceiveStatusDataModel:(ELFaceMaskBleDataModel *_Nonnull)model;

- (void)faceMaskReplaceSuccess:(BOOL)success;

- (void)faceMaskSwitchFanResult:(FaceMaskFanControlResult)result;

- (void)faceMaskPoweroffSuccess:(BOOL)success;


@end

NS_ASSUME_NONNULL_BEGIN

@interface ELFaceMaskBleManager : ELBluetoothManager

@property (nonatomic, weak) id<FaceMaskBleDelegate> faceMaskDelegate;

@property (nonatomic, assign) FaceMaskFanStatus fanStatus;
@property (nonatomic, assign) NSInteger filterWorkTime;
@property (nonatomic, assign) int battery;

+ (instancetype)shareManager;

//APP 获取设备状态
- (void)queryFaceMaskStatusData;
//APP 下发更换滤网指令
- (void)replaceFilter;
//APP 下发风扇控制指令
- (void)switchFanStatus:(FaceMaskFanStatus)status;
//APP 下发关机指令
- (void)powerOff;

@end

NS_ASSUME_NONNULL_END
