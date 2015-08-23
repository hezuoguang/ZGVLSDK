//
//  ZGVLTool.h
//  微聊
//
//  Created by weimi on 15/8/16.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ZGVLTool : NSObject
/**
 *  保存access_token uid
 */
+ (void)saveAccess_token:(NSString *)access_token uid:(NSString *)uid;
/**
 *  获得access_token
 */
+ (NSString *)access_token;
/**
 *  获得uid
 */
+ (NSString *)uid;
/**
 *  通过NSData获得URL
 *
 *  @param data     上传的数据
 *  @param fileName 上传后的名字
 *  @param success  成功调用
 *  @param error    失败调用
 */
+ (void)urlStringWithData:(NSData *)data fileName:(NSString *)fileName success:(void (^)(NSString *url))success error:(void (^)(NSError *error))error;
@end
