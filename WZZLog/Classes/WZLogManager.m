//
//  WZLogManager.m
//  WZLog
//
//  Created by wuzaohzou on 2019/12/6.
//  Copyright © 2019 wuzaohzou. All rights reserved.
//

#import "WZLogManager.h"

// 日志文件保存目录
static const NSString *LogFilePath = @"/Documents/WZLog/";
// 日志压缩包文件名
static const NSString *ZipFileName = @"WZLog.zip";
static const NSString *fileName = @"loger";
const char *queueName = "wzlog_queue";

@interface WZLogManager ()
// 日志的目录路径
@property (nonatomic, copy) NSString* basePath;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation WZLogManager

+ (instancetype)sharedInstance {
    
    static WZLogManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[WZLogManager alloc]init];
        }
    });
    
    return instance;
}


// 获取当前时间
+ (NSTimeInterval)getCurrDate {
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    
    return [localeDate timeIntervalSince1970];
}

//时间戳转为格式时间
+ (NSString *)timeIntervalToFormat:(NSTimeInterval)localTimeInterval{
    time_t timeInterval = (time_t)localTimeInterval;
    struct tm *time = localtime(&timeInterval);
    NSString *timeStr = [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d",time->tm_year + 1900,time->tm_mon + 1,time->tm_mday, time->tm_hour, time->tm_min, time->tm_sec];
    return timeStr;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        // 日志的目录路径
        _basePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),LogFilePath];
        _queue = dispatch_queue_create(queueName,NULL);
    }
    return self;
}

- (void)logInfo:(NSString*)module logStr:(NSString*)logStr, ... {
    
    NSString *arg = logStr;
    NSMutableString* parmaStr = [NSMutableString string];
    // 声明一个参数指针
    va_list paramList;
    // 获取参数地址，将paramList指向logStr
    va_start(paramList, logStr);
    
    
    @try {
        // 遍历参数列表
        while (arg) {
#if DEBUG
            NSLog(@"%@", arg);
#endif
            [parmaStr appendString:arg];
            // 指向下一个参数，后面是参数类似
            arg = va_arg(paramList, NSString*);
            
        }
    } @catch (NSException *exception) {
        [parmaStr appendString:@"【记录日志异常】"];
    } @finally {
        // 将参数列表指针置空
        va_end(paramList);
    }
    
    
    // 异步执行
    dispatch_async(_queue, ^{
        
        // 获取当前日期做为文件名
        NSString* filePath = [NSString stringWithFormat:@"%@%@",self.basePath,fileName];
        
        // [时间]-[模块]-日志内容
        NSString* timeStr = [self.class timeIntervalToFormat:[self.class getCurrDate]];
        NSString* writeStr = [NSString stringWithFormat:@"[%@]-[%@]-%@\n",timeStr,module,parmaStr];
        
        // 写入数据
        [self writeFile:filePath stringData:writeStr];
#if DEBUG
        NSLog(@"写入日志:%@",filePath);
#endif
    });
}

/**
 *  写入字符串到指定文件，默认追加内容
 *
 *  @param filePath   文件路径
 *  @param stringData 待写入的字符串
 */
- (void)writeFile:(NSString*)filePath stringData:(NSString*)stringData {
    
    // 待写入的数据
    NSData* writeData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    // NSFileManager 用于处理文件
    BOOL createPathOk = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[filePath stringByDeletingLastPathComponent] isDirectory:&createPathOk]) {
        // 目录不存先创建
        [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        // 文件不存在，直接创建文件并写入
        [writeData writeToFile:filePath atomically:NO];
    }else{
        
        // NSFileHandle 用于处理文件内容
        // 读取文件到上下文，并且是更新模式
        NSFileHandle* fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        
        // 跳到文件末尾
        [fileHandler seekToEndOfFile];
        
        // 追加数据
        [fileHandler writeData:writeData];
        
        // 关闭文件
        [fileHandler closeFile];
    }
}

@end
