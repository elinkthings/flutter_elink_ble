//
//  ELEightScaleHistoryRecord.h
//  AILinkBleSDK
//
//  Created by RedmiK90 on 2026/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ELEightScaleMCUAlgorithmHistoryDataModel;
@class ELEightScaleAPPAlgorithmSingleFrequencyHistoryDataModel;
@class ELEightScaleAPPAlgorithmDoubleFrequencyHistoryDataModel;

@interface ELEightScaleHistoryRecord : NSObject

/**mcu算法历史记录数据**/
+ (ELEightScaleMCUAlgorithmHistoryDataModel*)getHistoryRecord:(Byte *)payloadBytes record:(ELEightScaleMCUAlgorithmHistoryDataModel*)historyRecord dataLength:(NSInteger)length;

/**单频App算法历史记录数据**/
+ (ELEightScaleAPPAlgorithmSingleFrequencyHistoryDataModel*)getSingleFrequencyAppAlgorithmHistoryRecord:(Byte *)payloadBytes record:(ELEightScaleAPPAlgorithmSingleFrequencyHistoryDataModel*)historyRecord dataLength:(NSInteger)length;


/**双频App算法历史记录数据**/
+ (ELEightScaleAPPAlgorithmDoubleFrequencyHistoryDataModel*)getDoubleFrequencyAppAlgorithmHistoryRecord:(Byte *)payloadBytes record:(ELEightScaleAPPAlgorithmDoubleFrequencyHistoryDataModel*)historyRecord dataLength:(NSInteger)length;

@end

NS_ASSUME_NONNULL_END
