//
//  ZGStatus.h
//  微聊
//
//  Created by weimi on 15/8/16.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGStatus : NSObject

/**
 *  状态内容
 */
@property (nonatomic, copy) NSString *text;
/**
 *  状态配图,数组 最多为9,多的会被丢弃掉
 */
@property (nonatomic, strong)NSArray *pics;

@end
