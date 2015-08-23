//
//  ZGVL.m
//  微聊
//
//  Created by weimi on 15/8/16.
//  Copyright (c) 2015年 weimi. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ZGVL.h"
#import "ZGVLTool.h"
#import "ZGVLHttpTool.h"
#import "MJExtension.h"
#import "ZGVLConst.h"
#import "ZGVLDBTool.h"
#import "ZGVLChatMessageTool.h"

@implementation ZGVL

/**
 *  启动自动获取消息模块,不手动启动的话无法获得新的chatMessage数据
 */
+ (void)start {
    [ZGVLChatMessageTool startGetMessage];
}


+ (void)dowithRequest:(NSString *)url parameters:(id)parameters success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    [ZGVLHttpTool POST:url parameters:parameters success:^(NSDictionary *response) {
        if (response[@"error"]) {//请求出现错误
            //懒得写错误代码, 只能这么笨拙的比较了
            if([response[@"error"][@"message"] isEqualToString:@"登录失效, 请重新登录"]) {
                //发送  登录失效通知
                [[NSNotificationCenter defaultCenter] postNotificationName:ZGVLNeedRestartLoginNotification object:nil];
            }
            if (failure) {
                failure(response);
            }
        } else {//请求成功
            if(response[@"user"][@"access_token"]) {
                [ZGVLTool saveAccess_token:response[@"user"][@"access_token"] uid:response[@"user"][@"uid"]];
            }
            if (success) {
                success(response);
            }
        }
    } failure:^(NSError *zgerror) {
        if (error) {
            error(zgerror);
        }
    }];
}

/**
 *  是否需要登录
 *
 *  @return YES -- 需要  NO --不需要
 */
+ (BOOL)zg_needLogin {
    if ([ZGVLTool access_token]) {
        return NO;
    }
    return YES;
}

/**
 *  登录
 *
 *  @param uid     用户名
 *  @param pwd     密码
 *  @param success 登录成功时调用
 *  @param failure 登录失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_login:(NSString *)uid pwd:(NSString *)pwd success:(void (^)(ZGBaseUserInfo *userinfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"uid"] = uid;
    parameters[@"pwd"] = pwd;
    NSString *url = [HOST stringByAppendingPathComponent:@"api/login.json"];
    
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        ZGBaseUserInfo *user = [ZGBaseUserInfo objectWithKeyValues:response[@"user"]];
        if (success) {
            success(user);
        }
    } failure:failure error:error];
    
}
/**
 *  注册
 *
 *  @param uid     用户名
 *  @param pwd     密码
 *  @param success 注册成功时调用
 *  @param failure 注册失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_register:(NSString *)uid pwd:(NSString *)pwd success:(void (^)(NSDictionary *))success failure:(void (^)(NSDictionary *))failure error:(void (^)(NSError *))error {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"uid"] = uid;
    parameters[@"pwd"] = pwd;
    NSString *url = [HOST stringByAppendingPathComponent:@"api/register.json"];
    
    [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
}

/**
 *  发送一条消息
 *
 *  @param message ZGChatMessage模型
 *  @param chatMessage 发送成功时调用
 *  @param failure 发送失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_sendChatMessage:(ZGChatMessage *)message success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    /*text - 消息内容(文字消息为:消息内容; gif表情消息为:gif表情对应的图片名称;语音,图片消息为:资源的url)
    type - 消息类型(0, "文本消息"),(1, "gif表情消息"),(2, "图片消息"),(3, "语音消息")
    access_token - 授权标识(登录时成功时可以得到)
    to_user - 接收者uid*/
    parameters[@"to_user"] = message.to_user;
    parameters[@"access_token"] = [ZGVLTool access_token];
    parameters[@"type"] = [NSString stringWithFormat:@"%d", message.type];
    
    
    NSString *url = [HOST stringByAppendingPathComponent:@"api/chat/upload.json"];
    if (message.type == ZGChatMessageTypeImage || message.type == ZGChatMessageTypeVoice) {//语音或者图片消息,  先获得资源的url
        NSString *fileName = [NSString stringWithFormat:@"%@%lf", message.to_user, [[NSDate date] timeIntervalSince1970]];
        [ZGVLTool urlStringWithData:message.data fileName:fileName success:^(NSString *fileurl) {
            parameters[@"text"] = fileurl;
            [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
            
        } error:^(NSError *uploaderror) {
            if (error) {
                error(uploaderror);
            }
        }];
    } else {
        parameters[@"text"] = message.text;
        [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
    }
    
}

/**
 *  主动从本地获取消息id大于since_id且是与to_user对话的消息,最多20条
 *
 *  @param since_id
 *  @param to_user
 */

+ (NSArray *)zg_newChatMessages:(NSUInteger)since_id to_user:(NSString *)to_user {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"to_user"] = to_user;
    if (since_id > 0) {
        parameters[@"since_id"] = @(since_id);
    }
    return [ZGVLDBTool queryChatMessage:parameters];
}

/**
 *  主动从本地获取消息id小与max_id且是与to_user对话的消息,最多20条
 *
 *  @param max_id
 *  @param to_user
 */
+ (NSArray *)zg_oldChatMessages:(NSUInteger)max_id to_user:(NSString *)to_user {
    NSDictionary *parameters = @{
                                 @"max_id" : @(max_id),
                                 @"to_user" : to_user
                           };
    NSArray *array = [ZGVLDBTool queryChatMessage:parameters];
    if (array.count < 20) {
        [ZGVLChatMessageTool startGetMessage];
    }
    return array;
}

/**
 *  发送一条状态
 *
 *  @param message ZGStatus模型
 *  @param success 发送成功时调用
 *  @param failure 发送失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_sendStatus:(ZGStatus *)status success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    text - 状态内容
//    pics - 状态配图地址,数组 最多为9
//    access_token - 授权标识
    parameters[@"access_token"] = [ZGVLTool access_token];
    parameters[@"text"] = status.text;
    //parameters[@"pics[]"] = [NSMutableArray array];
    NSString *url = [HOST stringByAppendingPathComponent:@"api/status/upload.json"];
    NSInteger count = status.pics.count;
    if (count) {
        UIImage *image = status.pics.firstObject;
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSString *fileName = [NSString stringWithFormat:@"%@%lf", [ZGVLTool uid], [[NSDate date] timeIntervalSince1970]];
        [ZGVLTool urlStringWithData:data fileName:fileName success:^(NSString *fileUrl) {
            //[parameters[@"pics[]"] addObject:fileUrl];
            parameters[@"pics[]"] = fileUrl;
            [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
        } error:^(NSError *reerror) {
            if (error) {
                error(reerror);
            }
        }];
    } else {
        [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
    }
}

/**
 *  获取id > since_id 的状态数据
 *
 *  @param since_id
 *  @param success 发送成功时调用
 *  @param failure 发送失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_newStatus:(NSUInteger)since_id success:(void (^)(NSArray *statuses))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSArray *statuses = nil;
    //先从本地数据库查
    if (since_id <= 0) {//查最新的
        statuses = [ZGVLDBTool queryStatus:nil];
    } else {
        statuses = [ZGVLDBTool queryStatus:@{@"since_id" : @(since_id)}];
    }
    if (statuses.count) {
        if (success) {
            success(statuses);
        }
        return;
    }
    NSDictionary *parameters = @{
                                 @"since_id" : @(since_id),
                                 @"access_token" : [ZGVLTool access_token]
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/status/newstatuses.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        NSArray *statuses1 = response[@"statuses"];
        [ZGVLDBTool saveStatusWithArray:statuses1];
        if (success) {
            success(statuses1);
        }
    } failure:failure error:error];
}

/**
 *  获取id < max_id 的状态数据
 *
 *  @param max_id
 *  @param success 发送成功时调用
 *  @param failure 发送失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_oldStatus:(NSUInteger)max_id success:(void (^)(NSArray *statuses))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSArray *statuses = nil;
    //先从本地数据库查
    if (max_id <= 0) {//查最新的
        statuses = [ZGVLDBTool queryStatus:nil];
    } else {
        statuses = [ZGVLDBTool queryStatus:@{@"max_id" : @(max_id)}];
    }
    if (statuses.count) {
        if (success) {
            success(statuses);
        }
        return;
    }
    NSDictionary *parameters = @{
                                 @"max_id" : @(max_id),
                                 @"access_token" : [ZGVLTool access_token]
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/status/oldstatuses.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        NSArray *statuses1 = response[@"statuses"];
        [ZGVLDBTool saveStatusWithArray:statuses1];
        if (success) {
            success(statuses1);
        }
    } failure:failure error:error];
}
/**
 *  发送一条评论
 *
 *  @param comment ZGStatusComment模型
 *  @param success 发送成功时调用
 *  @param failure 发送失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_sendStatusComment:(ZGStatusComment *)comment success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"text" : comment.text,
                                 @"s_id" : @(comment.s_id),
                                 @"access_token" : [ZGVLTool access_token]
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/comment/upload.json"];
    [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
}

/**
 *  获取一条状态的所有评论
 *
 *  @param s_id    status 的 id
 *  @param success 发送成功时调用
 *  @param failure 发送失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_getStatusComments:(NSUInteger)s_id success:(void (^)(NSArray *comments))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"s_id" : @(s_id)
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/comment/comments.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            NSArray *comments = response[@"comments"];
            [ZGVLDBTool updateStatusCommentCount:s_id count:comments.count];
            success(comments);
        }
    } failure:failure error:error];
}

/**
 *  发送好友请求
 *
 *  @param text    请求说明
 *  @param to_user 被请求的用户uid
 *  @param success 登录成功时调用
 *  @param failure 登录失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_sendAddFriendMessage:(NSString *)text to_user:(NSString *)to_user success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"text" : text,
                                 @"access_token" : [ZGVLTool access_token],
                                 @"to_user" : to_user
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/friend/addfriend.json"];
    [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
}

/**
 *  处理一个好友请求
 *
 *  @param f_id    好友请求消息id
 *  @param result  (处理结果)(1, "拒绝"),(2, "同意")
 *  @param success 登录成功时调用
 *  @param failure 登录失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_dowithAddFriendRequest:(NSUInteger)f_id result:(NSUInteger)result success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"f_id" : @(f_id),
                                 @"access_token" : [ZGVLTool access_token],
                                 @"result" : @(result)
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/friend/dowithrequest.json"];
    [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
}

/**
 *  删除一个好友
 *
 *  @param to_user 欲删除的好友uid
 *  @param success 登录成功时调用
 *  @param failure 登录失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_deleteFriend:(NSString *)to_user success:(void (^)(NSDictionary *response))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"to_user" : to_user,
                                 @"access_token" : [ZGVLTool access_token],
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/friend/deletefriend.json"];
    [self dowithRequest:url parameters:parameters success:success failure:failure error:error];
}

/**
 *  获取所有未处理的好友请求
 *
 *  @param success 发送成功时调用
 *  @param failure 发送失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_getNewFriendRequests:(void (^)(NSArray *newFriends))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"access_token" : [ZGVLTool access_token],
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/friend/newfriends.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            NSArray *newFriends = response[@"newfriends"];
            success(newFriends);
        }
    } failure:failure error:error];
}

/**
 *  获取好友列表
 *
 *  @param success 发送成功时调用
 *  @param failure 发送失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_getFriendList:(void (^)(NSArray *friendlist))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"access_token" : [ZGVLTool access_token],
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/friend/friendlist.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            NSArray *friendlist = response[@"friendlist"];
            success(friendlist);
        }
    } failure:failure error:error];
}

/**
 *  搜索陌生人
 *
 *  @param key     搜索关键词
 *  @param page    分页
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_searchUsers:(NSString *)key page:(NSUInteger)page success:(void (^)(NSArray *users))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"key" : key,
                                 @"page" : @(page),
                                 @"access_token" : [ZGVLTool access_token]
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/friend/search.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            NSArray *users = response[@"users"];
            success(users);
        }
    } failure:failure error:error];
}

/**
 *  获取用户详细信息
 *
 *  @param uid     用户名
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_getUserInfo:(NSString *)uid success:(void (^)(ZGUserInfo *userInfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"uid" : uid,
                                 @"access_token" : [ZGVLTool access_token]
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/user/userinfo.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            NSDictionary *userInfoDict = response[@"user"];
            ZGUserInfo *userInfo = [ZGUserInfo objectWithKeyValues:userInfoDict];
            success(userInfo);
        }
    } failure:failure error:error];
}

/**
 *  更新用户信息
 *
 *  @param newUserInfo  只需设置(name - 昵称 age - 年龄 sex - 性别 birthday - 生日 city - 城市)
 *  @param success      处理成功时调用
 *  @param failure      处理失败时调用
 *  @param error        请求错误时调用
 */
+ (void)zg_updateUserInfo:(ZGUserInfo *)newUserInfo success:(void (^)(ZGUserInfo *userInfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"age"] = @(newUserInfo.age);
    parameters[@"name"] = newUserInfo.name;
    parameters[@"sex"] = newUserInfo.sex;
    parameters[@"birthday"] = newUserInfo.birthday;
    parameters[@"city"] = newUserInfo.city;
    parameters[@"access_token"] = [ZGVLTool access_token];
    NSString *url = [HOST stringByAppendingPathComponent:@"api/user/updateuserinfo.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            NSDictionary *userInfoDict = response[@"user"];
            ZGUserInfo *userInfo = [ZGUserInfo objectWithKeyValues:userInfoDict];
            success(userInfo);
        }
    } failure:failure error:error];
}

/**
 *  更新用户密码
 *
 *  @param pwd     新密码
 *  @param oldPwd  旧密码
 *  @param success      处理成功时调用
 *  @param failure      处理失败时调用
 *  @param error        请求错误时调用
 */
+ (void)zg_updateUserPwd:(NSString *)pwd oldPwd:(NSString *)oldPwd success:(void (^)(ZGUserInfo *userInfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSDictionary *parameters = @{
                                 @"pwd" : pwd,
                                 @"oldpwd" : oldPwd,
                                 @"access_token" : [ZGVLTool access_token]
                                 };
    NSString *url = [HOST stringByAppendingPathComponent:@"api/user/updateuserpwd.json"];
    [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            NSDictionary *userInfoDict = response[@"user"];
            ZGUserInfo *userInfo = [ZGUserInfo objectWithKeyValues:userInfoDict];
            success(userInfo);
        }
    } failure:failure error:error];
}

/**
 *  更新用户头像
 *
 *  @param photo   头像
 *  @param success 处理成功时调用
 *  @param failure 处理失败时调用
 *  @param error   请求错误时调用
 */
+ (void)zg_updateUserPhoto:(UIImage *)photo success:(void (^)(ZGUserInfo *userInfo))success failure:(void (^)(NSDictionary *reason))failure error:(void (^)(NSError *error))error {
    NSData *data = UIImageJPEGRepresentation(photo, 1.0);
    NSString *fileName = [NSString stringWithFormat:@"%@%lf", [ZGVLTool uid], [[NSDate date] timeIntervalSince1970]];
    [ZGVLTool urlStringWithData:data fileName:fileName success:^(NSString *fileurl) {
        NSDictionary *parameters = @{
                                     @"photo" : fileurl,
                                     @"access_token" : [ZGVLTool access_token]
                                     };
        NSString *url = [HOST stringByAppendingPathComponent:@"api/user/updateuserphoto.json"];
        [self dowithRequest:url parameters:parameters success:^(NSDictionary *response) {
            if (success) {
                NSDictionary *userInfoDict = response[@"user"];
                ZGUserInfo *userInfo = [ZGUserInfo objectWithKeyValues:userInfoDict];
                success(userInfo);
            }
        } failure:failure error:error];
    } error:error];
}
@end
