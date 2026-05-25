//
//  ELSkipBleManager.h
//  AILinkBleSDK
//
//  Created by cliCk on 2021/6/16.
//  Copyright © 2021 IOT. All rights reserved.
//

#import <AILinkBleSDK/ELBluetoothManager.h>
#import "ELSkipBleHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class ELSkipBleDataModel;
@class ELSkipHistoryDataModel;

@protocol ELSkipBleDelegate <NSObject>

//@optional

/** 返回设备的连接状态 */
- (void)skipManagerUpdateState:(ELBluetoothState)state;

/** 回调扫描到的设备 */
- (void)skipManagerScanDevices:(NSArray<ELPeripheralModel *> *)scanDevices;

/** 返回命令结果 */
- (void)skipManagerResult:(enum Skip_ResultType)result bleHeaderType:(enum Skip_BleHeadType)type;

/** 实时跳绳数据上报
 * @param readyState : 跳绳状态
 * @param model : 运动数据模型
 * @param power : 当前电量百分比
 */
- (void)skipManagerRealtimeDataWithState:(enum Skip_ReadyStateType)readyState skipModel:(ELSkipBleDataModel *)model power:(NSUInteger)power;

/** 跳绳结束，上报数据
 * @param model : 跳绳记录数据模型
 */
- (void)skipManagerSportEndReportDataWithHistoryModel:(ELSkipHistoryDataModel *)model;

/** 上报离线历史记录
 * @param modelList : 记录模型列表
 */
- (void)skipManagerReportOfflineHistoryWithHistoryModelList:(NSArray<ELSkipHistoryDataModel *> *)modelList;

@end

@interface ELSkipBleManager : ELBluetoothManager

@property (nonatomic, weak) id<ELSkipBleDelegate> skipDelegate;

+ (ELSkipBleManager *)shareManager;

/** 绑定设备，该功能与硬件没有实际的交互用途，只用户处理app绑定设备时的逻辑处理 */
- (void)bindDeviceWithType:(enum Skip_BindDeviceType)type;

/** 同步时间戳 */
- (void)syncDevTimeStamp:(NSInteger)timestamp;

/** 启动/结束自由跳绳 */
- (void)sendFreeModeWithType:(enum Skip_UseDevCommandType)type;

/** 启动/结束倒计时跳绳 */
- (void)sendCountdownTimeModeWithType:(enum Skip_UseDevCommandType)type;
/** 修改默认倒计时 */
- (void)updateCountdownTimeWithNum:(NSUInteger)num;

/** 启动/结束倒计数跳绳 */
- (void)sendCountDownNumWithType:(enum Skip_UseDevCommandType)type;
/** 修改默认倒计数 */
- (void)updateCountdownNumWithNum:(NSUInteger)num;



/** 请求接收离线历史记录 */
- (void)getOfflineHistory;

/** 清空离线历史记录 */
- (void)clearOfflineHistory;

@end

NS_ASSUME_NONNULL_END
