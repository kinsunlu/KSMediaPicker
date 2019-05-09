//
//  KSSegmentedControl.h
// 
//
//  Created by kinsun on 2018/11/25.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSSegmentedControl : UIView

@property (nonatomic, strong, readonly) NSArray <NSString *> *items;
@property (nonatomic, assign) CGFloat egdeMargin;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, assign) NSUInteger selectedSegmentIndex;
@property (nonatomic, copy) void (^didClickItem)(KSSegmentedControl *segmentedControl, NSInteger index);

@property (nonatomic, assign, getter=isShowIndicator) BOOL showIndicator;
@property (nonatomic, assign) CGFloat indicatorHeight;
@property (nonatomic, assign) CGFloat indicatorBottomEgdeInset;
@property (nonatomic, strong) UIColor *indndicatorColor;

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray <NSString *> *)items;
- (void)updateIndicatorProportion:(CGFloat)proportion;

@end

NS_ASSUME_NONNULL_END
