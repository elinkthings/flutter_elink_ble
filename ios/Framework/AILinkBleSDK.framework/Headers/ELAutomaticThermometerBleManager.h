//
//  ELAutomaticThermometerBleManager.h
//  Elink
//
//

#import "ELBluetoothManager.h"
#import "ELAutomaticThermometerDataModel.h"
#import "ELAutomaticThermometerHeader.h"
#import "ELAutomaticThermometerFunction1Model.h"
#import "ELAutomaticThermometerFunction2Model.h"


NS_ASSUME_NONNULL_BEGIN

@protocol ELAutomaticThermometerBleDelegate;



@interface ELAutomaticThermometerBleManager : ELBluetoothManager


@property (nonatomic,weak) id<ELAutomaticThermometerBleDelegate> automaticThermometerDelegate;

+ (ELAutomaticThermometerBleManager *)shareManager;


// APP 获取设备支持的功能
- (void)sendCmdQuerryDeviceFunctions1;
- (void)sendCmdQuerryDeviceFunctions2;
- (void)sendCmdQuerryDeviceFunctions2Ext;
// 同步单位设置
- (void)sendCmdChangeUnit:(ELDeviceTemperatureUnit)unit;
// 同步音量设置
- (void)sendCmdChangeVol:(UInt8)vol;
// 同步语言设置
- (void)sendCmdChangeLanguage:(UInt8)language;
// 同步自动开机
- (void)sendCmdChangeAutoPowerOnEnabled:(BOOL)enabled;
// 同步测温距离
- (void)sendCmdChangeMeasuringDistance:(UInt8)distance;
// 同步体表校准值
//- (void)sendCmdChangeBodyCalibrationValue:(UInt8)value;
- (void)sendCmdChangeBodyCalibrationAdd;
- (void)sendCmdChangeBodyCalibrationSub;
// 同步计量校准值
//- (void)sendCmdChangeMeasurementCalibrationValue:(UInt8)value;
- (void)sendCmdChangeMeasurementCalibrationAdd;
- (void)sendCmdChangeMeasurementCalibrationSub;
// 同步报警值
//- (void)sendCmdChangeAlarmValue:(UInt16)value;
- (void)sendCmdChangeAlarmValueCelsius:(NSInteger)valueCelsius valueFahrenheit:(NSInteger)valueFahrenheit;
// 同步音效
- (void)sendCmdChangeSoundEffect:(UInt8)effect;
// 同步报警音效
- (void)sendCmdChangeAlarmSoundEffect:(UInt8)effect;
//同步温度值播报开关
- (void)sendCmdChangeTemperatureVoiceSwitchEnabled:(BOOL)enabled;
//同步灵敏度设置
- (void)sendCmdChangeSensibility:(UInt8)value;
//同步自动关机设置
- (void)sendCmdChangeAutoPowerOff:(UInt8)value;
// 恢复默认值
- (void)sendCmdResetDevice;

@end

@interface ELAutomaticThermometerBleManager ()

- (void)autoScan;
- (void)stopAutoScan;
- (void)checkStatus;

@end


@protocol ELAutomaticThermometerBleDelegate <NSObject>

@optional
// 回调蓝牙状态)
- (void)automaticThermometerManagerUpdateState:(ELBluetoothState)state;

// 回调所有体温计设备
- (void)automaticThermometerManagerScanDevices:(NSArray<ELPeripheralModel *> *)devices;

//正在连接中倒计时
- (void)deviceBleCountDown:(NSInteger)count;

//ble version
//- (void)firmwareVersion:(NSString *)version;



// 设备上发温度数据
- (void)automaticThermometerManagerReceiveData:(ELAutomaticThermometerDataModel *)model;

// 设备上发支持的功能
- (void)automaticThermometerManagerDeviceFunctions1:(ELAutomaticThermometerFunction1Model *)functions;
- (void)automaticThermometerManagerDeviceFunctions2:(ELAutomaticThermometerFunction2Model *)functions;
- (void)automaticThermometerManagerDeviceFunctions2Ext:(ELAutomaticThermometerFunction2Model *)functions;

// 设备上发同步设置
//- (void)automaticThermometerManagerChangeOptions:(NSData *)data;
- (void)automaticThermometerManagerChangeOptionsType:(AutomaticThermometerBleDataType)type value:(NSInteger)value success:(BOOL)success;
- (void)automaticThermometerManagerChangeOptionsType:(AutomaticThermometerBleDataType)type valueCelsius:(NSInteger)valueCelsius valueFahrenheit:(NSInteger)valueFahrenheit success:(BOOL)success;

// 设备上发错误码
- (void)automaticThermometerManagerBackDeviceErrorCode:(AutomaticThermometerBleErrorCode)code;


@end

NS_ASSUME_NONNULL_END
