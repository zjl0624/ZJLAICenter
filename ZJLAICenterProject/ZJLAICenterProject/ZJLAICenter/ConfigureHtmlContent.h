//
//  ConfigureHtmlContent.h
//  ZJLAICenterProject
//
//  Created by zjl on 2025/3/24.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
NS_ASSUME_NONNULL_BEGIN

@interface ConfigureHtmlContent : NSObject
- (NSAttributedString *)attributedStringFromHTML:(NSString *)html;
@end

NS_ASSUME_NONNULL_END
