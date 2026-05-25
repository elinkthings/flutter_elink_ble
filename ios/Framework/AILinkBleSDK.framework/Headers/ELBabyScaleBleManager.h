//
//  ELBabyScaleBleManager.h
//  Elink
//
//  Created by iot_user on 2019/4/19.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELPeripheralModel.h"
#import "ELBabyScaleBleWeightModel.h"
#import "ELBabyScaleBleHeightModel.h"
#import "ELBabyScaleBleHeader.h"

@protocol BabyScaleBleDelegate <NSObject>
@optional
//Callback Bluetooth status（回调蓝牙状态）
- (void)babyScaleManagerUpdateState:(ELBluetoothState)state;
//Callback to all baby scale equipment（回调所有婴儿秤设备）
- (void)babyScaleManagerScanDevices:(NSArray<ELPeripheralModel *> *_Nullable)babyScaleDevices;
//Callback weight data（回调体重数据）
- (void)babyScaleManagerReceiveWeightModel:(ELBabyScaleBleWeightModel *_Nonnull)model;
//Callback height data（回调身高数据）
- (void)babyScaleManagerHeightModel:(ELBabyScaleBleHeightModel *_Nonnull)model;

/** Return the result of the unit setting（返回单位设置的结果） */
- (void)babyScaleBackSetUnitResults:(BabyScaleResultType )result;

/** Callback peeling (zeroing) and locking results（回调去皮(归零)和锁定结果）
 * type : 0 peeled, 1 locked（0去皮，1锁定）
 */
- (void)babyScaleBackCtrlType:(NSInteger )type Results:(BabyScaleResultType )result;

/** The device sends an error code.（设备上发错误码） */
- (void)babyScaleBackDeviceErrorCode:(BabyScaleDeviceErrorCode )code;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ELBabyScaleBleManager : ELBluetoothManager



//Baby scale Bluetooth manager agent（婴儿秤蓝牙管理者代理）
@property (nonatomic, weak) id<BabyScaleBleDelegate> babyScaleDelegate;

+(ELBabyScaleBleManager *)shareManager;
#pragma mark Hold YES is locked, NO is peeled (return to zero)（hold YES为锁定，NO去皮（归零））
-(void)changeHold:(BOOL)hold;
#pragma mark Height and weight unit switching（身高和体重单位切换）
-(void)changeHeightUnit:(ELDeviceHeightUnit)heightUnit AndWeightUnit:(ELDeviceWeightUnit)weightUnit;

@end

NS_ASSUME_NONNULL_END
