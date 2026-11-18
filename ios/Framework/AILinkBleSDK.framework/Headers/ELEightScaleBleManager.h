//
//  ELEightScaleBleManager.h
//  Elink
//
//  Created by iot_user on 2020/6/1.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELEightScaleSDKHeader.h"
#import "ELEightScaleBleDataModel.h"
#import "ELEightScaleBleBfrDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EightScaleBleDeletegate <NSObject>

@optional

/// Bluetooth connection status(蓝牙连接状态)
/// @param state connection status(连接状态)
-(void)eightScaleBleReceiveState:(ELBluetoothState)state;

/// Nearby eight-electrode equipment(附近的八电极设备)
/// @param devices Eight electrode equipment list(八电极设备列表)
-(void)eightScaleBlReceiveDevices:(NSArray<ELPeripheralModel *> *)devices;

/// Return weighed weight data(返回称量的体重数据)
/// @param weightStruct Weight data structure(体重数据结构体)
-(void)eightScaleBleReceiveWeightData:(EightScaleWeightStruct)weightStruct;


/// Return impedance data(返回阻抗数据)
/// @param adcStruct Impedance data structure(阻抗数据结构体)
-(void)eightScaleBleReceiveAdcData:(EightScaleAdcStruct)adcStruct;

/// Return heart rate data(返回心率数据)
/// @param testStep Heart rate measurement process(心率测量过程)
/// @param heartRate Heart rate data(心率数据)
-(void)eightScaleBleReceiveHeartRateTestStep:(EightScaleHeartRateTestStep)testStep heartRate:(int)heartRate;

/// Return temperature data(返回温度数据)
/// @param tempStruct Temperature data structure(温度数据结构体)
-(void)eightScaleBleReceiveTempData:(EightScaleTempStruct)tempStruct;

///Measurement completed(测量完成)
-(void)eightScaleBleReceiveTestComplete;

/// Recall measurement data(回调测量数据)
/// @param dataModel Measurement data(测量数据)
-(void)eightScaleBleReceiveTestData:(ELEightScaleBleDataModel *)dataModel;

/// Error code sent on the device(设备上发错误码)
/// @param errorCode Error code (1: overweight)(错误码(1：超重))
-(void)eightScaleBleReceiveErrorCode:(int)errorCode;

/// Switch temperature unit result(切换温度单位结果)
/// @param result 结果
-(void)eightScaleBleReceiveSwitchTempUnitResult:(EightScaleSwitchUnitResult)result;
/// Switch weight unit result(切换体重单位结果)
/// @param result 结果
-(void)eightScaleBleReceiveSwitchWeightUnitResult:(EightScaleSwitchUnitResult)result;


///MCU上报身高数据
- (void)eightScaleBleReportHeightDataWithHeight:(NSInteger)height unit:(ELDeviceHeightUnit)unit testStatus:(enum EightScaleTestStatus)status;

///MCU请求用户信息
- (void)eightScaleBleGetUserData;
//新格式
- (void)eightScaleBleNewGetUserData;

///MCU返回设备测量信息(测量完成的时候才会回调该方法)
- (void)eightScaleBleReportTestData:(ELEightScaleBleDataModel *)dataModle bfrData:(ELEightScaleBleBfrDataModel *)bfrDataModle;
// 双频八电极mcu测量完成返回数据(测量完成的时候才会回调该方法)
- (void)eightScaleBle0x0068ReportTestData:(ELEightScaleBleDataModel *)dataModel bodyFatData:(ELEightScaleBleBfrDataModel *)bfrDataModel;
/** MCU返回操作结果 */
- (void)eightScaleBleReportOperationWithType:(enum EightScaleOperationType)type unitResult:(enum EightScaleSwitchUnitResult)result;

/** 设备上发错误码 */
- (void)eightScaleBleReportErrorCode:(enum EightScaleErrorCodeType)type;

//回调透传数
- (void)eightScaleBleReceivePassData:(NSData *)data;

///MCU请求补全体脂数据
- (void)eightScaleBleCompletionBodyFatData;
- (void)eightScaleBleCompletionBodyFatData:(ELEightScaleBleDataModel *)dataModel;

/**
 Back to impedance measurement(返回阻抗测量)

 @param status 阻抗测量状态
 */
-(void)eightScaleScaleManagerCallBackAdcMeasureStatus:(DualBandEightScaleAdcMeasureStatus)status;


/**
 MCU回复回复支持的功能
 @param offlineRecordValue 离线记录
 @param modeValue 用户模式
 */
- (void)eightScaleMCUReportSupportFunction:(NSInteger)offlineRecordValue mode:(NSInteger)modeValue;


/**
 BM回复更新状态
 @param status
 00：更新列表成功
 01：更新个人用户成功
 02：更新列表失败
 03：更新个人用户失败
 */
- (void)updateBMReplyStatus:(NSInteger)status;


/**
 BM回复历史记录情况
 @param historyRecordStatus
 00：无历史记录
 01：开始发送历史记录
 02：结束发送历史记录
 */
- (void)historyRecordBMReplyStatus:(EightScaleHistoryRecordCodeType)historyRecordStatus;

//mcu算法一条记录结束后回调
- (void)mcuAlgorithmHistoryRecordBMReplyFinishRecord:(ELEightScaleMCUAlgorithmHistoryDataModel*)mcuAlgorithmHistoryRecordModel;

//单频app算法一条记录结束后回调
- (void)appAlgorithmSingleFrequencyHistoryRecordBMReplyFinishRecord:(ELEightScaleAPPAlgorithmSingleFrequencyHistoryDataModel*)appAlgorithmSingleFrequencyHistoryRecordModel;

//双频app算法一条记录结束后回调
- (void)appAlgorithmDoubleFrequencyHistoryRecordBMReplyFinishRecord:(ELEightScaleAPPAlgorithmDoubleFrequencyHistoryDataModel*)appAlgorithmDoubleFrequencyHistoryRecordModel;


@end

@interface ELEightScaleBleManager : ELBluetoothManager
//Current measurement status(当前测量状态)
@property (nonatomic, assign) EightScaleTestStatus testStatus;

@property (nonatomic, weak) id<EightScaleBleDeletegate> eightScaleDelegate;


+(instancetype)shareManager;


#pragma mark  ============ 发送数据指令给蓝牙 ==============

/// Switch weight unit(切换体重单位)
/// @param unit Weight unit(体重单位)
-(void)eightScaleSwitchWeightUnit:(ELDeviceWeightUnit)unit;

///双频八电级
/// Switch weight unit(切换体重单位)
/// @param unit Weight unit(体重单位)
-(void)doubleEightScaleSwitchWeightUnit:(ELDeviceWeightUnit)unit;


/// Switch temperature unit(切换温度单位)
/// @param unit Temperature unit(温度单位)
-(void)eightScaleSwitchTempUnit:(ELDeviceTemperatureUnit)unit;


/** 设置用户信息 */
- (void)eightScaleSendUserDataWithUserModel:(ELEightScaleBleUserModel *)model;

/** 回复测量完成 */
- (void)eightScaleSendEndTest;

/** 下发操作指令 */
- (void)eightScaleSendOperationWithType:(enum EightScaleOperationType)type unit:(NSInteger)unit;

/** 设置用户信息(新格式) */
- (void)eightScaleNewSendUserDataWithUserModel:(ELEightScaleBleUserModel *)model;

/** 下发用户列表（APP更新用户列表给BM模块） */
- (void)sendUpdateUserListWithUsers:(NSArray<ELEightScaleBleUserModel *> *)users;

/** 下发用户列表更新完成（通知BM模块） */
- (void)sendUpdateUserListFinished;

/** 更新个人用户信息给BM模块 */
- (void)sendUpdatePersonalInfoWithUserModel:(ELEightScaleBleUserModel *)model;

/** 请求同步历史记录 */
- (void)sendSyncHistoryRequest;

/** APP/BM回复用户信息 */
- (void)replyUserInformation:(ELEightScaleBleUserModel *)userInfo;

//APP获取MCU支持的模式
- (void)eightScaleSendGetMcuSupportFunction;
@end

NS_ASSUME_NONNULL_END
