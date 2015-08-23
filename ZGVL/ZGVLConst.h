//
//  ZGVLConst.h
//  微聊
//
//  Created by weimi on 15/8/17.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HOST @"http://zgvl.sinaapp.com"
//#define HOST @"http://127.0.0.1:8000"
#define ZGVLDBPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZGVL.sqlite"]
extern const NSString *qiniuHost;
@interface ZGVLConst : NSObject

@end
