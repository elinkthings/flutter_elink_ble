//
//  ELThermometerBleManager.h
//  Elink
//
//  Created by cliCk on 2019/5/28.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import "ELBluetoothManager.h"
#import "ELThermometerDeviceModel.h"
#import "ELThermometerBleModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , ThermometerBleDataType) {
    
    /**Stable temperature（ 稳定温度 ）*/
    ThermometerBleDataType_StableData           = 0x01 ,
    /** Real-time temperature（实时温度） */
    ThermometerBleDataType_RealtimeData         = 0x02 ,
    
    /// 6.2.2读取历史数据
    ThermometerBleDataType_GetRecordData    = 0x03 ,
    /// 6.2.3返回历史数据
    ThermometerBleDataType_BackRecordData   = 0x04 ,
    
    /// APP获取历史记录
    ThermometerBleDataType_RequestHistoryRecord = 0x10,
    /// 返回历史记录
    ThermometerBleDataType_ReceiveHistoryRecord = 0x11,
    
    /// 6.2.4获取设备支持功能/返回支持功能
    ThermometerBleDataType_SupportFunction   = 0x80 ,
    
    
    /** App release unit settings（app下发单位设置） */
    ThermometerBleDataType_AppSendUnit          = 0x81 ,
    /** The MCU replies to the setting result（MCU回复设置结果） */
    ThermometerBleDataType_BackSendUnit         = 0x82 ,
    
    /// App同步unix时间给MCU
    ThermometerBleDataType_AsyncUnixTime        = 0x83 ,
    
    /// 6.2.7获取设备测温模式/返回测试模式
    ThermometerBleDataType_GetMeasureTemMode       = 0x84 ,
    /// 6.2.8设置设备测温模式/返回设置结果
    ThermometerBleDataType_SetMeasureTemMode       = 0x85 ,
    /// 6.2.9获取高温报警值/返回高温报警值
    ThermometerBleDataType_GetTemAlarmValue       = 0x86 ,
    /// 6.2.10设置高温报警值/返回结果
    ThermometerBleDataType_SetTemAlarmValue       = 0x87 ,
    
    /** Error code sent on the device（设备上发错误码） */
    ThermometerBleDataType_DeviceBackErrorCode  = 0xFF ,
};

typedef NS_ENUM(NSInteger , ThermometerBleResultType) {
    /** success(设置成功 )*/
    ThermometerBleResultType_Succeed            = 0x00 ,
    /** failure(设置失败) */
    ThermometerBleResultType_Failure                   ,
    /** unsupport(不支持设置) */
    ThermometerBleResultType_Unsupported               ,
};

typedef NS_ENUM(NSInteger , ThermometerBleErrorCode) {
    /** Hyperthermia(体温过高) */
    ThermometerBleErrorCode_Hyperthemia         = 0x00 ,
    /** Hypothermia(体温过低 )*/
    ThermometerBleErrorCode_Hypothermia                ,
    /** error(测量出错) */
    ThermometerBleErrorCode_Failure                    ,
};

/// 设备类型
typedef NS_ENUM(NSInteger, ThermometerBleDevType) {
    /// 体温贴等连续测温设备
    ThermometerBleDevType_Continuous = 0 ,
    /// 一般体温计
    ThermometerBleDevType_Normal = 1 ,
    /// 基础体温计
    ThermometerBleDevType_Base = 2 ,
};

/// 设备功能枚举定义
typedef NS_ENUM(NSInteger, ThermometerBleSupportFunction) {
    /// 单次/连续 测温切换
    ThermometerBleSupportFunction_Once_Repeatedly   = 0 ,
    /// 单位切换
    ThermometerBleSupportFunction_Unit              = 1 ,
    /// 设置高温报警值
    ThermometerBleSupportFunction_TemAlarm          = 2 ,
    /// 历史数据
    ThermometerBleSupportFunction_Record            = 3 ,
};

/// 测温模式枚举定义
typedef NS_ENUM(NSInteger, ThermometerBleMeasureTemMode) {
    /// 单次测量
    ThermometerBleMeasureTemMode_Once       = 0x00 ,
    /// 连续测量
    ThermometerBleMeasureTemMode_Repeatedly = 0x01 ,
};

/// 获取历史记录状态定义
typedef NS_ENUM(NSInteger, ThermometerBleRequestHistoryRecordStatus) {
    /// 开始获取历史数据
    ThermometerBleRequestHistoryRecordStatus_Start     = 0x00 ,
    /// 接收到一帧,请发下一帧
    ThermometerBleRequestHistoryRecordStatus_Continous = 0x01 ,
    /// 数据接收完毕
    ThermometerBleRequestHistoryRecordStatus_End       = 0x02 ,
    /// 删除历史记录
    ThermometerBleRequestHistoryRecordStatus_Delete    = 0x03 ,
};

/// 体温计蓝牙代理方法
@protocol ELThermometerBleDelegate <NSObject>

@optional
/** Callback Bluetooth status(回调蓝牙状态) */
- (void)thermometerManagerUpdateState:(ELBluetoothState )state;

/** Call back all thermometer devices(回调所有体温计设备) */
- (void)thermometerManagerScanDevices:(NSArray<ELThermometerDeviceModel *> *)thermometerDevices;

/** Callback temperature data(回调温度数据) */
- (void)thermometerManagerReceiveModel:(ELThermometerBleModel *)model;

/** Return unit setting result(返回单位设置结果) */
- (void)thermometerManagerSetUnitResults:(ThermometerBleResultType )result;

/** Error code sent on the device(设备上发错误码)*/
- (void)thermometerManagerBackDeviceErrorCode:(ThermometerBleErrorCode )code;


/// 返回历史记录数据
/// @param all 历史数据总条数
/// @param nowSend 此次发送的条数
/// @param list 体温计模型列表
- (void)thermometerManagerRecordDataListWithAllNum:(long long)all nowSendNum:(long long)nowSend recordList:(NSArray<ELThermometerBleModel *> *)list;

/// 返回设备支持功能
/// @param type 设备类型
/// @param list 支持功能列表，内容为 ThermometerBleSupportFunction
- (void)thermometerManagerSupportFunctionWithDevType:(enum ThermometerBleDevType)type supportList:(NSArray<NSNumber *> *)list;

/// 返回设备当前单位
/// @param unit 单位
- (void)thermometerManagerDevUnit:(enum ELDeviceTemperatureUnit)unit;

/// 返回当前测温模式
- (void)thermometerManagerMeasureTemMode:(enum ThermometerBleMeasureTemMode)mode;

/// 返回设置测温模式结果
- (void)thermometerManagerSetMeasureTemModeResult:(enum ThermometerBleResultType)result;

/// 返回高温报警值
- (void)thermometerManagerHighTemAlarmValue:(ELThermometerBleModel *)model;

/// 设置高温报警值结果
- (void)thermometerManagerSetHighTemAlarmResult:(enum ThermometerBleResultType)result;

@end

@interface ELThermometerBleManager : ELBluetoothManager


@property (nonatomic,weak) id<ELThermometerBleDelegate> thermometerDelegate;

+ (ELThermometerBleManager *)shareManager;

/// 读取历史数据
/// @param count 一次传输可以接收的记录条数，根据MTU大小及单条记录占用字节数合理配置
/// @param time 已经同步过的最后一条历史数据的Unix时间戳(小端序),未同步过历史数据，发0
- (void)getRecordDataWithMaxCount:(NSInteger)count timeStamp:(long long)time;

/// 获取设备支持功能
- (void)getSupportFunction;

/** App release unit settings(app下发单位设置 )*/
- (void)changeThermometerUnit:(ELDeviceTemperatureUnit)unit;

/// 同步unix时间
- (void)setUnixTime:(long long)unixTime;

/// 同步北京时间
- (void)setBeijingTimeWithYear:(UInt8)year month:(UInt8)month day:(UInt8)day hour:(UInt8)hour minute:(UInt8)minute second:(UInt8)second weekday:(UInt8)weakday;

/// 获取设备当前单位
- (void)getNowUnit;

/// 获取设备测温模式
- (void)getMeasureTemMode;

/// 设置设备测温模式
/// @param mode 模式
- (void)setMeasureTemMode:(enum ThermometerBleMeasureTemMode)mode;

/// 获取高温报警值
- (void)getHighTemAlarmValue;

/// 设置高温报警值
/// @param model 不需要设置时间字段和dataType
- (void)setHighTemAlarmValue:(ELThermometerBleModel *)model;

/// APP 获取历史记录
- (void)getHistoryRecordWithStatus:(ThermometerBleRequestHistoryRecordStatus)status;

@end

NS_ASSUME_NONNULL_END
