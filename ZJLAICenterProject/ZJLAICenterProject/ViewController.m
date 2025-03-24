//
//  ViewController.m
//  ZJLAICenterProject
//
//  Created by zjl on 2025/3/24.
//

#import "ViewController.h"
#import "DeepSeekClient.h"
#import "DeepSeekStreamClient.h"
#import "ConfigureHtmlContent.h"

@interface ViewController ()
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) UITextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textView= [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_textView];
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
    DeepSeekStreamClient *client = [[DeepSeekStreamClient alloc] initWithAPIKey:@""];

    // 启动流式请求
    [client startStreamWithPrompt:@"你好，请写一首关于春天的诗"];
    client.streamHandler = ^(NSString * _Nonnull reasoning_content, NSString * _Nonnull content, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (reasoning_content.length > 0) {
                _text = [NSString stringWithFormat:@"%@%@",_text,reasoning_content];

            }else if (content.length > 0) {
                _text = [NSString stringWithFormat:@"%@%@",_text,content];

            }
            _textView.attributedText = [[[ConfigureHtmlContent alloc] init] attributedStringFromHTML:_text];
            [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 0)];

        });

    };


}
// 终止请求
- (void)stopStream {
//    [self.session invalidateAndCancel];
}

@end
