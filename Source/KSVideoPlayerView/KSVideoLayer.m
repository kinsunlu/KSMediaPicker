//
//  KSVideoLayer.m
// 
//
//  Created by kinsun on 2018/11/21.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSVideoLayer.h"

static NSString * const k_AVPlayerStatusKey = @"status";
NSNotificationName const KSVideoLayerDidChangedNotification = @"KSVideoLayerDidChangedNotification";
NSNotificationName const KSVideoLayerDidResetNotification = @"KSVideoLayerDidResetNotification";

@implementation KSVideoLayer {
    AVPlayer *_player;
    __weak AVPlayerLayer *_playerLayer;
    
    id _playTimeObserver;
    
    BOOL _isInBackground;
}

static KSVideoLayer *k_instance = nil;
+ (instancetype)shareInstance {
    if (k_instance == nil) {
        @synchronized (self) {
            if (k_instance == nil) {
                k_instance = [self layer];
            }
        }
    }
    return k_instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _isInBackground = NO;
        AVPlayer *player = [[AVPlayer alloc] init];
        _player = player;
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        [self addSublayer:playerLayer];
        _playerLayer = playerLayer;
        
        NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
        [notificationCenter addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        __weak typeof(self) weakSelf = self;
        _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10.f) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [weakSelf videoTimeDidChanged];
        }];
    }
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    _playerLayer.frame = self.bounds;
}

- (void)videoTimeDidChanged {
    if (_videoTimeDidChangdCallback != nil) {
        // 获取 item 当前播放秒
        _videoTimeDidChangdCallback(_playerItem.currentTime);
    }
    
    if (_videoTimeDidChangdWithLeftTime) {
        float duration = CMTimeGetSeconds(_playerItem.duration);// 获取视频长度
        float playLength = CMTimeGetSeconds(_playerItem.currentTime);// 获取视频长度
         _videoTimeDidChangdWithLeftTime(duration-playLength);
    }
}

- (void)playbackFinished:(NSNotification *)notification {
    if (notification.object == _playerItem) {
        _playing = NO;
        NSLog(@"视频播放完成通知");
        [_playerItem seekToTime:kCMTimeZero]; // 跳转到初始
        if (_videoPlaybackFinished != nil) {
            _videoPlaybackFinished();
        }
    }
}

- (void)didEnterBackgroundNotification:(NSNotification *)noti {
    [self resetPlayer];
    _isInBackground = YES;
}

- (void)willEnterForegroundNotification:(NSNotification *)noti {
    _isInBackground = NO;
}

- (void)removeItemObserver:(AVPlayerItem *)item {
    if (item != nil) {
        [item.asset cancelLoading];
        [item cancelPendingSeeks];
        [item removeObserver:self forKeyPath:k_AVPlayerStatusKey];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == _playerItem) {
        if ([keyPath isEqualToString:k_AVPlayerStatusKey]) {
            if (!_isInBackground) {
                AVPlayerStatus status = [[change objectForKey:@"new"] integerValue]; // 获取更改后的状态
                if (status == AVPlayerStatusReadyToPlay) {
                    NSLog(@"准备播放");
                    if (_videoCanBePlayed != nil) {
                        float duration = CMTimeGetSeconds(_playerItem.duration);// 获取视频长度
                        NSLog(@"%.2f", duration);
                        _videoCanBePlayed(duration);
                    }
                    // 播放
                    [self play];
                } else if (status == AVPlayerStatusFailed) {
                    NSLog(@"AVPlayerStatusFailed");
                } else {
                    NSLog(@"AVPlayerStatusUnknown");
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (playerItem != _playerItem) {
        [self removeItemObserver:_playerItem];
        _playerItem = playerItem;
        [_player replaceCurrentItemWithPlayerItem:playerItem];
        [playerItem addObserver:self forKeyPath:k_AVPlayerStatusKey options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self play];
    }
}

- (void)forcePlay {
    [_player play];
}

- (void)forcePause {
    [_player pause];
}

- (void)play {
    _playing = YES;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [session setActive:YES error:nil];
    [_player play];
}

- (void)pause {
    _playing = NO;
    [_player pause];
}

- (void)stop {
    if (_playing) {
        [self changeVideoTime:0.f];
        [self pause];
        if (_videoPlaybackFinished != nil) {
            _videoPlaybackFinished();
        }
    }
}

- (void)changeVideoTime:(float)time {
    CMTime changedTime = CMTimeMakeWithSeconds(time, 1.0);
    NSLog(@"changeVideoTime: %.2f", time);
    [_playerItem seekToTime:changedTime completionHandler:nil];
}

- (void)setVideoGravity:(KSVideoLayerGravity)videoGravity {
    _videoGravity = videoGravity;
    AVLayerVideoGravity k_videoGravity = AVLayerVideoGravityResizeAspect;
    switch (videoGravity) {
        case KSVideoLayerGravityResizeAspectFill:
            k_videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        case KSVideoLayerGravityResize:
            k_videoGravity = AVLayerVideoGravityResize;
            break;
        default:
            break;
    }
    _playerLayer.videoGravity = k_videoGravity;
}

- (void)setVolume:(float)volume {
    _player.volume = volume;
}

- (float)volume {
    return _player.volume;
}

- (void)resetPlayer {
    _playing = NO;
    [self removeItemObserver:_playerItem];
    _playerItem = nil;
    [_player replaceCurrentItemWithPlayerItem:nil];
    [NSNotificationCenter.defaultCenter postNotificationName:KSVideoLayerDidResetNotification object:self];
}

- (void)dealloc {
    [self removeItemObserver:_playerItem];
    _playerItem = nil;
    [_player replaceCurrentItemWithPlayerItem:nil];
    [_player removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    [NSNotificationCenter.defaultCenter removeObserver:self];
    _player = nil;
}

@end
