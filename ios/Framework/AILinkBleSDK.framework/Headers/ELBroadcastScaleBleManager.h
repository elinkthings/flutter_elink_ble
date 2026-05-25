//
//  ELBroadcastScaleBleManager.h
//  Elink
//
//  Created by iot_user on 2020/8/21.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELBroadcastScaleDataModel.h"

@protocol BroadcastScaleBleDelegate <NSObject>

@optional

//Bluetooth connection status（蓝牙连接状态）
-(void)broadcastScaleBleUpdateState:(ELBluetoothState)state;

//
-(void)broadcastScaleBleDataModel:(ELBroadcastScaleDataModel *_Nonnull)model;

@end



NS_ASSUME_NONNULL_BEGIN

@interface ELBroadcastScaleBleManager : ELBluetoothManager

@property (nonatomic, weak) id<BroadcastScaleBleDelegate> broadcastScaleBleDelegate;


+(instancetype)shareManager;



@end

NS_ASSUME_NONNULL_END
