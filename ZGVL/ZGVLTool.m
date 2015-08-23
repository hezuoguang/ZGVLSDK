//
//  ZGVLTool.m
//  微聊
//
//  Created by weimi on 15/8/16.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import "ZGVLTool.h"
#import "QiniuSDK.h"
#import "ZGVLHttpTool.h"
#import "ZGVLConst.h"
static NSString *_access_token = nil;
static NSString *_uid = nil;
@implementation ZGVLTool
/**
 *  获得上传凭证
 *
 *  @param fileName 文件名
 *  @param complete 完成调用
 */
+ (void)uploadToken:(NSString *)fileName complete:(void (^)(NSString *token, NSError *tokenerror)) complete{
    NSString *url = [HOST stringByAppendingPathComponent:@"api/qiniu/token.json"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"fileName"] = fileName;
    [ZGVLHttpTool POST:url parameters:parameters success:^(NSDictionary *response) {
        if (complete) {
            complete(response[@"token"], nil);
        }
        
    } failure:^(NSError *zgerror) {
        if (complete) {
            complete(nil, zgerror);
        }
    }];
}

/**
 *  保存access_token uid
 */
+ (void)saveAccess_token:(NSString *)access_token uid:(NSString *)uid{
    [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _access_token = access_token;
    _uid = uid;
}

/**
 *  获得access_token
 */
+ (NSString *)access_token {
    if (_access_token == nil) {
        _access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    }
    return _access_token;
}
/**
 *  获得uid
 */
+ (NSString *)uid {
    if (_uid == nil) {
        _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    }
    return _uid;
}
/**
 *  通过NSData获得URL
 *
 *  @param data     上传的数据
 *  @param fileName 上传后的名字
 *  @param success  成功调用 传入资源url
 *  @param error    失败调用
 */
+ (void)urlStringWithData:(NSData *)data fileName:(NSString *)fileName success:(void (^)(NSString *url))success error:(void (^)(NSError *error))error {
    
    [self uploadToken:fileName complete:^(NSString *token, NSError *reerror) {
        if(token) {
            QNUploadManager *mgr = [QNUploadManager sharedInstanceWithConfiguration:nil];
            [mgr putData:data key:fileName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                if (success) {
                    success([NSString stringWithFormat:@"%@/%@", qiniuHost, key]);
                }
            } option:nil];
        } else {
            if (error) {
               error(reerror);
            }
        }
    }];
    
}

@end
