//
//  ELCM02_BleManager.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/9/13.
//  Copyright © 2021 IOT. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELCM02_HeartbeatBleModel.h"
#import "ELCM02_BatteryBleModel.h"
#import "ELCM02_BleSupportFunctionModel.h"
#import "ELCM02_BleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CM02_BleDelegate <NSObject>

@optional

- (void)CM02ManagerUpdateState:(enum ELBluetoothState)state;

- (void)CM02ManagerScanDevices:(NSArray<ELPeripheralModel *> *_Nullable)CM02Devices;

/** 返回设备支持的功能 */
- (void)CM02ManagerBackSupportFunctionModel:(ELCM02_BleSupportFunctionModel *)model;

/** CM02返回设备心跳数据 */
- (void)CM02ManagerBackHeartbeatModel:(ELCM02_HeartbeatBleModel *)model;

/** CM02回复修改密码结果 */
- (void)CM02ManagerBackUpdatePasswordResult:(enum CM02_Result_Type)result;

/** CM02回复解锁和开锁状态 */
- (void)CM02ManagerBackLockState:(enum CM02_LockState_Type)lock passwordResult:(enum CM02_PasswordCorrect_Type)result;

/** CM02回复售后密码 */
- (void)CM02ManagerBackAfterSalesPassword:(NSString *)afterSalesPassword;

/** CM02回复单次行程和对应时间 */
- (void)CM02ManagerBackSingleMileage:(float)kmMileage time:(NSInteger)second;

/** CM02回复总里程信息 */
- (void)CM02ManagerBackTotalMileage:(float)kmMileage;

/** CM02回复电池信息 */
- (void)CM02ManagerBackBatteryBleModel:(ELCM02_BatteryBleModel *)model;


/** CM02回复控制器编号，硬件版本号和软件版本号 */
- (void)CM02ManagerBackControlCode:(NSString *)code hardwareVersion:(NSString *)hardwareVersion softwareVersion:(NSString *)softwareVersion;

/** CM02回复仪表编号，硬件版本和软件版本号 */
- (void)CM02ManagerBackDashboardCode:(NSString *)code hardwareVersion:(NSString *)hardwareVersion softwareVersion:(NSString *)softwareVersion;

#pragma mark - 仪表OTA

/** 返回ota是否可以升级和可以接收的最大长度 */
- (void)CM02ManagerBackCanOTA:(BOOL)can maxLength:(int)length;

/** 返回ota升级数据结果以及接受到的数据包编号 */
- (void)CM02ManagerBackOTASendResult:(BOOL)canSendNext index:(long long)index;

/** 返回ota升级结果 */
- (void)CM02ManagerBackOTAUpdateResult:(BOOL)result;

#pragma mark -

@end

@interface ELCM02_BleManager : ELBluetoothManager

@property (nonatomic, weak) id<CM02_BleDelegate> CM02Delegate;
@property (nonatomic, assign) ELSupportDeviceType deviceType;
+ (ELCM02_BleManager *)shareManager;

///** 查询接收端类型及支持的功能 */
- (void)getDeviceBaseInformation;

/** 切换单位 */
- (void)changeUnit:(enum CM02_Unit_Type)unit;
/** 定速巡航开关 */
- (void)setCruiseSwitch:(BOOL)state;
/** 是否为非零速度启动 */
- (void)setSpeedStart:(BOOL)state;


/** 恢复出厂设置 */
- (void)resetDevice;
/** 清除除里程和时间外的其它控制器及仪表参数 */
- (void)clearOtherCacheData;
/** 清除总里程 */
- (void)clearTotalMileage;
/** 清除单次里程时间(设备一开机就会记录骑行时间和里程，当需要记录这些时间和里程的时候需要清除一下当次时间，重新开始记录) */
- (void)clearSingleTime;


/** 设置档位(1-7) */
- (void)setGear:(NSInteger)gear;


/** 开关灯 */
- (void)setLightState:(BOOL)state;


/** 修改密码 */
- (void)updatePasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

/** 解锁或者锁车（锁车无需传密码） 、查询仪表开锁验证密码功能状态、打开/关闭仪表开锁验证密码功能(需要携带密码)*/
- (void)setLockState:(enum CM02_LockState_Type)lock password:(NSString *)password;

//查询仪表开锁验证密码功能状态
- (void)requestUnlockPasswordState;

//打开仪表开锁验证密码功能(需要携带密码)
- (void)setUnlockPasswordOn:(NSString *)password;

//关闭仪表开锁验证密码功能(需要携带密码)
- (void)setUnlockPasswordOff:(NSString *)password;

/** 查询售后密码 */
- (void)getAfterSalesPassword;


/** 查询单次行驶里程和时间 */
- (void)getNowSingleMileageInformation;

/** 查询总里程 */
- (void)getTotalMileageInformation;

/** 查询电池信息 */
- (void)getBatteryInformation;

/** 查询控制器厂商代码及编号 */
- (void)getControlVersion;

/** 查询仪表盘固件版本 */
- (void)getDashboardVersion;

/** 导航推送
 * @param state : 更新导航数据 、开启导航、关闭导航
 * @param code : 导航方向代码
 * @param segmentRemainDistance : 当前方向剩余路程 m
 * @param routeRemainDistance :  总剩余路程 m
 */
- (void)setNavigationPushWithState:(enum ElectricScooter_NavigationState)state code:(enum ElectricScooter_NavigationPushCode)code segmentRemainDistance:(NSInteger)segmentRemainDistance routeRemainDistance:(NSInteger)routeRemainDistance;

/// 当前时区
/// @param positive YES：东时区，NO：西时区
/// @param value 时区，范围0-12
- (void)setCurrentTimeZoneWithPositive:(BOOL)positive value:(NSUInteger)value;

#pragma mark - 仪表OTA

/** 发送OTA开始指令
 * @param size : ota文件长度
 * @param data : crc32校验码，4个byte
 * @param length : 单次发送OTA数据包最大的长度
 */
- (void)sendStartOTAWithFileSize:(long long)size crc32Data:(NSData *)data maxPacketLength:(int)length;

/** 发送OTA数据 */
- (void)sendOTAUpdateFileWithIndex:(long long)index data:(NSData *)data;

/** 发送OTA完成指令 */
- (void)sendEndOTACommand;

#pragma mark - 断开设备清除缓存信息

- (void)cleanData;

@end

NS_ASSUME_NONNULL_END
