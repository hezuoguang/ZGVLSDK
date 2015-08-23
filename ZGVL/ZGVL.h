//
//  ZGVL.h
//  微聊
//
//  Created by weimi on 15/8/16.
//  Copyright (c) 2015年 weimi. All rights reserved.
//  本SDK中的所有模型都是简易模型, 只是为了准确的传递数据

#import <Foundation/Foundation.h>
#import "ZGChatMessage.h"
#import "ZGStatus.h"
#import "ZGUserInfo.h"
#import "ZGBaseUserInfo.h"
#import "ZGStatusComment.h"
#import "ZGVLNotificationConst.h"
@interface ZGVL : NSObject
/**
 *  启动自动获取消息模块,不手动启动的话无法获得新的chatMessage数据,, 收到新消息时会发送"ZGVLReceivedNewChatMessageNotification"通知
 */
+ (void)start;

/**
 *  是否需要登录
 *
 *  @return YES -- 需要  NO --不需要
 */
+ (BOOL)zg_needLogin;

/**
 *  登录
 *
 *  @param uid     用户名
 *  @param pwd     密码
 *  @param success 登录成功时调用
 *  @param failure 登录失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_login:(NSString *)uid pwd:(NSString *)pwd success:(void (^)(ZGBaseUserInfo *userinfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;
/**
 *  注册
 *
 *  @param uid     用户名
 *  @param pwd     密码
 *  @param success 注册成功时调用
 *  @param failure 注册失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_register:(NSString *)uid pwd:(NSString *)pwd success:(void (^)(NSDictionary *success))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  发送一条消息
 *
 *  @param message ZGChatMessage模型
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_sendChatMessage:(ZGChatMessage *)message success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  主动从本地获取消息id大于since_id且是与to_user对话的消息,最多20条
 *
 *  @param since_id (为零默认获取最新数据)
 *  @param to_user
 */
+ (NSArray *)zg_newChatMessages:(NSUInteger)since_id to_user:(NSString *)to_user;

/**
 *  主动从本地获取消息id小与max_id且是与to_user对话的消息,最多20条
 *
 *  @param max_id
 *  @param to_user
 */
+ (NSArray *)zg_oldChatMessages:(NSUInteger)max_id to_user:(NSString *)to_user;

/**
 *  发送一条状态
 *
 *  @param message ZGStatus模型
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_sendStatus:(ZGStatus *)status success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;


/**
 *  获取id > since_id 的状态数据
 *
 *  @param since_id
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_newStatus:(NSUInteger)since_id success:(void (^)(NSArray *statuses))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  获取id < max_id 的状态数据
 *
 *  @param max_id
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_oldStatus:(NSUInteger)max_id success:(void (^)(NSArray *statuses))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;
/**
 *  发送一条评论
 *
 *  @param comment ZGStatusComment模型
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_sendStatusComment:(ZGStatusComment *)comment success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  获取一条状态的所有评论
 *
 *  @param s_id    status 的 id
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_getStatusComments:(NSUInteger)s_id success:(void (^)(NSArray *comments))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  发送好友请求
 *
 *  @param text    请求说明
 *  @param to_user 被请求的用户uid
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_sendAddFriendMessage:(NSString *)text to_user:(NSString *)to_user success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  处理一个好友请求
 *
 *  @param f_id    好友请求消息id
 *  @param result  (处理结果)(1, "拒绝"),(2, "同意")
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_dowithAddFriendRequest:(NSUInteger)f_id result:(NSUInteger)result success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  删除一个好友
 *
 *  @param to_user 欲删除的好友uid
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_deleteFriend:(NSString *)to_user success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  获取所有未处理的好友请求
 *
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_getNewFriendRequests:(void (^)(NSArray *newFriends))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  获取好友列表
 *
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_getFriendList:(void (^)(NSArray *friendlist))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  搜索陌生人
 *
 *  @param key     搜索关键词
 *  @param page    分页
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_searchUsers:(NSString *)key page:(NSUInteger)page success:(void (^)(NSArray *users))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;


/**
 *  获取用户详细信息
 *
 *  @param uid     用户名
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_getUserInfo:(NSString *)uid success:(void (^)(ZGUserInfo *userInfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  更新用户信息
 *
 *  @param newUserInfo  只需设置(name - 昵称 age - 年龄 sex - 性别 birthday - 生日 city - 城市)
 *  @param success      处理成功时调用
 *  @param failure      处理失败时调用
 *  @param error        请求错误时调用
 */
+ (void)zg_updateUserInfo:(ZGUserInfo *)newUserInfo success:(void (^)(ZGUserInfo *userInfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

/**
 *  更新用户密码
 *
 *  @param pwd     新密码
 *  @param oldPwd  旧密码
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_updateUserPwd:(NSString *)pwd oldPwd:(NSString *)oldPwd success:(void (^)(ZGUserInfo *userInfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;
/**
 *  更新用户头像
 *
 *  @param photo   头像
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_updateUserPhoto:(UIImage *)photo success:(void (^)(ZGUserInfo *userInfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error;

@end
