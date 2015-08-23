//
//  ZGBaseUserInfo.h
//  微聊
//
//  Created by weimi on 15/8/17.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGBaseUserInfo : NSObject
/**
 *  用户名
 */
@property (nonatomic, copy) NSString *uid;
/**
 *  昵称
 */
@property (nonatomic, copy) NSString *name;
/**
 *  头像
 */
@property (nonatomic, copy) NSString *photo;
/**
 *  授权标识
 */
@property (nonatomic, copy) NSString *access_token;

@end
