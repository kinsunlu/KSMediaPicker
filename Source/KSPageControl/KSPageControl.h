//
//  KSPageControl.h
//
//
//  Created by kinsun on 2018/12/2.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) CGFloat tooMuchEgdeMargin;

- (void)updatePageControlWithScrollView:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
