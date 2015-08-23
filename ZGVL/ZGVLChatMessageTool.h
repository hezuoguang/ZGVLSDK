//
//  ZGVLChatMessageTool.h
//  微聊
//
//  Created by weimi on 15/8/17.
//  Copyright (c) 2015年 weimi. All rights reserved.
//  此类用来从服务器获取聊天消息数据的, 获得数据后会发送通知,并将获得的数据

#import <Foundation/Foundation.h>

@interface ZGVLChatMessageTool : NSObject

+ (void)startGetMessage;

@end
