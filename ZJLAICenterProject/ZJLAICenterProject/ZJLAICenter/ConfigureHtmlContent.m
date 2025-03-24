//
//  ConfigureHtmlContent.m
//  ZJLAICenterProject
//
//  Created by zjl on 2025/3/24.
//

#import "ConfigureHtmlContent.h"
@interface ConfigureHtmlContent()
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) UILabel *targetLabel;
@property (strong, nonatomic) NSAttributedString *fullAttributedText;
@end
@implementation ConfigureHtmlContent
- (void)startPrintingHTML:(NSString *)html
                onLabel:(UILabel *)label
          withInterval:(NSTimeInterval)interval {
    
    [self stopPrinting];
    
    // 转换 HTML 到富文本
    NSAttributedString *attributedText = [self attributedStringFromHTML:html];
    self.fullAttributedText = attributedText;
    self.targetLabel = label;
    self.currentIndex = 0;
    
    // 初始化空内容
    self.targetLabel.attributedText = [[NSAttributedString alloc] init];
    
    // 启动定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                 target:self
                                               selector:@selector(updateHTMLText)
                                               userInfo:nil
                                                repeats:YES];
}

- (NSAttributedString *)attributedStringFromHTML:(NSString *)html {
    NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
    return [[NSAttributedString alloc] initWithData:data
                                            options:@{NSDocumentTypeDocumentOption: NSHTMLTextDocumentType}
                                 documentAttributes:nil
                                              error:nil];
}

- (void)updateHTMLText {
    if (self.currentIndex >= self.fullAttributedText.length) {
        [self stopPrinting];
        return;
    }
    
    // 逐步构建富文本
    NSMutableAttributedString *currentText = [self.targetLabel.attributedText mutableCopy];
    NSRange range = NSMakeRange(self.currentIndex, 1);
    NSAttributedString *nextChar = [self.fullAttributedText attributedSubstringFromRange:range];
    [currentText appendAttributedString:nextChar];
    
    // 主线程更新
    dispatch_async(dispatch_get_main_queue(), ^{
        self.targetLabel.attributedText = currentText;
    });
    
    self.currentIndex++;
}

- (void)stopPrinting {
    [self.timer invalidate];
    self.timer = nil;
}
@end
