//
//  ZGVLDBTool.h
//  微聊
//
//  Created by weimi on 15/8/17.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGVLDBTool : NSObject

+ (NSString *)messageSince_id;
+ (NSString *)messageMax_id;
+ (NSString *)statusSince_id;
+ (NSString *)statusMax_id;

+ (void)saveChatMessageWithDict:(NSDictionary *)message;
+ (void)saveChatMessageWithArray:(NSArray *)messages;

+ (void)saveStatusWithDict:(NSDictionary *)status;
+ (void)saveStatusWithArray:(NSArray *)statuses;
/**
 *  获取chatMessage数据
 *
 *  @param parameters 查询参数 since_id, max_id 可以不传(默认为最新的), to_user 必传
 *
 *  @return chatMessage 字典 最多20条
 */
+ (NSArray *)queryChatMessage:(NSDictionary *)parameters;
/**
 *  获取status数据
 *
 *  @param parameters 查询参数 since_id, max_id 可以不传(默认为最新的)
 *
 *  @return status 字典 最多20条
 */
+ (NSArray *)queryStatus:(NSDictionary *)parameters;
/**
 *  更新status的评论数
 *
 *  @param s_id  status id
 *  @param count 评论数
 */
+ (void)updateStatusCommentCount:(NSUInteger)s_id count:(NSUInteger)count;

@end
