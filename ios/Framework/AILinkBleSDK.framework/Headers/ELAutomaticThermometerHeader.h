//
//  ELAutomaticThermometerHeader.h
//  AILinkBleSDK
//
//

#ifndef ELAutomaticThermometerHeader_h
#define ELAutomaticThermometerHeader_h


// 设备返回数据 type
typedef NS_ENUM(NSInteger, AutomaticThermometerBleDataType) {
    
    // 体表温度
    AutomaticThermometerBleDataType_BodyTemperature           = 0x01,
    // 计量温度
    AutomaticThermometerBleDataType_MeasurementTemperature    = 0x02,
    // 同步单位设置
    AutomaticThermometerBleDataType_ChangeUnit                = 0x11,
    // 同步音量设置
    AutomaticThermometerBleDataType_ChangeVol                 = 0x13,
    // 同步语言设置
    AutomaticThermometerBleDataType_ChangeLanguage            = 0x15,
    // 同步自动开机
    AutomaticThermometerBleDataType_ChangeAutoPowerOn         = 0x17,
    // 同步测温距离
    AutomaticThermometerBleDataType_ChangeMeasuringDistance   = 0x19,
    // 同步体表校准值
    AutomaticThermometerBleDataType_ChangeBodyCalibrationValue  = 0x1B,
    // 同步计量校准值
    AutomaticThermometerBleDataType_ChangeMeasurementCalibrationValue  = 0x1D,
    // 同步报警值
    AutomaticThermometerBleDataType_ChangeAlarmValue           = 0x1F,
    // 同步音效
    AutomaticThermometerBleDataType_ChangeSoundEffect          = 0x21,
    // 恢复默认值
    AutomaticThermometerBleDataType_ChangeResetDevice          = 0x23,
    // 同步报警音效
    AutomaticThermometerBleDataType_ChangeAlermSoundEffect     = 0x25,
    // 同步温度值播报开关
    AutomaticThermometerBleDataType_ChangeTemperatureVoice     = 0x27,
    // 同步灵敏度设置
    AutomaticThermometerBleDataType_ChangeSensibility          = 0x29,
    // 同步自动关机设置
    AutomaticThermometerBleDataType_ChangeAutoPowerOff         = 0x2B,
    
    
    // 设备支持的功能1
    AutomaticThermometerBleDataType_DeviceFunctions1          = 0x81,
    // 设备支持的功能2
    AutomaticThermometerBleDataType_DeviceFunctions2          = 0x83,
    // 设备支持的功能2扩展
    AutomaticThermometerBleDataType_DeviceFunctions2Ext          = 0x85,
    
    // 设备上发错误码）
    AutomaticThermometerBleDataType_DeviceBackErrorCode       = 0xFF,
};

typedef NS_ENUM(NSInteger , AutomaticThermometerBleResultType) {
    // success(设置成功 )
    AutomaticThermometerBleResultType_Succeed            = 0x00,
    // failure(设置失败)
    AutomaticThermometerBleResultType_Failure            = 0x01,
    // unsupport(不支持设置)
    AutomaticThermometerBleResultType_Unsupported        = 0x02,
};

typedef NS_ENUM(NSInteger , AutomaticThermometerBleErrorCode) {
    // 温度过高(高于 42.0℃显示为 Hi)
    AutomaticThermometerBleErrorCode_HighTemperature        = 0x00,
    // 温度过低(低于 32.0℃显示为 Lo)
    AutomaticThermometerBleErrorCode_LowTemperature         = 0x01,
};


#endif /* ELAutomaticThermometerHeader_h */

