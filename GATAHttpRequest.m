//
//  GATAHttpRequest.m
//  GATA
//
//  Created by gaea on 15/4/23.
//  Copyright (c) 2015年 cctao. All rights reserved.
//

#import "GATAHttpRequest.h"

@interface CCHttpRequest()<NSURLConnectionDataDelegate>


@property (nonatomic, strong) NSURL *postURL;

@property (nonatomic, strong) NSURLConnection *postConnection;
/** 运行循环 */
@property (nonatomic, assign) CFRunLoopRef postRunloop;

// --- 定义 block 属性 ---

@property (nonatomic, copy) void (^success)(id);
@property (nonatomic, copy) void  (^failure)(NSError *);

@end
@implementation GATAHttpRequest


+ (instancetype)sharedHttpRequest {
    
        return [[self alloc]init];
}

     
- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
    self.success = success;
    self.failure = failure;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 1.生成request
        NSMutableURLRequest *request = [self request:URLString parameters:parameters];

        // 2. 开始网络连接
        self.postConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        // 3. 启动网络连接
        [self.postConnection start];
        // 4. 利用运行循环实现多线程
        self.postRunloop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    });
}


- (NSMutableURLRequest *)request:(NSString*)URLString parameters:(id)parameters{
    
    if (URLString == nil) {
        NSLog(@"URL地址为空！！");
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30.0;
    [request addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    
    if (parameters != nil)
    {
        NSMutableString *parameterStr = [[NSMutableString alloc]init];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *str = [NSString stringWithFormat:@"%@=%@&",key,obj];
            
            [parameterStr appendFormat:@"%@",str];
        }];
        
        NSString *paramete  = [parameterStr substringWithRange:NSMakeRange(0, [parameterStr length] - 1)];
        request.HTTPBody = [paramete dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:true];
    }

    return  request;
}

#pragma mark - NSURLConnectionDataDelegate
// 1. 接收到响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
   //暂时无使用
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.success) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.success(data);});
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    CFRunLoopStop(self.postRunloop);
}

// 出错
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    CFRunLoopStop(self.postRunloop);
    if (self.failure) {
        self.failure(error);
    }
    
}


@end
     
