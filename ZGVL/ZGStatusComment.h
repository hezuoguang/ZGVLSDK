//
//  ZGStatusComment.h
//  微聊
//
//  Created by weimi on 15/8/17.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGStatusComment : NSObject

/**
 *  评论内容
 */
@property (nonatomic, copy) NSString *text;
/**
 *  被评论的状态id
 */
@property (nonatomic, assign)NSUInteger s_id;

@end
