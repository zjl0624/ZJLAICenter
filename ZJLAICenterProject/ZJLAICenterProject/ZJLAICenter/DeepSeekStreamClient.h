//
//  DeepSeekStreamClient.h
//  ZJLAICenterProject
//
//  Created by zjl on 2025/3/24.
//

#import <Foundation/Foundation.h>
// 设置缓冲区阈值（参考网页3的流量控制建议）
#define MAX_BUFFER_SIZE 1024 * 1024 // 1MB
NS_ASSUME_NONNULL_BEGIN

@interface DeepSeekStreamClient : NSObject<NSURLSessionDataDelegate>
@property (nonatomic, copy) NSString *apiKey;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) void (^streamHandler)(NSString *chunk, NSError *error);
@property (nonatomic, strong) NSMutableData *responseData;
- (void)startStreamWithPrompt:(NSString *)prompt;
- (instancetype)initWithAPIKey:(NSString *)apiKey;
@end

NS_ASSUME_NONNULL_END
