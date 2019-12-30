//
//  WZLogManager.h
//  WZLog
//
//  Created by wuzaohzou on 2019/12/6.
//  Copyright © 2019 wuzaohzou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define WZLog(module, fmt, ...) [[WZLogManager sharedInstance] logInfo:module logStr:[NSString stringWithFormat:@"当前类名：%@, 当前函数名：%s, 当前函数和参数：%s, 当前函数的行号：%d, 当前文件路径：%s，", NSStringFromClass([self class]), __func__, __PRETTY_FUNCTION__, __LINE__, __FILE__], @"日志：",fmt, ##__VA_ARGS__, nil];

@interface WZLogManager : NSObject
+ (instancetype)sharedInstance;
- (void)logInfo:(NSString*)module logStr:(NSString*)logStr, ...;

@end

NS_ASSUME_NONNULL_END
