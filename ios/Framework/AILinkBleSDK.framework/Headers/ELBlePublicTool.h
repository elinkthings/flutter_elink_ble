//
//  ELBlePublicTool.h
//  Elink
//
//  Created by iot_user on 2019/5/10.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELBlePublicTool : NSObject
#pragma mark Keep decimal places, support for retaining 7 significant digits（保留小数位，支持保留7位有效数字）
+(NSString *)retainPointValue:(double)value withPoint:(NSUInteger)point;
/**
Turn time into time （将时间转成时间截）
 
 @param timeString time
 @param formatter format
 @return Time cut(时间截)
 */
+ (NSInteger)getTimeStampWithTimeString:(NSString *)timeString AndFormatter:(NSString *)formatter;

/**
 Determine if the WiFi password is legal(判断WiFi密码是否合法)

 @param password wifi password (8 ~ 56 characters)(wifi密码(8~56个字符))
 @return yes: legal, NO: illegal(yes:合法，NO：不合法)
 */
+(BOOL)legalBleWifiPassword:(NSString *)password;
@end

NS_ASSUME_NONNULL_END
