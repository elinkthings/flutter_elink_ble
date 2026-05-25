//
//  ELRemoteControlBleHeader.h
//  Elink
//
//  Created by iot_user on 2019/8/22.
//  Copyright © 2019 iot_iMac. All rights reserved.
//

#ifndef ELRemoteControlBleHeader_h
#define ELRemoteControlBleHeader_h
/** 遥控器按钮类型 */
typedef NS_ENUM(NSInteger ,RemoteControlType) {
    /** K */
    RemoteControlType_K_0_05                   = 0 ,
    /** 字母0.1 到 1.2 */
    RemoteControlType_Letter_0_1                   ,//1
    RemoteControlType_Letter_0_2                   ,
    RemoteControlType_Letter_0_5                   ,
    RemoteControlType_Letter_0_8                   ,
    RemoteControlType_Letter_1_2                   ,
    
    /** 时钟图形 */
    RemoteControlType_Clock                        ,
    /** 对称的方块 */
    RemoteControlType_SymmetryBox                  ,
    
    RemoteControlType_E_0_1                        ,
    RemoteControlType_E_0_3                        ,
    RemoteControlType_E_0_6                        ,
    RemoteControlType_E_1_0                        ,
    
    /** 数字0.1到1.0 */
    RemoteControlType_Number_0_1                   ,
    RemoteControlType_Number_0_3                   ,
    RemoteControlType_Number_0_6                   ,
    RemoteControlType_Number_1_0                   ,
    
    /** 动植物0.1到0.7 */
    RemoteControlType_Pattern_0_1                  ,//16
    RemoteControlType_Pattern_0_2                  ,
    RemoteControlType_Pattern_0_4                  ,
    RemoteControlType_Pattern_0_7                  ,
    /** 黑色的散点 */
    RemoteControlType_BlackDots                    ,
    /** 多个圆弧 */
    RemoteControlType_CircularArc                  ,
    /** 3956 */
    RemoteControlType_3956                         ,
    /** 上下为空的方块 */
    RemoteControlType_UpDownEmpty                  ,
    /** 左右为空的方块 */
    RemoteControlType_LeftRightEmpty               ,
    /** 黑色的点 */
    RemoteControlType_BlockDot                     ,
    /** 空心的准星 */
    RemoteControlType_HollowSightBead              ,
    /** 准星 */
    RemoteControlType_SightBead                    ,
    
    RemoteControlType_UpProgram                    ,
    RemoteControlType_DownProgram                  ,
    
    RemoteControlType_8_3                          ,//30
    RemoteControlType_8_4                          ,
    
    /** 显示水平 */
    RemoteControlType_HorizontalLine               ,
    /** 显示垂直 */
    RemoteControlType_VerticalLine                 ,
    /** 显示单个 */
    RemoteControlType_Point                        ,
    RemoteControlType_Reset                        ,
    
    RemoteControlType_Light                        ,
    RemoteControlType_Right                        ,
    RemoteControlType_Mute                         ,//38
    
    /** 上下左右 */
    RemoteControlType_TouchTop                     ,
    RemoteControlType_TouchLeft                    ,
    RemoteControlType_TouchRight                   ,
    RemoteControlType_TouchBottom                  ,
};

#endif /* ELRemoteControlBleHeader_h */
