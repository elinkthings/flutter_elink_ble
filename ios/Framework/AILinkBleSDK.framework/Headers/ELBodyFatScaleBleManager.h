//
//  ELScaleBleManager.h
//  Elink
//
//  Created by cliCk on 2019/5/28.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <AILinkBleSDK/ELBluetoothManager.h>
#import "ELBodyFatScaleBleHeader.h"

@class ELBodyFatScaleBleUserModel,ELBodyFatScaleBleWeightModel,ELBodyFatScaleDeviceModel;
NS_ASSUME_NONNULL_BEGIN

@protocol ELBodyFatScaleBleDelegate <NSObject>

@optional

/** Callback Bluetooth status(回调蓝牙状态) */
- (void)bodyFatScaleManagerUpdateState:(ELBluetoothState )state;

/**Callback all body fat scales detected( 回调扫描到的所有体脂秤 )*/
- (void)bodyFatScaleManagerScanDevices:(NSArray<ELBodyFatScaleDeviceModel *> *)scaleDevices;

/// 回调透传数据
- (void)bodyFatScaleManagerReceivePassData:(NSData *)data;

#pragma mark 回调A7指令数据

/**
 Callback to set unit result(回调设置单位结果)

 @param result 结果
 */
- (void)bodyFatScaleManagerCallBackSetUnitResult:(ELSetBluetoothResponseType)result;

/**
MCU requests user information( MCU 请求用户信息)

 @param status 请求状态
 */
- (void)bodyFatScaleManagerMCURequestAppUserInfoType:(BodyFatScaleMCURequestUserInfoStatus)status;


/**
 Return weight and body fat model(返回重量及体脂model)
 */
-(void)bodyFatScaleManagerCallBackWeight:(ELBodyFatScaleBleWeightModel *)weightModel state:(BodyFatScaleMeasureStatus)status;


/**
 Return temperature (unit: ° C)(返回温度（单位：°C）)

 @param temp 温度（单位：°C）
 */
-(void)bodyFatScaleManagerCallBackTemp:(NSString *)temp;

/**
 Back to impedance measurement(返回阻抗测量)

 @param status 阻抗测量状态
 @param adc 阻抗
 */
-(void)bodyFatScaleManagerCallBackAdcMeasureStatus:(BodyFatScaleAdcMeasureStatus)status adcValue:(NSInteger)adc;

/**
 Callback heart rate measurement(回调心率测量)
 
 @param status 心率测量状态
 @param heartRate 心率
 */
-(void)bodyFatScaleManagerCallBackHeartRateMeasureStatus:(BodyFatScaleHeartRateMeasureStatus)status heartRateValue:(NSInteger)heartRate;

/**
 Return error code(返回错误码)

 @param code 错误码
 1:超重
 */
-(void)bodyFatScaleManagerCallBackErrorCode:(NSInteger)code;
#pragma mark 回调A6指令数据

/**
 Send success or failure callback for offline user list(发送离线用户列表的成功或失败回调)

 @param status 状态
 */
-(void)bodyFatScaleManagerCallBackUpdateRecordStatus:(BodyFatScaleUpdateRecordStatus)status;

/**
 Request callback for offline history(请求离线历史记录的回调)

 @param status 状态
 */
-(void)bodyFatScaleManagerCallBackSendHistoryDataStatus:(BodyFatScaleSendHistoryDataStatus)status;

/**
 APP algorithm-offline history data(APP 算法-离线历史记录数据)

 @param user 用户信息
 */
-(void)bodyFatScaleManagerCallBackBleUserHistoryDataCustomADCModel:(ELBodyFatScaleBleUserModel *)user bodyDataModel:(ELBodyFatScaleBleWeightModel *)bodyModel;

/**
 MCU algorithm-offline history data(MCU 算法-离线历史记录数据)

 @param user 用户信息
 @param bodyModel 体脂数据
 */
-(void)bodyFatScaleManagerCallBackBleUserHistoryDataModel:(ELBodyFatScaleBleUserModel *)user bodyDataModel:(ELBodyFatScaleBleWeightModel *)bodyModel;

/** MCU replies to the result of setting the ip address (MCU回复设置ip地址结果 )
 * @param result : 1：成功，0:失败，2:不支持
 */
- (void)bodyFatScaleManagerCallBackSetIPAddressResult:(NSInteger)result;

/** MCU reporting mode (MCU上报模式 )
 * @param mode : 0：体脂模式(默认)，1:体重模式(没有阻抗和体脂数据)
 */
- (void)bodyFatScaleManagerCallBackReportingMode:(NSInteger)mode;


/** MCU 返回支持数据类型列表
 */
- (void)bodyFatScaleManagerCallBackSupportDataList:(NSMutableArray*)dataList;

/** MCU 返回显示项和顺序
 */
- (void)bodyFatScaleManagerCallBackDisplayItemOrder:(NSMutableArray*)dataList;
@end



@interface ELBodyFatScaleBleManager : ELBluetoothManager


@property (nonatomic,weak) id<ELBodyFatScaleBleDelegate> bodyFatScaleDelegate;

+ (ELBodyFatScaleBleManager *)shareManager;

@property (nonatomic, assign, getter=isManualSendReceivedDataResult) BOOL manualSendReceivedDataResult;

#pragma mark  ============ 下发A7指令 ==============
- (void)changeBodyFatScaleUnit:(ELDeviceWeightUnit)unit;
- (void)sendCurrentUserToBle:(ELBodyFatScaleBleUserModel *)usr;

-(void)sendReceivedDataResult:(BOOL)result;
//APP请求支持的显示项(0x0076)
- (void)get0x0076SupportDataTypeList;
//APP下发显示项和顺序(0x10)
- (void)readDeliverDisplayItemsTheirSequence;
- (void)sendDeliverDisplayItemsTheirSequence:(NSMutableArray*)dataList;
#pragma mark  ============ 下发A6指令 ==============

-(void)sendOfflineUserListToBle:(NSArray <ELBodyFatScaleBleUserModel *> *)userListArr;

-(void)updateSingleUserInOfflineUserList:(ELBodyFatScaleBleUserModel *)usr;

-(void)sendCmd_RequestHistory;

/** 设置设备的IP地址，端口号和访问路径 */
- (void)setDevAccessIpAddress:(NSString *)address portNumber:(NSUInteger)portNum path:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
