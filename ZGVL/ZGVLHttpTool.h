//
//  ZGVLHttpTool.h
//  微聊
//
//  Created by weimi on 15/8/16.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGVLHttpTool : NSObject

+ (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *zgerror))failure;

@end
