//
//  ELBloodSugarBleManager.h
//  Elink
//
//  Created by iot_user on 2020/7/7.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import <AILinkBleSDK/ELBluetoothManager.h>
#import "ELBloodSugarBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface BloodSugarDataStruct : NSObject

@property (nonatomic, assign) int value; //数值

@property (nonatomic, assign) enum ELDeviceBloodSugarUnit unit; //单位

@property (nonatomic, assign) int point;    //小数点

@property (nonatomic, copy) NSString *timeStr;  //时间 yyyy/MM/dd HH:mm:ss

@property (nonatomic, assign) int serialNumber; //小数点

@end

@protocol BloodSugarBleDelegate <NSObject>

@optional

/// 蓝牙连接状态
/// @param state 连接状态
-(void)bloodSugarBleReceiveState:(ELBluetoothState)state;

/// 附近的血糖仪设备
/// @param devices 血糖仪设备列表
-(void)bloodSugarBleReceiveDevices:(NSArray<ELPeripheralModel *> *)devices;

/// 回调设备状态
/// @param status 状态
-(void)bloodSugarBleReceiveDeviceStatus:(BloodSugarDeviceStatus)status;

/// 回调测量结果数据
/// @param data 数据
-(void)bloodSugarBleReceiveTestData:(BloodSugarDataStruct *)data;

/// 回调设置单位的结果
/// @param result 结果
-(void)bloodSugarBleReceiveSwitchUnitResult:(ELSetBluetoothResponseType)result;

/// 上报错误码
/// @param errorCode 错误码
-(void)bloodSugarBleReceiveErrorCode:(BloodSugarErrorCode)errorCode;

/** 设备返回历史记录 */
- (void)bloodSugarBleReceiveBackOfflineHistory:(NSArray<BloodSugarDataStruct *> *)history;

///返回原始数据
- (void)bloodSugarBleBackManufactureData:(NSData *)data;
@end


@interface ELBloodSugarBleManager : ELBluetoothManager

@property (nonatomic, weak) id<BloodSugarBleDelegate> bloodSugarDelegate;


+(instancetype)shareManager;



//查询设备状态
-(void)bloodSugarQueryDeviceStatus;

//切换单位
-(void)bloodSugarSwitchUnit:(ELDeviceBloodSugarUnit)unit;

//App获取离线历史记录
- (void)bloodSugarGetOfflineHistory;

@end

NS_ASSUME_NONNULL_END
