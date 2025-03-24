//
//  DeepSeekClient.m
//  ZJLAICenterProject
//
//  Created by zjl on 2025/3/24.
//

#import "DeepSeekClient.h"

@implementation DeepSeekClient
- (instancetype)initWithAPIKey:(NSString *)apiKey {
    self = [super init];
    if (self) {
        _apiKey = [apiKey copy];
    }
    return self;
}

- (void)sendRequestWithPrompt:(NSString *)prompt completion:(void (^)(NSString *response, NSError *error))completion {
    // 构造API地址（根据网页5）
    NSURL *url = [NSURL URLWithString:@"https://api.deepseek.com/chat/completions"];
    
    // 构建请求头（网页1、网页5）
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    
    // 构造请求体（网页5参数说明）
    NSDictionary *messageDict = @{
        @"role": @"user",
        @"content": prompt
    };
    
    NSDictionary *bodyDict = @{
        @"model": @"deepseek-reasoner", // 模型选择（网页5）
        @"messages": @[messageDict],
        @"temperature": @1.3,       // 温度参数（网页5）
        @"max_tokens": @2048        // 最大token限制（网页5）
    };
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&jsonError];
    
    if (jsonError) {
        completion(nil, jsonError);
        return;
    }
    
    [request setHTTPBody:jsonData];
    
    // 发起异步请求（网页1的Java实现转换）
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        // 解析响应（网页5的响应格式）
        NSError *parseError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        if (parseError) {
            completion(nil, parseError);
            return;
        }
        
        // 提取回复内容（网页5示例）
        NSArray *choices = jsonResponse[@"choices"];
        if (choices.count > 0) {
            NSString *content = choices[0][@"message"][@"content"];
            completion(content, nil);
        } else {
            completion(nil, [NSError errorWithDomain:@"DeepSeekError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"No response content"}]);
        }
    }];
    
    [task resume];
}

@end
