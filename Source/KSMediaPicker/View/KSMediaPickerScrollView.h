//
//  KSMediaPickerScrollView.h
//  KSMediaPickerDemo
//
//  Created by kinsun on 2019/4/29.
//  Copyright © 2019年 kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KSMediaPickerScrollViewDelegate <NSObject, UIScrollViewDelegate>

@optional
- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView;

@end

@interface KSMediaPickerScrollView : UIScrollView

@property (nonatomic, weak) id<KSMediaPickerScrollViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
