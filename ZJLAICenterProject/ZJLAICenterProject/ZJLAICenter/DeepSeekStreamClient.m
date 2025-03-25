//
//  DeepSeekStreamClient.m
//  ZJLAICenterProject
//
//  Created by zjl on 2025/3/24.
//

#import "DeepSeekStreamClient.h"

@implementation DeepSeekStreamClient

- (instancetype)initWithAPIKey:(NSString *)apiKey {
    self = [super init];
    if (self) {
        _apiKey = [apiKey copy];
    }
    return self;
}

- (void)startStreamWithPrompt:(NSString *)prompt {
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSURL *url = [NSURL URLWithString:@"https://api.deepseek.com/chat/completions"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 配置协议头（网页1的SSE协议要求）
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"text/event-stream" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.apiKey]
   forHTTPHeaderField:@"Authorization"];
    
    // 构建流式请求体（网页2的参数结构）
    NSDictionary *body = @{
        @"model": @"deepseek-reasoner",
        @"messages": @[@{@"role":@"user", @"content":prompt}],
        @"stream": @YES,
        @"temperature": @0.7
//        @"extra_body":@{@"return_reasoning":@(YES)}
    };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    // 创建长连接任务
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
    NSLog(@"deepseek请求参数：%@",body);
}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    
    // 解析SSE格式数据（网页1的data: {...}格式）
    NSString *dataStr = [[NSString alloc] initWithData:self.responseData
                                             encoding:NSUTF8StringEncoding];
    if ([dataStr containsString:@"[DONE]"]) {
        NSLog(@"回答完成");
        _streamFinish();
    }
    NSArray *events = [dataStr componentsSeparatedByString:@"\n\n"];
    
    for (NSString *event in events) {
        if ([event hasPrefix:@"data: "]) {
            
            NSString *jsonStr = [event substringFromIndex:6];
            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:0
                                                                  error:&error];

            if (!error && dict[@"choices"]) {
                NSString *reasoning = dict[@"choices"][0][@"delta"][@"reasoning_content"];
                if (reasoning) {
                    if ([reasoning isKindOfClass:[NSNull class]]) {
                        
                    }else {
                        self.streamHandler(reasoning,@"", nil);
                        NSLog(@"reasoning：%@",reasoning);
                    }
                    
                }
                NSString *content = dict[@"choices"][0][@"delta"][@"content"];
                if (content) {
                    if ([content isKindOfClass:[NSNull class]]) {
                        
                    }else {
                        self.streamHandler(@"",content, nil);
                        NSLog(@"content：%@",content);
                    }

                }
            }
        }
    }
    
    // 保留未完成数据块
    NSString *lastPartial = [events lastObject];
    self.responseData = [[lastPartial dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        NSLog(@"流式连接已被主动终止");
    } else if (error) {
        self.streamHandler(nil,nil, error);
    }
    self.responseData = nil;
}




- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (self.responseData.length > MAX_BUFFER_SIZE) {
        [dataTask cancel];
        self.streamHandler(nil, nil,[NSError errorWithDomain:@"BufferOverflow"
                                                  code:-1
                                              userInfo:nil]);
    }
    completionHandler(NSURLSessionResponseAllow);
}
@end
