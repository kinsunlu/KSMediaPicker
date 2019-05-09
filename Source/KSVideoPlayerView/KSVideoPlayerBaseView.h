//
//  KSVideoPlayerBaseView.h
// 
//
//  Created by kinsun on 2018/12/10.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSVideoLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSVideoPlayerBaseView : UIView

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, weak, readonly) UIImageView *coverView;
@property (nonatomic, assign) KSVideoLayerGravity videoGravity;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign, getter=isShowToolsBar) BOOL showToolsBar;
@property (nonatomic, copy) void (^videoTimeDidChangdWithLeftTime)(float time);
@property (nonatomic, copy) void (^videoPlaybackFinished)(void);
@property (nonatomic, copy) void (^videoTimeDidChangdCallback)(CMTime time);
@property (nonatomic, copy) void (^videoCanBePlayed)(float duration);

@property (nonatomic, strong, nullable) AVPlayerItem *playerItem;

- (void)play;
- (void)pause;
- (void)changeVideoTime:(float)time;
- (void)resetViewStatus;

@end

NS_ASSUME_NONNULL_END
