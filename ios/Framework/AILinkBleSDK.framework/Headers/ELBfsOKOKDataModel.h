//
//  ELBfsOKOKDataModel.h
//  Elink
//

#import <Foundation/Foundation.h>
#import "ELBroadcastScaleBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OKOKDevType) {
    /** 体重秤 */
    OKOKDevType_Weight            = 0 ,
    /** 体脂秤 */
    OKOKDevType_Bfr                   ,
};

/** lea one 秤返回的数据对象模型 */
@interface ELBfsOKOKDataModel : NSObject

/** 流水号 */
@property (nonatomic, assign) NSInteger serialNumber;

/** 设备返回的原始体重 */
@property (nonatomic, assign) NSInteger rawWeight;

/** 电阻 */
@property (nonatomic, assign) NSInteger adc;

/** mac地址 */
@property (nonatomic, copy) NSString *mac;

/** 设备类型 */
@property (nonatomic, assign) OKOKDevType devType;

/** 单位 (仅支持 kg，斤，lb和st:lb) */
@property (nonatomic, assign) ELDeviceWeightUnit unit;

/** 小数位 */
@property (nonatomic, assign) NSInteger weightPoint;

/** 是否为锁定数据 */
@property (nonatomic, assign) BOOL isLockData;

+ (instancetype)initWithDevBleData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
