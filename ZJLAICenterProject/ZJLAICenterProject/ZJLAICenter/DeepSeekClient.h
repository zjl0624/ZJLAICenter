//
//  DeepSeekClient.h
//  ZJLAICenterProject
//
//  Created by zjl on 2025/3/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeepSeekClient : NSObject
@property (nonatomic, copy) NSString *apiKey;

- (instancetype)initWithAPIKey:(NSString *)apiKey;
- (void)sendRequestWithPrompt:(NSString *)prompt completion:(void (^)(NSString *response, NSError *error))completion;

@end



NS_ASSUME_NONNULL_END
