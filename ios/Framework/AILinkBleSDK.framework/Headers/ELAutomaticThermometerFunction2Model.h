//
//  ELAutomaticThermometerFunction2Model.h
//  AILinkBleSDK
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELAutomaticThermometerFunction2Model : NSObject

// 报警值(2bytes ,大端序,精度0.1℃)
@property (nonatomic, assign) UInt16 rawValueAlerm; // 精度 0.1℃ 例如 37.5℃(默认报警值) 则 rawValueAlerm = 0x016D
@property (nonatomic, assign) UInt16 rawMinValueAlerm; // 精度 0.1℃ 例如 37.5 则 rawValueAlerm = 0x016D
@property (nonatomic, assign) UInt16 rawMaxValueAlerm; // 精度 0.1℃ 例如 37.5℃ 则 rawValueAlerm = 0x016D
// 报警值(2bytes ,大端序,精度0.1℉)
@property (nonatomic, assign) UInt16 rawValueAlermFahrenheit; // 精度 0.1℉ 例如 37.5℉ 则 rawValueAlerm = 0x016D

// 体表温度校准
@property (nonatomic, assign) BOOL supportBodyCalibration; // 体表温度校准(YES=支持, NO=不支持)
@property (nonatomic, assign) BOOL negativeBodyCalibration; // 体表温度校准正负号(YES=负温度, NO=正温度)
@property (nonatomic, assign) UInt8 rawValueBodyCalibration; // 体表温度校准值(精度 0.1℃)(默认 0)
@property (nonatomic, copy, readonly) NSString *valueBodyCalibrationString;
@property (nonatomic, assign) BOOL negativeFahrenheitBodyCalibration; // 体表温度校准正负号(YES=负温度, NO=正温度)
@property (nonatomic, assign) UInt8 rawValueFahrenheitBodyCalibration; // 体表温度校准值(精度 0.1℉)(默认 0)
@property (nonatomic, copy, readonly) NSString *valueFahrenheitBodyCalibrationString;

// 计量温度校准
@property (nonatomic, assign) BOOL supportMeasurementCalibration; // 计量温度校准(YES=支持, NO=不支持)
@property (nonatomic, assign) BOOL negativeMeasurementCalibration; // 计量温度校准正负号(YES=负温度, NO=正温度)
@property (nonatomic, assign) UInt8 rawValueMeasurementCalibration; // 计量温度校准值(精度 0.1℃)(默认 0)
@property (nonatomic, copy, readonly) NSString *valueMeasurementCalibrationString;
@property (nonatomic, assign) BOOL negativeFahrenheitMeasurementCalibration; // 计量温度校准正负号(YES=负温度, NO=正温度)
@property (nonatomic, assign) UInt8 rawValueFahrenheitMeasurementCalibration; // 计量温度校准值(精度 0.1℉)(默认 0)
@property (nonatomic, copy, readonly) NSString *valueFahrenheitMeasurementCalibrationString;

// 当前温度单位
@property (nonatomic, assign) UInt8 currentUnit; // 当前温度单位 0=℃.(默认) 1=℉


// 温度值播报开关
@property (nonatomic, assign) BOOL supportTemperatureVoiceSwitch; // 温度值播报开关(YES=支持, NO=不支持)
@property (nonatomic, assign) BOOL valueTemperatureVoiceSwitchEnabled; // 设备当前状态(YES=开启温度值播报(默认) , NO=不开启温度值播报), 当设备支持温度值播报开关时,该状态位有有效

// 报警音效配置
@property (nonatomic, assign) UInt8 supportAlarmSoundEffect; // Bit7: 音效1 Bit6: 音效2 Bi0：支持关闭报警音效
@property (nonatomic, assign) UInt8 valueAlarmSoundEffect;   // 0x80: 音效1 0x40: 音效2 0x01：关闭报警音效
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *soundAlarmEffectList;

// 灵敏度配置
@property (nonatomic, assign) BOOL supportSensibility; // Bit7: 1=支持调节灵敏度.  0=不支持调节灵敏度
@property (nonatomic, assign) UInt8 supportSensibilityGearMax; // Bit5-Bit0:灵敏度档位数量(例如有5档,则对应1-5档)
@property (nonatomic, assign) UInt8 valueSensibility;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *valueSensibilityGearList;

// 自动关机配置
@property (nonatomic, assign) UInt8 supportAutoPowerOff;
@property (nonatomic, assign) UInt8 valueAutoPowerOff;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *autoPowerOffList;


+ (instancetype)defaultModel;

@end

NS_ASSUME_NONNULL_END
