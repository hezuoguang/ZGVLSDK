//
//  ZGVLChatMessageTool.m
//  微聊
//
//  Created by weimi on 15/8/17.
//  Copyright (c) 2015年 weimi. All rights reserved.
//  

#import "ZGVLChatMessageTool.h"
#import "ZGVLHttpTool.h"
#import "ZGVLConst.h"
#import "ZGVLDBTool.h"
#import "ZGVLTool.h"
#import "ZGVLNotificationConst.h"
#define newMessageUrl [NSString stringWithFormat:@"%@/api/chat/newmessages.json", HOST]
#define oldMessageUrl [NSString stringWithFormat:@"%@/api/chat/oldmessages.json", HOST]
@implementation ZGVLChatMessageTool

static bool _flag = false;

+ (void)startGetMessage {
    
    
    if(!_flag) {
        _flag = true;
        [self getNewMessages];
    }
    
    [self getOldMessages];
    
}


+ (void)getNewMessages{
    NSDictionary *parameters = @{
                        @"since_id" : [ZGVLDBTool messageSince_id],
                        @"access_token" : [ZGVLTool access_token]
                        };
    [ZGVLHttpTool POST:newMessageUrl parameters:parameters success:^(NSDictionary *response) {
        if (response[@"error"]) {
            if ([response[@"error"][@"message"] isEqualToString:@"登录失效, 请重新登录"]) {
                _flag = false;
                //发送  登录失效通知
                [[NSNotificationCenter defaultCenter] postNotificationName:ZGVLNeedRestartLoginNotification object:nil];
                return ;
            }
        }
        NSArray *messages = response[@"messages"];
        if (messages && messages.count) {
            [ZGVLDBTool saveChatMessageWithArray:messages];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZGVLReceivedNewChatMessageNotification object:nil userInfo:@{ZGVLReceivedNewChatMessageNotificationKey : messages}];
        }
        NSUInteger after = 1;
        if (messages.count < 40) {
            after = 1.5;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZGVLChatMessageTool getNewMessages];
        });
        
    } failure:^(NSError *zgerror) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZGVLChatMessageTool getNewMessages];
        });
    }];
    
    
}

+ (void)getOldMessages {
    NSDictionary *parameters = @{
                                 @"max_id" : [ZGVLDBTool messageMax_id],
                                 @"access_token" : [ZGVLTool access_token]
                                 };
    [ZGVLHttpTool POST:oldMessageUrl parameters:parameters success:^(NSDictionary *response) {
        NSArray *messages = response[@"messages"];
        if (messages.count) {
            [ZGVLDBTool saveChatMessageWithArray:messages];
        }
        
    } failure:^(NSError *zgerror) {
        //NSLog(@"%@", zgerror);
    }];
}



@end
