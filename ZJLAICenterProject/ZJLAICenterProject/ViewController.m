//
//  ViewController.m
//  ZJLAICenterProject
//
//  Created by zjl on 2025/3/24.
//

#import "ViewController.h"
#import "DeepSeekClient.h"
#import "DeepSeekStreamClient.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化客户端（网页2的密钥配置）
//    DeepSeekClient *client = [[DeepSeekClient alloc] initWithAPIKey:@""];
//
//    // 发送请求（网页5的调用示例）
//    [client sendRequestWithPrompt:@"你好，请写一首关于春天的诗" completion:^(NSString *response, NSError *error) {
//        if (error) {
//            NSLog(@"请求失败: %@", error.localizedDescription);
//            return;
//        }
//        
//        NSLog(@"DeepSeek回复:\n%@", response);
//    }];
    
    // 初始化客户端
    DeepSeekStreamClient *client = [[DeepSeekStreamClient alloc] initWithAPIKey:@"sk-a842a8022ae24988a21280ecf0ef95c4"];

    // 启动流式请求
    [client startStreamWithPrompt:@"你好，请写一首关于春天的诗"];
    client.streamHandler = ^(NSString * _Nonnull chunk, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        
        // 实时追加到文本视图（类似网页2的UI更新）
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            [self.textView insertText:chunk];
//            [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 0)];
        });
    };


}
// 终止请求
- (void)stopStream {
//    [self.session invalidateAndCancel];
}

@end
