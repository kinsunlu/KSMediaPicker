//
//  KSIndicatorLabelControl.h
//  kinsun
//
//  Created by kinsun on 2018/12/1.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSIndicatorLabelControl : UIControl

@property (nonatomic, copy) NSAttributedString *attributText;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;

- (void)willFinishInit;
- (CGSize)textSizeOfSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
