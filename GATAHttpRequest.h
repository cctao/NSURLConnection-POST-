//
//  GATAHttpRequest.h
//  GATA
//
//  Created by gaea on 15/4/23.
//  Copyright (c) 2015年 cctao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCHttpRequest : NSObject

+ (instancetype)sharedHttpRequest;

/**
 *  异步网络POST
 *
 *  @param URLString  url
 *  @param parameters 参数
 *  @param success    成功回调
 *  @param failure    失败回调
 */
- (void)POST:(NSString *)URLString
  parameters:(id)parameters
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;
@end