//
//  ZGVLDBTool.m
//  微聊
//
//  Created by weimi on 15/8/17.
//  Copyright (c) 2015年 weimi. All rights reserved.
//

#import "ZGVLDBTool.h"
#import "ZGVLConst.h"
#import "ZGVLTool.h"
#import "FMDB.h"
@implementation ZGVLDBTool

static FMDatabase *_db;

+ (FMDatabase *)db {
    if (_db == nil) {
        _db = [[FMDatabase alloc] initWithPath:ZGVLDBPath];
        NSString *createTableSql = @"CREATE TABLE IF NOT EXISTS message(`pk` TEXT NOT NULL, `m_id` INTEGER NOT NULL,`text` TEXT NOT NULL,`to_user` TEXT NOT NULL,`from_user` TEXT NOT NULL,`uid` TEXT NOT NULL,PRIMARY KEY(pk));";
        NSString *createTableSql2 = @"CREATE TABLE IF NOT EXISTS status(`pk` TEXT NOT NULL, `s_id` INTEGER NOT NULL,`text` TEXT NOT NULL,`uid` TEXT NOT NULL,PRIMARY KEY(pk));";
        [_db open];
        [_db executeUpdate:createTableSql];
        [_db executeUpdate:createTableSql2];
    }
    return _db;
}


+ (void)saveChatMessageWithDict:(NSDictionary *)message {
    NSString *uid = [ZGVLTool uid];
    NSString *m_id = message[@"m_id"];
    NSString *to_user = message[@"to_user"][@"uid"];
    NSString *from_user = message[@"from_user"][@"uid"];
    NSData *text = [NSKeyedArchiver archivedDataWithRootObject:message];
    [[self db] executeUpdateWithFormat:@"insert into message (pk, m_id, to_user, from_user, uid, text) values(%@, %@, %@, %@, %@, %@)",[NSString stringWithFormat:@"%@-%@", uid, m_id], m_id, to_user, from_user, uid, text];
}

+ (void)saveChatMessageWithArray:(NSArray *)messages {
    for (NSDictionary *message in messages) {
        [self saveChatMessageWithDict:message];
    }
}

+ (void)saveStatusWithDict:(NSDictionary *)status {
    NSString *uid = [ZGVLTool uid];
    NSString *s_id = status[@"s_id"];
    NSData *text = [NSKeyedArchiver archivedDataWithRootObject:status];
    [[self db] executeUpdateWithFormat:@"insert into status (pk, s_id, uid, text) values(%@, %@, %@, %@)",[NSString stringWithFormat:@"%@-%@", uid, s_id], s_id, uid, text];
}
+ (void)saveStatusWithArray:(NSArray *)statuses {
    for (NSDictionary *status in statuses) {
        [self saveStatusWithDict:status];
    }
}
/**
 *  获取chatMessage数据
 *
 *  @param parameters 查询参数 since_id, max_id 可以不传(默认为最新的)
 *
 *  @return chatMessage 字典 最多20条
 */
+ (NSArray *)queryChatMessage:(NSDictionary *)parameters {
    NSString *sql = nil;
    NSString *to_user = parameters[@"to_user"];
    if (parameters[@"since_id"]) {
        sql = [NSString stringWithFormat:@"select text from message where (to_user = '%@' or from_user = '%@') and uid = '%@' and m_id > %@ order by m_id limit 20",to_user, to_user, [ZGVLTool uid], parameters[@"since_id"]];
    } else if(parameters[@"max_id"]) {
        sql = [NSString stringWithFormat:@"select text from message where (to_user = '%@' or from_user = '%@') and uid = '%@' and m_id < %@ order by m_id desc limit 20",to_user, to_user, [ZGVLTool uid], parameters[@"max_id"]];
    } else {
        sql = [NSString stringWithFormat:@"select text from message where (to_user = '%@' or from_user = '%@') and uid = '%@' order by m_id desc limit 20",to_user, to_user, [ZGVLTool uid]];
    }
    FMResultSet *results = [[ZGVLDBTool db] executeQuery:sql];
    NSMutableArray *messages = [NSMutableArray array];
    while (results.next) {
        NSData *data = [results dataForColumnIndex:0];
        NSDictionary *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (parameters[@"since_id"]) {//保证m_id小的在前
            [messages addObject:message];
        } else {
            [messages insertObject:message atIndex:0];
        }
    }
    return messages;
}
/**
 *  获取status数据
 *
 *  @param parameters 查询参数 since_id, max_id 可以不传(默认为最新的)
 *
 *  @return status 字典 最多20条
 */
+ (NSArray *)queryStatus:(NSDictionary *)parameters {
    NSString *sql = nil;
    if (parameters[@"since_id"]) {
        sql = [NSString stringWithFormat:@"select text from status where uid = '%@' and s_id > %@ order by s_id limit 20", [ZGVLTool uid], parameters[@"since_id"]];
    } else if(parameters[@"max_id"]) {
        sql = [NSString stringWithFormat:@"select text from status where uid = '%@' and s_id < %@ order by s_id desc limit 20", [ZGVLTool uid], parameters[@"max_id"]];
    } else {
        sql = [NSString stringWithFormat:@"select text from status where uid = '%@' order by s_id desc limit 20", [ZGVLTool uid]];
    }
    FMResultSet *results = [[ZGVLDBTool db] executeQuery:sql];
    NSMutableArray *statuses = [NSMutableArray array];
    while (results.next) {
        NSData *data = [results dataForColumnIndex:0];
        NSDictionary *status = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (parameters[@"since_id"]) {//保证s_id大的在前面
            [statuses insertObject:status atIndex:0];
        } else {
            [statuses addObject:status];
        }
        
    }
    return statuses;
}

/**
 *  更新status的评论数
 *
 *  @param s_id  status id
 *  @param count 评论数
 */
+ (void)updateStatusCommentCount:(NSUInteger)s_id count:(NSUInteger)count {
    NSString *sql = [NSString stringWithFormat:@"select text from status where s_id = '%@' limit 1", @(s_id)];
    FMResultSet *results = [[ZGVLDBTool db] executeQuery:sql];
    if (results.next) {
        NSData *data = [results dataForColumnIndex:0];
        NSDictionary *status = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableDictionary *statusM = [NSMutableDictionary dictionaryWithDictionary:status];
        statusM[@"count"] = [NSString stringWithFormat:@"%zd", count];
        NSData *text = [NSKeyedArchiver archivedDataWithRootObject:statusM];
        [[ZGVLDBTool db] executeUpdateWithFormat:@"UPDATE status SET text = %@ WHERE s_id = %@",text, @(s_id)];
    }
}

+ (NSString *)messageSince_id {
    NSString *sql = [NSString stringWithFormat:@"select max(m_id) from message where uid = '%@'", [ZGVLTool uid]];
    FMResultSet *results = [[self db] executeQuery:sql];
    if (results.next) {
        NSString *idstr = [results stringForColumnIndex:0];
        if (!idstr) {
            NSString *idstr = [results stringForColumnIndex:0];
            if (!idstr) {
                return @"0";
            }
            return idstr;
        }
        return idstr;
    }
    return @"0";
    
}
+ (NSString *)messageMax_id {
    NSString *sql = [NSString stringWithFormat:@"select min(m_id) from message where uid = '%@'", [ZGVLTool uid]];
    FMResultSet *results = [[self db] executeQuery:sql];
    if (results.next) {
        NSString *idstr = [results stringForColumnIndex:0];
        if (!idstr) {
            return @"0";
        }
        return idstr;
    }
    return @"0";
    
}
+ (NSString *)statusSince_id {
    NSString *sql = [NSString stringWithFormat:@"select max(s_id) from status where uid = '%@'", [ZGVLTool uid]];
    FMResultSet *results = [[self db] executeQuery:sql];
    if (results.next) {
        NSString *idstr = [results stringForColumnIndex:0];
        if (!idstr) {
            return @"0";
        }
        return idstr;
    }
    return @"0";
    
}
+ (NSString *)statusMax_id {
    NSString *sql = [NSString stringWithFormat:@"select min(s_id) from status where uid = '%@'", [ZGVLTool uid]];
    FMResultSet *results = [[self db] executeQuery:sql];
    if (results.next) {
        NSString *idstr = [results stringForColumnIndex:0];
        if (!idstr) {
            return @"0";
        }
        return idstr;
    }
    return @"0";
    
}

@end
