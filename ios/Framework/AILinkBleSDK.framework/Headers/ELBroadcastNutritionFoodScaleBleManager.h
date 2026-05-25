//
//  ELBroadcastNutritionFoodScaleBleManager.h
//  Elink
//
//  Created by iot_user on 2020/8/21.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELBroadcastNutritionFoodScaleDataModel.h"

@protocol BroadcastNutritionFoodScaleBleDelegate <NSObject>

@optional

//Bluetooth connection status（蓝牙连接状态）
- (void)broadcastNutritionFoodScaleBleUpdateState:(ELBluetoothState)state;

//
- (void)broadcastNutritionFoodScaleBleDataModel:(ELBroadcastNutritionFoodScaleDataModel *_Nonnull)model;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ELBroadcastNutritionFoodScaleBleManager : ELBluetoothManager

@property(nonatomic, weak) id <BroadcastNutritionFoodScaleBleDelegate> broadcastNutritionFoodScaleBleDelegate;


+ (instancetype)shareManager;


@end

NS_ASSUME_NONNULL_END
