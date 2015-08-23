//
//  ZGVLHttpTool.m
//  微聊
//
//  Created by weimi on 15/8/16.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import "ZGVLHttpTool.h"
#import "AFNetworking.h"
@implementation ZGVLHttpTool

+ (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

@end
