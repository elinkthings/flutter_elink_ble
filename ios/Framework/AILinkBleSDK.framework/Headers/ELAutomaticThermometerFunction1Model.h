//
//  ELAutomaticThermometerFunction1Model.h
//  AILinkBleSDK
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ELAutomaticThermometerSupportLanguage) {
    ELAutomaticThermometerSupportLanguage_None               = 0,
    
    ELAutomaticThermometerSupportLanguage_DI                = 1 << 0, // 滴
    ELAutomaticThermometerSupportLanguage_DINGDONG          = 1 << 1, // 叮咚
    ELAutomaticThermometerSupportLanguage_EN                = 1 << 2, // 英语
    ELAutomaticThermometerSupportLanguage_IT                = 1 << 3, // 意大利语
    ELAutomaticThermometerSupportLanguage_HR                = 1 << 4, // 韩语
    ELAutomaticThermometerSupportLanguage_SP                = 1 << 5, // 西班牙语
    ELAutomaticThermometerSupportLanguage_JP                = 1 << 6, // 日语
    ELAutomaticThermometerSupportLanguage_JP1               = 1 << 7, // 日语1
    
    ELAutomaticThermometerSupportLanguage_FR                = 1 << 8, // 法语
    ELAutomaticThermometerSupportLanguage_UI                = 1 << 9, // 越南语
    ELAutomaticThermometerSupportLanguage_CB                = 1 << 10, // 柬埔寨语
    ELAutomaticThermometerSupportLanguage_ML                = 1 << 11, // 马来语
    ELAutomaticThermometerSupportLanguage_RL                = 1 << 12, // 印尼语
    ELAutomaticThermometerSupportLanguage_AR                = 1 << 13, // 阿拉伯语
    ELAutomaticThermometerSupportLanguage_TL                = 1 << 14, // 泰语
    ELAutomaticThermometerSupportLanguage_PL                = 1 << 15, // 波兰语
    
    ELAutomaticThermometerSupportLanguage_CH                = 1 << 16, // 中文
    ELAutomaticThermometerSupportLanguage_CH0               = 1 << 17, // 中文0
    ELAutomaticThermometerSupportLanguage_CH1               = 1 << 18, // 中文1
    ELAutomaticThermometerSupportLanguage_CH2               = 1 << 19, // 中文2
    ELAutomaticThermometerSupportLanguage_CH3               = 1 << 20, // 中文3
    
};

typedef NS_OPTIONS(NSUInteger, ELAutomaticThermometerSupportLanguageExt) {
    ELAutomaticThermometerSupportLanguageExt_None               = 0,
    
};

typedef NS_ENUM(NSUInteger, ELAutomaticThermometerSupportLanguageValue) {
    ELAutomaticThermometerSupportLanguageValue_None               = 0x00,
    
    ELAutomaticThermometerSupportLanguageValue_DI                = 0x01, // 滴
    ELAutomaticThermometerSupportLanguageValue_DINGDONG          = 0x02, // 叮咚
    ELAutomaticThermometerSupportLanguageValue_EN                = 0x03, // 英语
    ELAutomaticThermometerSupportLanguageValue_IT                = 0x04, // 意大利语
    ELAutomaticThermometerSupportLanguageValue_HR                = 0x05, // 韩语
    ELAutomaticThermometerSupportLanguageValue_SP                = 0x06, // 西班牙语
    ELAutomaticThermometerSupportLanguageValue_JP                = 0x07, // 日语
    ELAutomaticThermometerSupportLanguageValue_JP1               = 0x08, // 日语1
    
    ELAutomaticThermometerSupportLanguageValue_FR                = 0x09, // 法语
    ELAutomaticThermometerSupportLanguageValue_UI                = 0x0A, // 越南语
    ELAutomaticThermometerSupportLanguageValue_CB                = 0x0B, // 柬埔寨语
    ELAutomaticThermometerSupportLanguageValue_ML                = 0x0C, // 马来语
    ELAutomaticThermometerSupportLanguageValue_RL                = 0x0D, // 印尼语
    ELAutomaticThermometerSupportLanguageValue_AR                = 0x0E, // 阿拉伯语
    ELAutomaticThermometerSupportLanguageValue_TL                = 0x0F, // 泰语
    ELAutomaticThermometerSupportLanguageValue_PL                = 0x10, // 波兰语
    
    ELAutomaticThermometerSupportLanguageValue_CH                = 0x11, // 中文
    ELAutomaticThermometerSupportLanguageValue_CH0               = 0x12, // 中文0
    ELAutomaticThermometerSupportLanguageValue_CH1               = 0x13, // 中文1
    ELAutomaticThermometerSupportLanguageValue_CH2               = 0x14, // 中文2
    ELAutomaticThermometerSupportLanguageValue_CH3               = 0x15, // 中文3
    
};

typedef NS_OPTIONS(NSUInteger, ELAutomaticThermometerSupportSoundEffect) {
    ELAutomaticThermometerSupportSoundEffect_None               = 0,
    
    ELAutomaticThermometerSupportSoundEffect_Off                 = 1 << 0, // 关闭
    
    ELAutomaticThermometerSupportSoundEffect_DingDong           = 1 << 6, // 叮咚(默认)
    ELAutomaticThermometerSupportSoundEffect_Di                 = 1 << 7, // 嘀
};

typedef NS_OPTIONS(NSUInteger, ELAutomaticThermometerSupportMeasuringDistance) {
    ELAutomaticThermometerSupportMeasuringDistance_NONE               = 0,
    
    ELAutomaticThermometerSupportMeasuringDistance_0_6                = 1 << 0, // 0.6m
    ELAutomaticThermometerSupportMeasuringDistance_0_8                = 1 << 1, // 0.8m
    ELAutomaticThermometerSupportMeasuringDistance_1_0                 = 1 << 2, // 1.0m
    ELAutomaticThermometerSupportMeasuringDistance_1_2                 = 1 << 3, // 1.2m
    ELAutomaticThermometerSupportMeasuringDistance_1_4                 = 1 << 4, // 1.4m
    ELAutomaticThermometerSupportMeasuringDistance_1_6                 = 1 << 5, // 1.6m
    ELAutomaticThermometerSupportMeasuringDistance_1_8                 = 1 << 6, // 1.8m
    ELAutomaticThermometerSupportMeasuringDistance_2_0                 = 1 << 7, // 2.0m
    
};

@interface ELAutomaticThermometerFunction1Model : NSObject

// 音量配置
@property (nonatomic, assign) BOOL supportVol;
@property (nonatomic, assign) BOOL supportVolGear0;
@property (nonatomic, assign) UInt8 supportVolGearMax;
@property (nonatomic, assign) UInt8 valueVol;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *valueVolGearList;
// 语言配置
@property (nonatomic, assign) UInt32 supportLanguage;
@property (nonatomic, assign) UInt32 supportLanguageExt;
@property (nonatomic, assign) UInt32 valueLanguage;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *languageList;
// 音效配置
@property (nonatomic, assign) UInt8 supportSoundEffect; // Bit7: 嘀 Bit6: 叮咚
@property (nonatomic, assign) UInt8 valueSoundEffect;   // 0x80: 嘀 0x40: 叮咚(默认)
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *soundEffectList;
// 上电自动开机
@property (nonatomic, assign) BOOL supportAutoPowerOn;
@property (nonatomic, assign) BOOL valueAutoPowerOnEnabled;
// 测温距离
@property (nonatomic, assign) UInt8 supportMeasuringDistance;
@property (nonatomic, assign) UInt8 valueMeasuringDistance;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *measuringDistanceList;



+ (instancetype)defaultModel;


@end

NS_ASSUME_NONNULL_END
