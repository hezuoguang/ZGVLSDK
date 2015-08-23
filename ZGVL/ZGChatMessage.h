//
//  ZGChatMessage.h
//  微聊
//
//  Created by weimi on 15/8/16.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ZGChatMessageTypeText = 0,//文本信息
    ZGChatMessageTypeGifEmotion = 1,//表情信息
    ZGChatMessageTypeImage = 2,//图片信息
    ZGChatMessageTypeVoice = 4,//语音信息
}ZGChatMessageType;

@interface ZGChatMessage : NSObject

/**
*  消息内容(文字消息为:消息内容; gif表情消息为:gif表情对应的图片名称;其他消息无需设置,但需要设置data属性)
*/
@property (nonatomic, copy) NSString *text;
/**
 *  图片或者语音消息的数据
 */
@property (nonatomic, strong) NSData *data;
/**
 *  接收者uid
 */
@property (nonatomic, copy) NSString *to_user;

/**
 *  发送者uid, 发送一条消息时无需设置
 */
@property (nonatomic, copy) NSString *from_user;

/**
 *  消息类型
 */
@property (nonatomic, assign) ZGChatMessageType type;


@end
