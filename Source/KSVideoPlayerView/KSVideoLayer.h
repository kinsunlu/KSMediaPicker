//
//  KSVideoLayer.h
// 
//
//  Created by kinsun on 2018/11/21.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const KSVideoLayerDidChangedNotification;
FOUNDATION_EXPORT NSNotificationName const KSVideoLayerDidResetNotification;

typedef NS_ENUM(NSInteger, KSVideoLayerGravity) {
    KSVideoLayerGravityResizeAspect = 0,
    KSVideoLayerGravityResizeAspectFill,
    KSVideoLayerGravityResize
};

@interface KSVideoLayer : CALayer

@property (nonatomic, copy) void (^videoTimeDidChangdWithLeftTime)(float time);
@property (nonatomic, copy) void (^videoTimeDidChangdCallback)(CMTime time);
@property (nonatomic, copy) void (^videoCanBePlayed)(float duration);
@property (nonatomic, copy) void (^videoPlaybackFinished)(void);

@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) KSVideoLayerGravity videoGravity;
@property (nonatomic) float volume;

+ (instancetype)shareInstance;

- (void)play;
- (void)pause;
- (void)stop;

- (void)changeVideoTime:(float)time;

- (void)resetPlayer;
- (void)forcePlay;
- (void)forcePause;

@end

NS_ASSUME_NONNULL_END
