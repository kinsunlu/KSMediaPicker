//
//  KSMediaViewerView.h
//  kinsun
//
//  Created by kinsun on 2018/12/4.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSMediaViewerView : UIView

@property (nonatomic, weak, readonly) UIView *barrierView;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END
