//
//  ELHeightBodyFatScaleBleManager.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/3/24.
//  Copyright © 2021 IOT. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELHeightBodyFatScaleBleHeader.h"
#import "ELSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class ELHeightBodyFatScaleBleWeightBodyModel;
@class ELPeripheralModel;
@class ELEightScaleBleDataModel;


@protocol ELHeightBodyFatScaleBleDelegate <NSObject>

@optional
 
/** 返回设备连接状态 */
- (void)heightBodyFatScaleManagerUpdateState:(ELBluetoothState)state;

/** 回调扫描到的身高体脂秤 */
- (void)heightBodyFatScaleManagerScanDevices:(NSArray<ELPeripheralModel *> *)scanDevices;

/** 回调用户信息设置结果 */
- (void)heightBodyFatScaleManagerSetUserDataResult:(HeightBodyFatScale_SetupResult)result;

/** MCU主动请求用户信息 */
- (void)heightBodyFatScaleManagerRequestUserData;

/** MCU设置单位 */
- (void)heightBodyFatScaleManagerMCUSetHeightUnit:(ELDeviceHeightUnit)heightUnit weightUnit:(ELDeviceWeightUnit)weightUnit;

/** MCU回复单位设置结果 */
- (void)heightBodyFatScaleManagerReportUnitResult:(HeightBodyFatScale_SetupResult)result;

/** 人体成份分析仪 MCU回复单位设置结果 */
- (void)heightBodyFatScaleManagerReportHeightUnit:(ELDeviceHeightUnit)heightUnit weightUnit:(ELDeviceWeightUnit)weightUnit;


/** MCU回复工作模式设置结果 */
- (void)heightBodyFatScaleManagerWorkModeResult:(HeightBodyFatScale_SetupResult)result;

/** MCU回复声音设置结果 */
- (void)heightBodyFatScaleManagerVideoSetupResult:(HeightBodyFatScale_SetupResult)result;

/** MCU回复设备状态
 * @param mode : 工作模式
 * @param power : 设备电量
 * @param charging : 是否在充电
 * @param weightUnit : 重量单位
 * @param heightUnit : 身高单位
 * @param video : 语音开关
 */
- (void)heightBodyFatScaleManagerReportDevStateWithWorkMode:(HeightBodyFatScale_WorkModeType)mode power:(NSInteger)power charging:(BOOL)charging weightUnit:(ELDeviceWeightUnit)weightUnit height:(ELDeviceHeightUnit)heightUnit videoState:(BOOL)video DEPRECATED_MSG_ATTRIBUTE("use 'voiceState' instead");
- (void)heightBodyFatScaleManagerReportDevStateWithWorkMode:(HeightBodyFatScale_WorkModeType)mode power:(NSInteger)power charging:(BOOL)charging weightUnit:(ELDeviceWeightUnit)weightUnit height:(ELDeviceHeightUnit)heightUnit voiceState:(BOOL)voice;

/**  MCU回复设备支持模式 */
- (void)heightBodyFatScaleManagerReportDevModeArray:(NSArray *)modeArray;

#pragma mark  - 身高体脂秤模式

/** MCU上报称重状态 */
- (void)heightBodyFatScaleManagerReportWeighingState:(HeightBodyFatScale_WeightStableType)stable weightNumber:(NSInteger)weight weightPoint:(NSInteger)point unit:(ELDeviceWeightUnit)unit;

/** MCU上报阻抗数据
 * @param state : 阻抗测量状态
 * @param aisle : 通道
 * @param adc : 阻抗
 * @param algorithmId : 体脂算法ID  （若使用MCU端算法，则该值为 0
 */
- (void)heightBodyFatScaleManagerReportAdcDataWithImpedanceState:(HeightBodyFatScale_AdcStateType)state aisle:(HeightBodyFatScale_AdcAisleType)aisle adc:(NSInteger)adc algorithmId:(NSInteger)algorithmId;

/** MCU上报心率数据 */
- (void)heightBodyFatScaleManagerReportHeartRateDataWithState:(HeightBodyFatScale_HeartRateStateType)state bpm:(NSInteger)bpm;

/** MCU上报温度数据
 * @param negative : 是否为负温度
 * @param tem : 温度
 * @param point : 几位小数
 * @param unit 温度单位
 */
- (void)heightBodyFatScaleManagerReportTemDataWithNegative:(BOOL)negative tem:(NSInteger)tem point:(NSInteger)point unit:(ELDeviceTemperatureUnit)unit;

/** MCU上报身高数据 */
- (void)heightBodyFatScaleManagerReportHeightDataWithHeight:(NSInteger)height unit:(ELDeviceHeightUnit)unit point:(NSInteger)point;


/** MCU上报体脂数据 */
- (void)heightBodyFatScaleManagerReportBodyFatDataWithDataModel:(ELHeightBodyFatScaleBleWeightBodyModel *)model;

/** // 人体成份分析仪 MCU上报阻抗数据
 */
- (void)heightBodyFatScaleManagerReportAdcDataWithImpedanceState:(HeightBodyFatScale_AdcStateType)state bleDataModelWith:(ELEightScaleBleDataModel *)bleDataModel UseAppAlgorithm:(BOOL)useAppAlgorithm;

///// 人体成份分析仪 MCU请求补全体脂数据
- (void)heightBodyFatScaleManagerCompletionBodyFatDataWith:(ELEightScaleBleDataModel *)bleDataModel;

#pragma mark  - 抱婴模式

/** MCU上报称重状态
 * @param stable : 测量状态
 * @param adultWeight : 成人体重
 * @param allWeight : 成人+婴儿总体重
 * @param babyWeight : 婴儿重量
 * @param point : 小数位
 * @param unit : 单位
 */
- (void)heightBodyFatScaleManagerReportBabyModetWithWeighingState:(HeightBodyFatScale_WeightStableType)stable adultWeight:(NSInteger)adultWeight allWeight:(NSInteger)allWeight babyWeight:(NSInteger)babyWeight point:(NSInteger)point unit:(ELDeviceWeightUnit)unit;

#pragma mark  - 体重模式

/** MCU上报称重状态 */
- (void)heightBodyFatScaleManagerReportWeightModeWithWeighingState:(HeightBodyFatScale_WeightStableType)stable weightNumber:(NSInteger)weight point:(NSInteger)point unit:(ELDeviceWeightUnit)unit;

#pragma mark  - 体重身高模式

/** MCU上报称重状态 */
- (void)heightBodyFatScaleManagerReportWeightHeightModeWithWeighingState:(HeightBodyFatScale_WeightStableType)stable weightNumber:(NSInteger)weight point:(NSInteger)point unit:(ELDeviceWeightUnit)unit;

/** MCU上报身高数据 */
- (void)heightBodyFatScaleManagerReportWeightHeightMOdeWithHeightNumber:(NSInteger)height point:(NSInteger)point unit:(ELDeviceHeightUnit)unit;


#pragma mark  - 

/** MCU发送测量完成 */
- (void)heightBodyFatScaleManagerSendCompletedWithWorkMode:(HeightBodyFatScale_WorkModeType)type;

@end

@interface ELHeightBodyFatScaleBleManager : ELBluetoothManager

@property (nonatomic, weak) id<ELHeightBodyFatScaleBleDelegate> heightBodyFatScaleDelegate;

+ (ELHeightBodyFatScaleBleManager *)shareManager;

#pragma mark 发送指令

///设置用户信息
- (void)sendUserDataWithSex:(NSInteger)sex age:(NSInteger)age height:(NSInteger)cm DEPRECATED_MSG_ATTRIBUTE("use 'sendUserDataWithGender:age:heightInCm:' instead");
- (void)sendUserDataWithGender:(NSInteger)gender age:(NSInteger)age heightInCm:(NSInteger)heightInCm;

///App设置单位
- (void)sendUnitWithHeightUnit:(ELDeviceHeightUnit)heightUnit weightUnit:(ELDeviceWeightUnit)weightUnit;

///App回复单位设置结果
- (void)reportUnitSetupResult:(HeightBodyFatScale_SetupResult)result;

//App下发工作模式
- (void)sendDevceWorkMode:(HeightBodyFatScale_WorkModeType)model DEPRECATED_MSG_ATTRIBUTE("use 'sendDeviceWorkMode' instead");
- (void)sendDeviceWorkMode:(HeightBodyFatScale_WorkModeType)mode;

//App读取声音设置
- (void)getVideoSetup DEPRECATED_MSG_ATTRIBUTE("use 'getVoiceSetup' instead");
- (void)getVoiceSetup;

//App声音设置
- (void)sendVideoSetupState:(BOOL)state DEPRECATED_MSG_ATTRIBUTE("use 'sendVoiceSetting' instead");
- (void)sendVoiceSetting:(BOOL)on;

//App获取工作状态
- (void)getWorkState;

//App回复测量完成
- (void)sendWeighingCompleted;

#pragma mark A6指令


@end

NS_ASSUME_NONNULL_END
