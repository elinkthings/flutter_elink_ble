//
//  ELHygrothermographBleManager.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/5/7.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <AILinkBleSDK/ELBluetoothManager.h>
#import "ELHygrothermographBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class ELHygrothermographBleRecordData;

@protocol ELHygrothermographBleDelegate <NSObject>

@optional

/** 返回设备的连接状态 */
- (void)hygrothermographManagerUpdateState:(ELBluetoothState)state;

/** 回调扫描到的温湿度计 */
- (void)hygrothermographManagerScanDevices:(NSArray<ELPeripheralModel *> *)scanDevices;

/** 设备返回当前状态
 * @param power : 电量 0～100
 * @parm time : 设备开机时间
 * @param tem : 温度，单位摄氏度
 * @param hum : 湿度，单位%
 */
- (void)hygrothermographManagerReturnDevStatePower:(NSInteger)power bootTime:(long long)time tem:(float)tem hum:(float)hum;


/// 新设备返回当前状态
/// @param power 电量 0～100
/// @param time 设备开机时间,当该值不用发时,为0xFFFFFFFF. 当主控MCU有独立RTC芯片时,需要发. 当MCU主控无独立RTC芯片时,该值填0xFFFFFFFF
/// @param tem 温度
/// @param unit 温度单位
/// @param hum 湿度，单位%
/// @param state 当前设备状态，详细内容见枚举注释
/// @param isCharging 设备充电状态 默认是关闭状态
- (void)newTHManagerReturnDevStatePower:(int)power bootTime:(long long)time tem:(float)tem unit:(enum ELDeviceTemperatureUnit)unit hum:(float)hum devState:(enum TH_DevStateType)state isCharging:(BOOL)isCharging;



/** 设备返回阀值
 * @param tem : 温度阀值，单位摄氏度
 * @param hum : 湿度阀值，单位%
 */
- (void)hygrothermographManagerReturnThresholdTemThreshold:(float)tem humThreshold:(float)hum;

/** 设备返回历史记录数据
 * @param list  : 历史记录列表
 * @param allNumber : 历史记录总数量
 * @param getNumber : 已发数量
 */
- (void)hygrothermographManagerReturnRecordDataList:(NSArray<ELHygrothermographBleRecordData *> *)list allListNumber:(long long)allNumber getListNumber:(long long)getNumber;

/** 返回设备采样频率和保存频率 */
- (void)hygrothermographManagerReturnSamplingFrequency:(NSInteger)sampling saveFrequency:(NSInteger)save timeInterval:(NSInteger)timeInterval;

/** 返回温湿度校准值 */
- (void)hygrothermographManagerReturnCalibrationValueWithTem:(float)tem hum:(float)hum;

/** 返回设备信息 */
- (void)hygrothermographManagerReturnDevType:(enum Hygrothermograph_DevType)type version:(NSString *)version IMEI:(NSString *)IMEI;

/** 返回设备报警功能开关
 * @param highTem : 高温报警值，单位摄氏度
 * @param lowTem : 低温报警值，单位摄氏度
 */
- (void)hygrothermographManagerReturnTemAlarmSwitch:(BOOL)temAlarm
                                       highTemAlarm:(float)highTem
                                        lowTemAlarm:(float)lowTem
                                     humAlarmSwitch:(BOOL)humAlarm
                                       highHumAlarm:(float)highHum
                                        lowHumAlarm:(float)lowHum;

/** 返回wifi/4g例行上报时间 */
- (void)hygrothermographManagerReturnRoutineReportingTime:(int)time;

/** wifi/4g设备返回历史记录数据 */
- (void)hygrothermographManagerWiFiReturnRecordDataList:(NSArray<ELHygrothermographBleRecordData *> *)list allListNumber:(long long)allNumber getListNumber:(long long)getNumber;

/** 返回WiFi网络状态 */
- (void)hygrothermographManagerReturnWiFiConnectStatus:(enum Hygrothermograph_ConnectStateType)connectState
                                            workStatus:(enum Hygrothermograph_WorkStateType)workStatus
                                          failedStatus:(enum Hygrothermograph_FailedType)failedStatus;

/** MCU replies to the result of setting the ip address (MCU回复设置ip地址结果 )
 * @param result : 1：成功，0:失败，2:不支持
 */
- (void)managerCallBackSetIPAddressResult:(NSInteger)result;

/// 返回设备的ip地址
- (void)hygrothermographManagerBackDevIpAddress:(NSString *)ipAddress;



/// 返回蜂鸣器状态
/// @param open 是否打开
- (void)THManagerBuzzerState:(BOOL)open;

/// 设备返回闹钟功能
/// @param state 闹钟状态
/// @param num 1-5(对应5的个闹钟编号)
/// @param mode 模式
/// @param timeStr 时间，格式为 HH:mm:ss
/// @param open 是否激活
- (void)THManagerAlarmLockState:(enum TH_AlarmClockState)state num:(int)num mode:(enum TH_AlarmClockMode)mode timeStr:(NSString *)timeStr open:(BOOL)open;

/// 设备返回整点报时状态
/// @param open 整点报时开关
- (void)THManagerReportPunctuallyState:(BOOL)open;

/// 设备返回小夜灯状态
/// @param open 小夜灯开关
- (void)THManagerNightLightState:(BOOL)open;

/// 设备返回背光状态
/// @param open 背光灯开关
/// @param brightness 亮度，0-100
- (void)THManagerGounrdLightState:(BOOL)open brightness:(int)brightness;

/// 设备返回当前单位
/// @param unit 单位
- (void)THManagerUnitState:(enum ELDeviceTemperatureUnit)unit;

/// 设备返回寻物状态
/// @param alarm 是否正在报警
- (void)THManagerLostState:(BOOL)alarm;

/// 返回支持的功能列表
/// @param list 数组内容为 TH_Dev_SupportFeatures 枚举
- (void)THManagerSuportList:(NSArray<NSNumber *> *)list;

/// 返回清除历史记录结果
/// @param state 只会返回成功，不会返回失败
- (void)THManagerClearRecordState:(BOOL)state;

/// 返回是否支持历史记录
/// @param state 只会返回成功，不会返回失败
- (void)THManagerSupportRecordData:(BOOL)state;


// 返回绑定状态
- (void)THManagerBindingStatus:(Byte)status;

@end

/**
 
 温湿度协议手动传入cid，因为有需要不连接设备发送数据的应用场景，所以不通过peripheralModel获取cid
 
 */


/// 温湿度计蓝牙数据发送
@interface ELHygrothermographBleManager : ELBluetoothManager

@property (nonatomic, weak) id<ELHygrothermographBleDelegate> hygrothermographDelegate;

+ (ELHygrothermographBleManager *)shareManager;

/** 获取设备状态信息 */
- (void)getDevStateWithCid:(enum ELSupportDeviceType)cid;

/** 设置阀值
 * @param tem 区间为 0.1 ～ 10摄氏度 (超过区间就设置为临界值)
 * @param hum 区间为 0.1 ~ 10 %（同上）
 */
- (void)setDevThresholdWithTem:(float)tem hum:(float)hum cid:(enum ELSupportDeviceType)cid;

/** 读取设备历史记录
 * 因为设备保存的历史数据过多，APP 不需每次多获取全部历史。 所以 APP 可以根据自身上一次获取到的开机时间，获取新的历 史数据。 例如：APP 首次连接设备获取数据时，则该值为 0. 如果首次已经获取到了开机时间的 100s 时，再次获取时，该值 应该为 100
 */
- (void)getDevRecordDataWithDevTime:(long long)devTime cid:(enum ELSupportDeviceType)cid;

/** 设置采样频率和保存频率 */
- (void)setSamplingFrequency:(NSInteger)sampling saveFrequency:(NSInteger)save timeInterval:(NSInteger)timeInterval cid:(enum ELSupportDeviceType)cid;


/// 7.4.4 APP设置、读取温湿度校准
/// @param set true:设置(APP下发数据时,两个单位的值都要算好,当设备处于哪个单位时,就使用哪个偏置的值,避免了单位转化导致精度丢失), flase:读取
/// @param cTem （单位:℃  .范围-10.0 到 +10.0 ，默认值0）
/// @param fTem （单位:℉  .范围-10.0 到 +10.0 ，默认值0）
/// @param hum （范围-10.0到 +10.0% ，默认值为0）
- (void)setOrGetTemHumCalibrationValueWithSet:(BOOL)set cTem:(float)cTem fTem:(float)fTem hum:(float)hum cid:(enum ELSupportDeviceType)cid;

/** APP获取设备信息 */
- (void)getDevDataInfoWithCid:(enum ELSupportDeviceType)cid;

/** APP获取设备报警功能 */
- (void)getDevAlarmDataInfoWithCid:(enum ELSupportDeviceType)cid;

/** APP设置报警功能 */
- (void)setDevAlarmDataInfoWithTemAlarmSwitch:(BOOL)temAlarm
                                 highTemAlarm:(float)highTem
                                  lowTemAlarm:(float)lowTem
                               humAlarmSwitch:(BOOL)humAlarm
                                 highHumAlarm:(float)highHum
                                  lowHumAlarm:(float)lowHum
                                          cid:(enum ELSupportDeviceType)cid;

/// 获取设备支持功能
- (void)getDevSupportFeaturesWithCid:(enum ELSupportDeviceType)cid;

/// 设置/读取设备蜂鸣器功能
/// @param set 是否为设置命令，否则读取
/// @param close 是否关闭，默认是打开
- (void)setOrGetBuzzerWithCmd:(BOOL)set close:(BOOL)close cid:(enum ELSupportDeviceType)cid;

/// 设置/读取设备闹钟功能
/// @param state 闹钟状态
/// @param num 1-5(对应5的个闹钟编号)
/// @param mode 模式
/// @param timeStr 时间，格式为 HH:mm:ss
/// @param open 是否激活
- (void)setOrGetAlarmClockWithState:(enum TH_AlarmClockState)state num:(int)num mode:(enum TH_AlarmClockMode)mode timeStr:(NSString *)timeStr open:(BOOL)open cid:(enum ELSupportDeviceType)cid;

/// 设置/读取设备整点报时功能
/// @param set 是否为设置，否则读取
/// @param open 是否打开整点报时，默认关闭
- (void)setOrGetReportPunctuallyWithCmd:(BOOL)set open:(BOOL)open cid:(enum ELSupportDeviceType)cid;

/// 设置/读取设备小夜灯
/// @param set 是否为设置，否则读取
/// @param open 是否打开小夜灯，默认关闭
- (void)setOrGetDevNightLightWithCmd:(BOOL)set open:(BOOL)open cid:(enum ELSupportDeviceType)cid;

/// 设置/读取背光亮度
/// @param set 是否为设置，否则读取
/// @param open 是否打开，默认关闭
/// @param brightness 亮度值0-100
- (void)setOrGetGroundLightWithCmd:(BOOL)set open:(BOOL)open brightness:(int)brightness cid:(enum ELSupportDeviceType)cid;

/// 设置/读取单位
/// @param set 是否为设置，否则读取
/// @param unit 单位
- (void)setOrGetUnitWithCmd:(BOOL)set unit:(ELDeviceTemperatureUnit)unit cid:(enum ELSupportDeviceType)cid;

/// 寻物功能
/// @param start 是否开始寻物
- (void)findingWithCmd:(BOOL)start cid:(enum ELSupportDeviceType)cid;

/// 清除设备历史记录
- (void)clearRecordDataWithCid:(enum ELSupportDeviceType)cid;

/// 查询BM是否支持历史记录
- (void)getSupportRecordDataWithCid:(enum ELSupportDeviceType)cid;

/** app设置设备wifi/4g例行上报时间 */
- (void)setDevRoutineReportingTime:(int)time cid:(enum ELSupportDeviceType)cid;

/** app获取Wi-Fi网络状态 */
- (void)getDevWiFiStatusWithCid:(enum ELSupportDeviceType)cid;

/** 设置设备的IP地址，端口号和访问路径 */
- (void)setDevAccessIpAddress:(NSString *)address portNumber:(NSUInteger)portNum path:(NSString *)path;

/** 获取设备ip地址 */
- (void)getDevAccessIp;

/** 设置Unix时间 */
- (void)setUnixTime:(long long)time;


// App绑定设备 开始
- (void)bindDeviceStart;
// App绑定设备 完成
- (void)bindDeviceDone;

/// 解析A7指令
- (void)processA7Data:(NSData *)rawData withMac:(NSData *)mac withCid:(UInt16)cid;
/// 解析A6指令
- (void)processA6Data:(NSData *)rawData;

/// 生成A7数据包
- (NSData * _Nullable)makePacketA7Payload:(NSData *)payload withMac:(NSData *)mac withCid:(UInt16)cid;
/// 生成A6数据包
- (NSData * _Nullable)makePacketA6Payload:(NSData *)payload;

@end

NS_ASSUME_NONNULL_END
