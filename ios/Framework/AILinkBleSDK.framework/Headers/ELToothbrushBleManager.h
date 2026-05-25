//
//  ELToothbrushBleManager.h
//  Elink
//
//  Created by iot_user on 2020/5/11.
//  Copyright © 2020 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELToothburshHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ToothbrushDelegate <NSObject>

@optional
//Bluetooth status callback(回调蓝牙状态)
- (void)toothbrushReceiveState:(ELBluetoothState)state;

//Callback toothbrush device list(回调牙刷设备列表)
- (void)toothbrushReceiveDevices:(NSArray<ELPeripheralModel *> *)devices;

/// Callback gear information(回调档位信息)
/// @param oneGear First gear(一档档位)
/// @param twoGear Second gear(二档档位)
- (void)toothbrushReceiveOneGear:(NSArray<NSNumber *> *)oneGear twoGear:(NSArray<NSNumber *> *)twoGear;

/// Set work gear result(设置工作档位结果)
/// @param result 结果
- (void)toothbrushReceiveSetWorkGearResult:(ELSetBluetoothResponseType)result;

//Call back current working gear information(回调当前工作档位信息)
- (void)toothbrushReceiveWorkGear:(ToothbrushWorkGear)workGear;

/// Call back trial results(回调试用结果)
/// @param result 结果
- (void)toothbrushReceiveTryResult:(ToothbrushSetResult)result;

/// Report work phase(上报工作阶段)
/// @param workPhase Work stage information(工作阶段信息)
- (void)toothbrushReceiveWorkPhase:(ToothBrushWorkPhase)workPhase;

/** 0xFC 针对当前刷牙时间新增的上报工作状态 */
- (void)toothbrushReceiveNewWorkPhase:(ToothBrushNewWorkPhase)workPhase;

/// Recall the data of manually set gear(回调手动设置档位的数据)
/// @param custom data(数据)
- (void)toothbrushReceiveCustomData:(ToothbrushCustomData)custom;

/// Callback switch toothbrush result(回调开关牙刷结果)
/// @param result 结果
- (void)toothbrushReceiveSwitchResult:(ToothbrushSetResult)result;


/// Callback three-axis direction(回调三轴方向)
/// @param direction 方向
- (void)toothbrushReceiveTriaxialDirection:(ToothbrushTriaxialDirection)direction;

/// Recall three-axis data(回调三轴数据)
/// @param success 是否成功
/// @param x x轴数据
/// @param y y轴数据
/// @param z z轴数据
- (void)toothbrushReceiveTriaxialData:(BOOL)success triaxialX:(int)x triaxialY:(int)y triaxialZ:(int)z;

/// Default value of second gear(二档档位默认值)
/// @param gear Second gear(二档档位)
- (void)toothbrushReceiveTwoGearDefault:(ToothbrushGearType)gear;

/// Set the second gear default gear result(设置二档默认档位结果)
/// @param result 结果
- (void)toothbrushReceiveSettingTwoGearDefaultResult:(ELSetBluetoothResponseType)result;

/// Call back brushing data(回调刷牙数据)
/// @param data 刷牙数据
- (void)toothbrushtReceiveToothbrushData:(ToothbrushData)data;

/// Call back brushing offline data(回调刷牙数据)
/// @param data 刷牙离线数据
- (void)toothbrushtReceiveToothbrushOfflineData:(ToothbrushOfflineData)data;

- (void)toothbrushtReceiveToothbrushOfflineDataCount:(unsigned char)count result:(unsigned char)result;

/** 回复离线历史记录数据发送状态 */
- (void)toothbrushReceiveRecordDataStatus:(enum ToothbrushOfflineRecrodStatusType)status;


/** MCU replies to the result of setting the ip address (MCU回复设置ip地址结果 )
 * @param result : 1：成功，0:失败，2:不支持
 */
- (void)toothbrushManagerCallBackSetIPAddressResult:(NSInteger)result;

//MCU response Prevent Splashing mode 防飞溅
- (void)toothbrushtReceivePreventSplashing:(Byte)support on:(Byte)on;

@end


@interface ELToothbrushBleManager : ELBluetoothManager
//Current working mode(当前工作模式)
@property(nonatomic, assign) ToothbrushGearType currentMode;
//Current default working hours(当前默认工作时长)
@property(nonatomic, assign) NSInteger currentWorkTime;
//Current gear(当前档位)
@property(nonatomic, assign) ToothSupportGearType currentGear;


@property(nonatomic, weak) id <ToothbrushDelegate> toothbrushDelegate;


+ (instancetype)shareManager;


//Get supported gear(获取支持的档位)
- (void)getGear;

/// Set brushing mode(设置刷牙模式) //******** wifi 牙刷专用方法
/// @param gearType Brushing mode(刷牙模式)
/// @param interval Brushing time (0: do not modify the working time, before keeping)(刷牙时间(0:不修改工作时长，保留之前))
/// @param supportType Which gear is it(是哪个档位)
- (void)setWorkGear:(ToothbrushGearType)gearType interval:(int)interval supportGearType:(ToothSupportGearType)supportType;
//******** 通用牙刷专用方法
- (void)setWorkGear:(ToothbrushGearType)gearType interval:(int)interval supportGearType:(ToothSupportGearType)supportType withCid:(ELSupportDeviceType)cid;

/// Get the current working gear(获取当前工作的档位) //******** wifi 牙刷专用方法
- (void)getWorkGear;
//******** 通用牙刷专用方法
- (void)getWorkGearWithCid:(ELSupportDeviceType)cid;

/// try out(试用) //******** wifi 牙刷专用方法
/// @param gear Gear (ToothbrushGearTypeStop_00 means stop trial)(档位(ToothbrushGearTypeStop_00 表示停止试用))
/// @param supportType Which gear(第几档)
/// @param frequency 频率
/// @param duty 占空比
- (void)tryGear:(ToothbrushGearType)gear supportType:(ToothSupportGearType)supportType frequency:(int)frequency duty:(int)duty;
//******** 通用牙刷专用方法
- (void)tryGear:(ToothbrushGearType)gear supportType:(ToothSupportGearType)supportType frequency:(int)frequency duty:(int)duty withCid:(ELSupportDeviceType)cid;

/// Get the current work stage(获取当前工作阶段) //******** wifi 牙刷专用方法
- (void)getWorkPhase;
//******** 通用牙刷专用方法
- (void)getWorkPhaseWithCid:(ELSupportDeviceType)cid;

/// Set manual setting gear(设置手动设置档位) //******** wifi 牙刷专用方法
/// @param frequency 频率
/// @param duty 占空比
/// @param interval 时间
- (void)setCustomGearData:(int)frequency duty:(int)duty interval:(int)interval;
//******** 通用牙刷专用方法
- (void)setCustomGearData:(int)frequency duty:(int)duty interval:(int)interval withCid:(ELSupportDeviceType)cid;

/// Get manual profile data(获取手动设置档数据)
- (void)getCustomGear;

- (void)getCustomGearWithCid:(ELSupportDeviceType)cid;

/// Switch toothbrush(开关牙刷)
- (void)switchToothbrush;

- (void)switchToothbrushWithCid:(ELSupportDeviceType)cid;

//Get three axis direction(获取三轴方向)
- (void)getTriaxialDirection;

//APP 获取离线历史记录条数 二级指令 0x11
- (void)getOfflineDataCount;

//APP 请求接收离线历史记录 二级指令 0x12
- (void)getOfflineDataStart;

//APP 取消接收离线历史记录 二级指令 0x13
- (void)getOfflineDataCancel;

//APP 请求清空离线历史记录 二级指令 0x14
- (void)getOfflineDataClear;

//APP 请求设备继续发送离线历史记录 二级指令 0x16
- (void)getOfflineNextRecord;

//Get three-axis data(获取三轴数据)
- (void)getTriaxialData;

//Set the second gear default gear(设置二档默认档位) //******** wifi 牙刷专用方法
- (void)setTwoGearDefaultGear:(ToothbrushGearType)gear;
//******** 通用牙刷专用方法
- (void)setTwoGearDefaultGear:(ToothbrushGearType)gear withCid:(ELSupportDeviceType)cid;

//Get the second gear default gear(获取二档默认档位)
- (void)getTwoGearDefualt;
//******** 通用牙刷专用方法
- (void)getTwoGearDefualtWithCid:(ELSupportDeviceType)cid;

//Report the results of receiving brushing data(上报刷牙数据接收结果) //******** wifi 牙刷专用方法
- (void)reportReceiveResultOfToothbrushData:(BOOL)result;
//******** 通用牙刷专用方法
- (void)reportReceiveResultOfToothbrushData:(BOOL)result withCid:(ELSupportDeviceType)cid;

///清除wifi记录指令
- (void)bleWifiCleanWifiRecord;

///获取设备连接的wifi名称
- (void)getBleLinkWifiName;

/// Request device authorization(请求设备授权)
/// @param interval 时间截
-(void)requestDeviceAuthorization:(NSInteger)interval;


/** 设置设备的IP地址，端口号和访问路径 */
- (void)setDevAccessIpAddress:(NSString *)address portNumber:(NSUInteger)portNum path:(NSString *)path;

/** app查询BLE工作状态 0xFC */
- (void)getDevBleWorkState:(enum ELSupportDeviceType)cid;

//APP request Prevent Splashing mode 防飞溅 (cid 0x002D BLE only)
- (void)getPreventSplashingMode;
- (void)setPreventSplashingMode:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
