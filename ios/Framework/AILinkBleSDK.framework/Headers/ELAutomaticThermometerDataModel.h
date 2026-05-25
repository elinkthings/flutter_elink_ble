//
//  ELAutomaticThermometerDataModel.h
//  Elink
//
//

#import <Foundation/Foundation.h>
#import "ELSDKHeader.h"
#import "ELAutomaticThermometerHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELAutomaticThermometerDataModel : NSObject


@property (nonatomic, assign) AutomaticThermometerBleDataType dataType; //0x01:体表温度 0x02:计量温度

@property (nonatomic, assign) UInt16 temperature;//温度
@property (nonatomic, assign) ELDeviceTemperatureUnit unit;//单位  0:℃ 1:℉

@property (nonatomic, assign) NSInteger tempPoint;   //小数点偏移位置 0：无小数点。 N:N 位小数点。

@property (nonatomic, copy, readonly) NSString *temperatureString;


@end


NS_ASSUME_NONNULL_END
