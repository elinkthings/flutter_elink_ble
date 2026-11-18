//
//  ELEightScaleBadyInfo.h
//  AILinkBleSDK
//
//  Created by RedmiK90 on 2026/10/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ELEightScaleBleDataModel;
@class ELPeripheralModel;

typedef void (^ELEightScaleBadySuccessBlock)(NSDictionary *data);
typedef void (^ELEightScaleBadyFailureBlock)(id error);

@interface ELEightScaleBadyInfo : NSObject

/// 双频八电极，请求后台算法。成功时返回 data 字典，由外部再转成记录模型
+ (void)getDoubleEightDataWithBleDataModel:(ELEightScaleBleDataModel *)dataModel
                                peripheral:(ELPeripheralModel *)peripheral
                               withUserSex:(NSInteger)sex
                                    height:(NSInteger)height
                                       age:(NSInteger)age
                                   success:(ELEightScaleBadySuccessBlock)success
                                   failure:(ELEightScaleBadyFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
