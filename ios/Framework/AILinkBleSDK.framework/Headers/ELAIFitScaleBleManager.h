//
//  ELAIFitScaleBleManager.h
//  Pods
//
//  Created by LarryZhang on 2023/8/11.
//

#import "ELBluetoothManager.h"
#import "ELAIFitScaleBleHeader.h"
NS_ASSUME_NONNULL_BEGIN
@class ELAIFitScaleBleDataModel,ELAIFitScaleBleUserModel;
@protocol AIFitScaleBleDelegate;

@interface ELAIFitScaleBleManager : ELBluetoothManager

@property(nonatomic, weak) id <AIFitScaleBleDelegate> aifitScaleBleDelegate;


+ (instancetype)shareManager;

@end

@interface ELAIFitScaleBleManager ()

- (void)autoScan;
- (void)stopAutoScan;
- (void)checkStatus;

@end

@interface ELAIFitScaleBleManager ()

- (void)aIFitSendSwitUnit:(AIFitScaleWeightUnit)unit;

- (void)aIFitSendRequestBMVer;
- (void)aIFitSendSyncDateTime;
- (void)aIFitSendCurrentUserInfoWithUserId:(NSInteger)userId Sex:(NSInteger)sex Age:(NSInteger)age Height:(NSInteger)height;
- (void)aIFitSendCurrentUserInfoList:(NSArray *)userList;
- (void)aIFitSendRequestHistory ;

@end

@protocol AIFitScaleBleDelegate <NSObject>

@optional

/// 蓝牙连接状态
/// @param state 连接状态
- (void)deviceBleReceiveState:(ELBluetoothState)state;


/// @param result :秤进入低功耗模式(秤黑屏）
- (void)deviceBleReceiveDevicesLightOff:(BOOL)result;

/// 附近的设备
/// @param devices 设备列表
- (void)deviceBleReceiveDevices:(NSArray<ELPeripheralModel *> *_Nullable)devices;

//正在连接中倒计时
- (void)deviceBleCountDown:(NSInteger)count;

//ble version
- (void)firmwareVersion:(NSString *)version;

- (void)bluetoothReceivePassData:(NSData *)data;


- (void)blueToothBackConnectScaleWeightData:(ELAIFitScaleBleDataModel *)model status:(MeasureStatus)status;


- (void)blueToothBackAdc:(NSUInteger)adc status:(AdcMeasureStatus)status;

- (void)blueToothBackHistoryDataModel:(ELAIFitScaleBleUserModel *)userModel  bodyDataModel:(ELAIFitScaleBleDataModel*)dataModel status:(HistoryStatus)status;

- (void)blueToothBackAlgorithmNumber:(NSUInteger)algorithmNo;
- (void)blueToothBackWriteCurrentUserResult:(BOOL)result;
- (void)blueToothBackChangeUnitResult:(BOOL)result;
- (void)blueToothBackWriteAppTimeToBleResult:(BOOL)result;
- (void)blueToothBackWriteOfflineUserListResult:(BOOL)result;
- (void)blueToothBackUpdateOfflineSingleUserResult:(BOOL)result;


@end

NS_ASSUME_NONNULL_END
